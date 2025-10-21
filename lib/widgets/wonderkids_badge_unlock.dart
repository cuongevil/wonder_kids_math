import 'dart:math';
import 'dart:ui';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import '../themes/app_theme.dart';
import 'wonderkids_shimmer_text.dart';
import 'wonderkids_glow_effect.dart';

/// 🏅 WonderKidsBadgeUnlock
/// Hiệu ứng mở huy hiệu mới — kiểu TPBank Glow + Duolingo medal
/// Có badge quay nhẹ, halo sáng, confetti và shimmer text.
class WonderKidsBadgeUnlock extends StatefulWidget {
  final String badgeName;
  final String description;
  final String badgeIcon;
  final VoidCallback onClose;

  const WonderKidsBadgeUnlock({
    super.key,
    required this.badgeName,
    required this.description,
    required this.badgeIcon,
    required this.onClose,
  });

  @override
  State<WonderKidsBadgeUnlock> createState() => _WonderKidsBadgeUnlockState();
}

class _WonderKidsBadgeUnlockState extends State<WonderKidsBadgeUnlock>
    with TickerProviderStateMixin {
  late ConfettiController _confettiCtrl;
  late AnimationController _rotateCtrl;
  late AnimationController _glowCtrl;
  late AnimationController _fadeCtrl;

  @override
  void initState() {
    super.initState();
    _confettiCtrl = ConfettiController(duration: const Duration(seconds: 4));
    _rotateCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    // 🎊 Delay nhẹ để confetti bay lúc badge sáng rực
    Future.delayed(const Duration(milliseconds: 600), _confettiCtrl.play);
  }

  @override
  void dispose() {
    _confettiCtrl.dispose();
    _rotateCtrl.dispose();
    _glowCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = sin(_glowCtrl.value * 2 * pi) * 0.5 + 0.5;
    final width = MediaQuery.of(context).size.width * 0.85;

    return FadeTransition(
      opacity: _fadeCtrl,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 🌫 Làm mờ nền
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(color: Colors.black.withOpacity(0.35)),
            ),

            // 🎊 Confetti
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiCtrl,
                blastDirectionality: BlastDirectionality.explosive,
                numberOfParticles: 25,
                maxBlastForce: 12,
                minBlastForce: 4,
                emissionFrequency: 0.04,
                colors: const [
                  Colors.amber,
                  Colors.pinkAccent,
                  Colors.lightBlueAccent,
                  Colors.greenAccent,
                  Colors.deepPurpleAccent,
                ],
              ),
            ),

            // 🪩 Popup kính mờ
            Container(
              width: width,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.25),
                    Colors.white.withOpacity(0.15),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.tpPurple.withOpacity(0.4),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ✨ Halo sáng quanh huy hiệu
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _glowCtrl,
                        builder: (context, _) {
                          return Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppTheme.tpPurple
                                      .withOpacity(0.6 + t * 0.3),
                                  AppTheme.tpOrange.withOpacity(0.4 - t * 0.2),
                                  Colors.transparent,
                                ],
                                stops: const [0.2, 0.7, 1],
                              ),
                            ),
                          );
                        },
                      ),
                      // 🏅 Huy hiệu quay nhẹ
                      RotationTransition(
                        turns: Tween(begin: -0.02, end: 0.02)
                            .animate(_rotateCtrl),
                        child: Image.asset(
                          widget.badgeIcon,
                          height: 120,
                          width: 120,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 🌟 Tiêu đề shimmer
                  WonderKidsShimmerText(
                    text: "🏅 Huy hiệu mới!",
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 💜 Tên huy hiệu
                  Text(
                    widget.badgeName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      color: Colors.amberAccent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // 📖 Mô tả huy hiệu
                  Text(
                    widget.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 🔘 Nút đóng
                  GestureDetector(
                    onTap: widget.onClose,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [AppTheme.tpPurple, AppTheme.tpOrange],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.tpPurple.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Text(
                        "Đóng",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
