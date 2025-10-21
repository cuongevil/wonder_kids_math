import 'dart:math';
import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

/// 🌟 WonderKidsGlowEffect
/// Hiệu ứng halo tím–cam động, phản chiếu lan tỏa quanh widget con.
/// - Có thể bọc quanh bất kỳ widget nào.
/// - Dễ tuỳ chỉnh: độ sáng, tốc độ, bán kính.
class WonderKidsGlowEffect extends StatefulWidget {
  final Widget child;
  final double radius;
  final double intensity;
  final Duration duration;
  final bool enablePulse;

  const WonderKidsGlowEffect({
    super.key,
    required this.child,
    this.radius = 50,
    this.intensity = 0.6,
    this.duration = const Duration(seconds: 5),
    this.enablePulse = true,
  });

  @override
  State<WonderKidsGlowEffect> createState() => _WonderKidsGlowEffectState();
}

class _WonderKidsGlowEffectState extends State<WonderKidsGlowEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
    AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
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
      builder: (context, _) {
        final t = (sin(_controller.value * 2 * pi) * 0.5 + 0.5);
        final scale = widget.enablePulse ? (1 + t * 0.05) : 1.0;

        return Stack(
          alignment: Alignment.center,
          children: [
            // 🔮 Glow gradient layer
            Container(
              width: widget.radius * 2,
              height: widget.radius * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.tpPurple.withOpacity(widget.intensity * (0.4 + t * 0.6)),
                    AppTheme.tpOrange.withOpacity(widget.intensity * (0.3 + t * 0.3)),
                    Colors.transparent,
                  ],
                  stops: const [0.2, 0.6, 1],
                ),
              ),
              transform: Matrix4.identity()..scale(scale),
            ),
            widget.child,
          ],
        );
      },
    );
  }
}
