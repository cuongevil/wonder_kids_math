import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

class AnimatedBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<IconData> icons;

  const AnimatedBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.icons,
  });

  @override
  State<AnimatedBottomNavBar> createState() => AnimatedBottomNavBarState();
}

class AnimatedBottomNavBarState extends State<AnimatedBottomNavBar>
    with SingleTickerProviderStateMixin {
  bool _visible = true;

  void show() => setState(() => _visible = true);
  void hide() => setState(() => _visible = false);

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 400),
      offset: _visible ? Offset.zero : const Offset(0, 2),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: _visible ? 1 : 0,
        curve: Curves.easeOut,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: AppTheme.tpPurple.withOpacity(0.25),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(widget.icons.length, (index) {
              final isActive = widget.currentIndex == index;
              return GestureDetector(
                onTap: () => widget.onTap(index),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 1, end: isActive ? 1.2 : 1),
                  duration: const Duration(milliseconds: 250),
                  builder: (_, scale, child) => Transform.scale(
                    scale: scale,
                    child: ShaderMask(
                      shaderCallback: (rect) =>
                          AppTheme.primaryGradient.createShader(rect),
                      child: Icon(
                        widget.icons[index],
                        color: isActive ? Colors.white : Colors.white60,
                        size: isActive ? 28 : 24,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
