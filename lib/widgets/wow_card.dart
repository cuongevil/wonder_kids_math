import 'dart:math';
import 'package:flutter/material.dart';

class WowCard extends StatefulWidget {
  final String imagePath;
  final String text;

  const WowCard({
    super.key,
    required this.imagePath,
    required this.text,
  });

  @override
  State<WowCard> createState() => _WowCardState();

  /// 🔹 Hàm static để trigger animation từ bên ngoài
  static void triggerAnimation(BuildContext context) {
    final state = context.findAncestorStateOfType<_WowCardState>();
    state?._playAnimation();
  }
}

class _WowCardState extends State<WowCard> with TickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _bounceAnim;
  late Animation<double> _rotateAnim;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // 🔹 Bounce nhẹ
    _bounceAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.08), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.08, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _animController, curve: Curves.easeInOut));

    // 🔹 Xoay phải → xoay trái → về thẳng đứng
    _rotateAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.05), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.05, end: -0.05), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -0.05, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _animController, curve: Curves.easeInOut));
  }

  void _playAnimation() {
    _animController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: Container(
        key: ValueKey(widget.imagePath + widget.text),
        width: size.width * 0.85,
        height: size.height * 0.45,
        padding: EdgeInsets.all(size.width * 0.06),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFF5F7), Color(0xFFE5F0FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 🌟 Sticker random bay quanh
            ...List.generate(5, (i) {
              final left = _random.nextDouble() * (size.width * 0.65);
              final top = _random.nextDouble() * (size.height * 0.3);
              final icons = [Icons.star, Icons.favorite, Icons.catching_pokemon];
              final icon = icons[_random.nextInt(icons.length)];
              return Positioned(
                left: left,
                top: top,
                child: Opacity(
                  opacity: 0.5,
                  child: Icon(
                    icon,
                    color: Colors.primaries[_random.nextInt(Colors.primaries.length)]
                        .withOpacity(0.7),
                    size: 20,
                  ),
                ),
              );
            }),

            // Nội dung chính (ảnh + chữ)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: _bounceAnim,
                  child: RotationTransition(
                    turns: _rotateAnim,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        widget.imagePath,
                        width: size.width * 0.65,
                        height: size.width * 0.65,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                Text(
                  widget.text,
                  style: TextStyle(
                    fontSize: size.width * 0.075,
                    fontWeight: FontWeight.w600,
                    color: Colors.deepPurple,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }
}
