import 'package:flutter/material.dart';

/// 🌈 Animated gradient background cho card
class AnimatedGradientBackground extends StatefulWidget {
  final List<Color> colors;
  final Widget child;
  final BorderRadius borderRadius;
  final BoxBorder? border;
  const AnimatedGradientBackground({
    super.key,
    required this.colors,
    required this.child,
    required this.borderRadius,
    this.border,
  });
  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState
    extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller =
    AnimationController(vsync: this, duration: const Duration(seconds: 12))
      ..repeat();
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.colors,
              begin: Alignment(-1 + 2 * _controller.value, -1),
              end: Alignment(1 - 2 * _controller.value, 1),
            ),
            borderRadius: widget.borderRadius,
            border: widget.border,
          ),
          child: widget.child,
        );
      },
    );
  }
}
