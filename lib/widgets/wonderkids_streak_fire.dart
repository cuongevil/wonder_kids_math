import 'dart:math';
import 'package:flutter/material.dart';
import '../themes/app_theme.dart';
import 'wonderkids_shimmer_text.dart';
import 'wonderkids_glow_effect.dart';

/// 🔥 WonderKidsStreakFire
/// Hiệu ứng ngọn lửa streak (chuỗi ngày học liên tục)
/// Kiểu Duolingo Fire + TPBank Fintech Glow.
class WonderKidsStreakFire extends StatefulWidget {
  final int streakDays;
  final double size;
  final bool animate;

  const WonderKidsStreakFire({
    super.key,
    required this.streakDays,
    this.size = 160,
    this.animate = true,
  });

  @override
  State<WonderKidsStreakFire> createState() => _WonderKidsStreakFireState();
}

class _WonderKidsStreakFireState extends State<WonderKidsStreakFire>
    with TickerProviderStateMixin {
  late AnimationController _flameCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _shineCtrl;

  @override
  void initState() {
    super.initState();
    _flameCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _shineCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _flameCtrl.dispose();
    _pulseCtrl.dispose();
    _shineCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = sin(_pulseCtrl.value * 2 * pi) * 0.5 + 0.5;
    final baseSize = widget.size;

    return SizedBox(
      width: baseSize,
      height: baseSize * 1.2,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 💫 Glow tím-cam xung quanh
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (context, _) {
              return Container(
                width: baseSize * (1.1 + t * 0.1),
                height: baseSize * (1.1 + t * 0.1),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.tpPurple.withOpacity(0.5 + t * 0.2),
                      AppTheme.tpOrange.withOpacity(0.3),
                      Colors.transparent,
                    ],
                    stops: const [0.2, 0.6, 1],
                  ),
                ),
              );
            },
          ),

          // 🔥 Lửa động (có shimmer)
          AnimatedBuilder(
            animation: _flameCtrl,
            builder: (context, _) {
              final sway = sin(_flameCtrl.value * 2 * pi) * 0.08;
              return Transform.rotate(
                angle: sway,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: baseSize * 0.6,
                      height: baseSize * 0.9,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFFFB300), Color(0xFFFF8B00)],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        borderRadius:
                        BorderRadius.vertical(top: Radius.circular(120)),
                      ),
                    ),
                    Container(
                      width: baseSize * 0.45,
                      height: baseSize * 0.6,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFFFF9C4), Color(0xFFFFB300)],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        borderRadius:
                        BorderRadius.vertical(top: Radius.circular(100)),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // ✨ Ánh sáng shimmer trên lửa
          AnimatedBuilder(
            animation: _shineCtrl,
            builder: (context, _) {
              final shinePos = (sin(_shineCtrl.value * 2 * pi) * 0.5 + 0.5);
              return Positioned(
                top: baseSize * 0.4 * (1 - shinePos),
                child: Container(
                  width: baseSize * 0.25,
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.8),
                        Colors.white.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // 🔢 Số ngày streak (shimmer)
          Positioned(
            bottom: 0,
            child: WonderKidsGlowEffect(
              radius: 50,
              intensity: 0.5,
              child: Column(
                children: [
                  WonderKidsShimmerText(
                    text: "${widget.streakDays}",
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "ngày liên tiếp",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
