import 'dart:math';
import 'dart:ui';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import '../themes/app_theme.dart';
import 'wonderkids_glow_effect.dart';
import 'wonderkids_shimmer_button.dart';
import 'wonderkids_shimmer_text.dart';

/// 🔓 WonderKidsLevelUnlockDialog
/// Popup mở khóa level mới — animation chìa khóa xoay, glow bùng sáng.
class WonderKidsLevelUnlockDialog extends StatefulWidget {
  final String levelName;
  final String message;
  final VoidCallback onContinue;

  const WonderKidsLevelUnlockDialog({
    super.key,
    required this.levelName,
    required this.message,
    required this.onContinue,
  });

  @override
  State<WonderKidsLevelUnlockDialog> createState() =>
      _WonderKidsLevelUnlockDialogState();
}

class _WonderKidsLevelUnlockDialogState
    extends State<WonderKidsLevelUnlockDialog> with TickerProviderStateMixin {
  late ConfettiController _confettiCtrl;
  late AnimationController _keyRotateCtrl;
  late AnimationController _glowCtrl;
  late AnimationController _fadeCtrl;

  @override
  void initState() {
    super.initState();
    _confettiCtrl = ConfettiController(duration: const Duration(seconds: 3))
      ..play();

    _keyRotateCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _confettiCtrl.dispose();
    _keyRotateCtrl.dispose();
    _glowCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = sin(_glowCtrl.value * 2 * pi) * 0.5 + 0.5;
    final borderGradient = LinearGradient(
      colors: [
        AppTheme.tpPurple.withOpacity(0.7 + t * 0.3),
        AppTheme.tpOrange.withOpacity(0.7 - t * 0.3),
      ],
    );

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

            // 🎊 Confetti nhẹ
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiCtrl,
                blastDirectionality: BlastDirectionality.explosive,
                numberOfParticles: 20,
                maxBlastForce: 10,
                minBlastForce: 4,
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

            // 🪩 Popup kính mờ
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
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
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // ✨ Viền sáng tím–cam
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        gradient: borderGradient,
                      ),
                    ),
                  ),

                  // 💫 Nội dung chính
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 🔑 Chìa khóa xoay
                      RotationTransition(
                        turns:
                        Tween(begin: -0.1, end: 0.1).animate(_keyRotateCtrl),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Glow tím quanh icon
                            AnimatedBuilder(
                              animation: _glowCtrl,
                              builder: (context, _) {
                                final glowScale = 1.2 + t * 0.2;
                                return Transform.scale(
                                  scale: glowScale,
                                  child: Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: [
                                          AppTheme.tpPurple
                                              .withOpacity(0.5 + t * 0.3),
                                          Colors.transparent,
                                        ],
                                        stops: const [0.5, 1.0],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            const Icon(
                              Icons.vpn_key_rounded,
                              color: Colors.white,
                              size: 80,
                              shadows: [
                                Shadow(
                                    color: Colors.black54,
                                    blurRadius: 8,
                                    offset: Offset(2, 2)),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 🌟 Tiêu đề Shimmer
                      WonderKidsShimmerText(
                        text: "Mở khóa thành công!",
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // 🔸 Level mới
                      Text(
                        "Level mới: ${widget.levelName}",
                        style: const TextStyle(
                          color: Colors.amberAccent,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // 📖 Nội dung
                      Text(
                        widget.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // 🔮 Nút CTA
                      WonderKidsGlowEffect(
                        radius: 70,
                        intensity: 0.6,
                        child: WonderKidsShimmerButton(
                          label: "Tiếp tục ➜",
                          onPressed: widget.onContinue,
                        ),
                      ),
                    ],
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
