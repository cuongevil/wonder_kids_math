import 'dart:math';
import 'dart:ui';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import '../themes/app_theme.dart';
import 'wonderkids_shimmer_text.dart';
import 'wonderkids_glow_effect.dart';

/// ⚡ WonderKidsStreakExplosion
/// Hiệu ứng lửa bùng nổ khi bé đạt mốc streak lớn (10, 20, 30 ngày...)
/// Ánh sáng nổ, lửa lan rộng, confetti bay, chữ shimmer & glow fintech.
class WonderKidsStreakExplosion extends StatefulWidget {
  final int streakDays;
  final VoidCallback onClose;

  const WonderKidsStreakExplosion({
    super.key,
    required this.streakDays,
    required this.onClose,
  });

  @override
  State<WonderKidsStreakExplosion> createState() =>
      _WonderKidsStreakExplosionState();
}

class _WonderKidsStreakExplosionState extends State<WonderKidsStreakExplosion>
    with TickerProviderStateMixin {
  late ConfettiController _confettiCtrl;
  late AnimationController _burstCtrl;
  late AnimationController _glowCtrl;
  late AnimationController _flameCtrl;

  @override
  void initState() {
    super.initState();
    _confettiCtrl = ConfettiController(duration: const Duration(seconds: 3));
    _burstCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _flameCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    Future.delayed(const Duration(milliseconds: 400), () {
      _burstCtrl.forward();
      _confettiCtrl.play();
    });
  }

  @override
  void dispose() {
    _confettiCtrl.dispose();
    _burstCtrl.dispose();
    _glowCtrl.dispose();
    _flameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = sin(_glowCtrl.value * 2 * pi) * 0.5 + 0.5;
    final width = MediaQuery.of(context).size.width * 0.85;

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 🌫 Làm mờ nền
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.black.withOpacity(0.4)),
          ),

          // 🎊 Confetti bay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiCtrl,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 35,
              maxBlastForce: 18,
              minBlastForce: 8,
              emissionFrequency: 0.05,
              colors: const [
                Colors.amber,
                Colors.pinkAccent,
                Colors.lightBlueAccent,
                Colors.greenAccent,
                Colors.deepPurpleAccent,
              ],
            ),
          ),

          // 💥 Hiệu ứng nổ ánh sáng trung tâm
          AnimatedBuilder(
            animation: _burstCtrl,
            builder: (context, _) {
              final progress = Curves.easeOutCubic.transform(
                _burstCtrl.value,
              );
              final radius = 80 + progress * 400;
              final opacity = (1 - progress).clamp(0.0, 1.0);
              return Opacity(
                opacity: opacity,
                child: Container(
                  width: radius,
                  height: radius,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.8),
                        AppTheme.tpOrange.withOpacity(0.6),
                        Colors.transparent,
                      ],
                      stops: const [0.1, 0.5, 1.0],
                    ),
                  ),
                ),
              );
            },
          ),

          // 🔥 Lửa fintech trung tâm
          AnimatedBuilder(
            animation: _flameCtrl,
            builder: (context, _) {
              final sway = sin(_flameCtrl.value * 2 * pi) * 0.1;
              return Transform.rotate(
                angle: sway,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 160,
                      height: 200,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.tpOrange.withOpacity(0.9),
                            Colors.amberAccent,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(140)),
                      ),
                    ),
                    Container(
                      width: 120,
                      height: 160,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.9),
                            AppTheme.tpOrange.withOpacity(0.4),
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(120)),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // ✨ Halo tím–cam lan tỏa quanh lửa
          AnimatedBuilder(
            animation: _glowCtrl,
            builder: (context, _) {
              return Container(
                width: width * (1.1 + t * 0.1),
                height: width * (1.1 + t * 0.1),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.tpPurple.withOpacity(0.5 + t * 0.3),
                      AppTheme.tpOrange.withOpacity(0.4 - t * 0.2),
                      Colors.transparent,
                    ],
                    stops: const [0.2, 0.7, 1],
                  ),
                ),
              );
            },
          ),

          // 🔢 Số streak đạt được
          WonderKidsGlowEffect(
            radius: 80,
            intensity: 0.6,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                WonderKidsShimmerText(
                  text: "${widget.streakDays} ngày 🔥",
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Chuỗi học bất bại!",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // 🔘 Nút đóng
          Positioned(
            bottom: 60,
            child: GestureDetector(
              onTap: widget.onClose,
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [AppTheme.tpPurple, AppTheme.tpOrange],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.tpPurple.withOpacity(0.5),
                      blurRadius: 25,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Text(
                  "Tiếp tục 🔥",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
