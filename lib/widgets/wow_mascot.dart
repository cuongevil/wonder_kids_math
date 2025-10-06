import 'package:flutter/material.dart';

class WowMascot extends StatefulWidget {
  final bool isHappy; // ✅ Trạng thái cảm xúc
  const WowMascot({super.key, this.isHappy = true});

  @override
  State<WowMascot> createState() => _WowMascotState();
}

class _WowMascotState extends State<WowMascot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounce;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _bounce = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant WowMascot oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Khi thay đổi cảm xúc => reset animation cho mượt
    if (oldWidget.isHappy != widget.isHappy) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String imagePath = widget.isHappy
        ? 'assets/images/mascot/mascot_happy.png'
        : 'assets/images/mascot/mascot_sad.png';

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double offsetY =
        widget.isHappy ? -_bounce.value : _bounce.value / 2;

        return Transform.translate(
          offset: Offset(0, offsetY),
          child: AnimatedScale(
            scale: widget.isHappy ? 1.05 : 0.9,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            child: Image.asset(
              imagePath,
              width: 90,
              height: 90,
            ),
          ),
        );
      },
    );
  }
}
