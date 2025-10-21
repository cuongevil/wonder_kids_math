import 'dart:math';
import 'dart:ui';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import '../themes/app_theme.dart';
import 'wonderkids_shimmer_text.dart';
import 'wonderkids_glow_effect.dart';

/// 🎁 WonderKidsRewardCard
/// Hiệu ứng mở quà / nhận phần thưởng kiểu TPBank Glow
/// - Có hộp quà phát sáng, confetti, chữ shimmer.
/// - Dùng khi bé nhận huy hiệu, điểm thưởng, vật phẩm...
class WonderKidsRewardCard extends StatefulWidget {
  final String title;
  final String rewardText;
  final String? icon; // Ảnh huy hiệu hoặc quà
  final VoidCallback onClose;

  const WonderKidsRewardCard({
    super.key,
    required this.title,
    required this.rewardText,
    required this.onClose,
    this.icon,
  });

  @override
  State<WonderKidsRewardCard> createState() => _WonderKidsRewardCardState();
}

class _WonderKidsRewardCardState extends State<WonderKidsRewardCard>
    with TickerProviderStateMixin {
  late ConfettiController _confettiCtrl;
  late AnimationController _boxCtrl;
  late AnimationController _glowCtrl;
  bool _opened = false;

  @override
  void initState() {
    super.initState();
    _confettiCtrl = ConfettiController(duration: const Duration(seconds: 3));
    _boxCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    // Auto mở hộp sau delay
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _openBox();
    });
  }

  void _openBox() {
    setState(() => _opened = true);
    _boxCtrl.forward();
    _confettiCtrl.play();
  }

  @override
  void dispose() {
    _confettiCtrl.dispose();
    _boxCtrl.dispose();
    _glowCtrl.dispose();
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

    final width = MediaQuery.of(context).size.width * 0.8;

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 🌫 Làm mờ nền
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(color: Colors.black.withOpacity(0.35)),
          ),

          // 🎊 Confetti bay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiCtrl,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 20,
              maxBlastForce: 15,
              minBlastForce: 6,
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

          // 🪩 Card phần thưởng
          AnimatedBuilder(
            animation: _glowCtrl,
            builder: (context, _) {
              return Container(
                width: width,
                padding: const EdgeInsets.all(24),
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
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
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
                    // ✨ Viền sáng tím–cam động
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          gradient: borderGradient,
                        ),
                      ),
                    ),

                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 🎁 Hộp quà phát sáng + animation mở nắp
                        AnimatedBuilder(
                          animation: _boxCtrl,
                          builder: (context, _) {
                            final openValue =
                            Curves.easeOut.transform(_boxCtrl.value);
                            final lidRotation = openValue * pi / 3; // mở nắp

                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                // Glow vòng tròn quanh hộp
                                Container(
                                  width: 130,
                                  height: 130,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        AppTheme.tpPurple
                                            .withOpacity(0.6 + t * 0.3),
                                        Colors.transparent,
                                      ],
                                      stops: const [0.4, 1],
                                    ),
                                  ),
                                ),

                                // Phần thân hộp
                                Image.asset(
                                  'assets/images/gift_box_bottom.png',
                                  height: 100,
                                  width: 120,
                                ),

                                // Nắp hộp xoay mở ra
                                Transform.translate(
                                  offset: Offset(0, -openValue * 60),
                                  child: Transform.rotate(
                                    angle: -lidRotation,
                                    alignment: Alignment.bottomCenter,
                                    child: Image.asset(
                                      'assets/images/gift_box_top.png',
                                      height: 60,
                                      width: 120,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        // 🌟 Tiêu đề shimmer
                        WonderKidsShimmerText(
                          text: widget.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // 💎 Nội dung phần thưởng
                        Text(
                          widget.rewardText,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.amberAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // 🔮 Icon phần thưởng
                        if (widget.icon != null)
                          WonderKidsGlowEffect(
                            radius: 60,
                            intensity: 0.6,
                            child: Image.asset(
                              widget.icon!,
                              height: 80,
                              width: 80,
                            ),
                          ),

                        const SizedBox(height: 30),

                        // 🔘 Nút Đóng
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
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
