import 'dart:math';
import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

/// 💫 WonderKidsShimmerText
/// Hiệu ứng chữ gradient tím–cam, ánh sáng chạy qua (shimmer)
class WonderKidsShimmerText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration duration;
  final double shimmerWidth;
  final bool loop;
  final Gradient? gradient;

  const WonderKidsShimmerText({
    super.key,
    required this.text,
    this.style,
    this.duration = const Duration(seconds: 3),
    this.shimmerWidth = 0.3,
    this.loop = true,
    this.gradient,
  });

  @override
  State<WonderKidsShimmerText> createState() => _WonderKidsShimmerTextState();
}

class _WonderKidsShimmerTextState extends State<WonderKidsShimmerText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
    AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gradient = widget.gradient ??
        const LinearGradient(
          colors: [AppTheme.tpPurple, AppTheme.tpOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final shimmerPos = _controller.value * (1 + widget.shimmerWidth) - widget.shimmerWidth;
        return ShaderMask(
          shaderCallback: (rect) {
            final shimmerGradient = LinearGradient(
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.9),
                Colors.white.withOpacity(0.1),
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment(-1.0 + shimmerPos, 0),
              end: Alignment(1.0 + shimmerPos, 0),
            );

            return LinearGradient(
              colors: gradient.colors,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ).createShader(rect);
          },
          blendMode: BlendMode.srcATop,
          child: Text(
            widget.text,
            textAlign: TextAlign.center,
            style: widget.style ??
                const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: Colors.white,
                  shadows: [
                    Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(1, 1)),
                  ],
                ),
          ),
        );
      },
    );
  }
}
