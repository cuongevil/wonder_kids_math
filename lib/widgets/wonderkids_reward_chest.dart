import 'dart:math';
import 'dart:ui';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import '../themes/app_theme.dart';
import 'wonderkids_shimmer_text.dart';
import 'wonderkids_glow_effect.dart';

/// 🏆 WonderKidsRewardChest
/// Hiệu ứng rương vàng mở ra + ánh sáng bay lên kiểu TPBank Glow
/// Dùng khi bé nhận thưởng lớn, quà đặc biệt, hoặc huy hiệu mới.
class WonderKidsRewardChest extends StatefulWidget {
  final String title;
  final String rewardText;
  final String? rewardIcon;
  final VoidCallback onClose;

  const WonderKidsRewardChest({
    super.key,
    required this.title,
    required this.rewardText,
    required this.onClose,
    this.rewardIcon,
  });

  @override
  State<WonderKidsRewardChest> createState() => _WonderKidsRewardChestState();
}

class _WonderKidsRewardChestState extends State<WonderKidsRewardChest>
    with TickerProviderStateMixin {
  late ConfettiController _confettiCtrl;
  late AnimationController _chestCtrl;
  late AnimationController _glowCtrl;
  late AnimationController _lightCtrl;
  bool _opened = false;

  @override
  void initState() {
    super.initState();
    _confettiCtrl = ConfettiController(duration: const Duration(seconds: 4));
    _chestCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _lightCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    Future.delayed(const Duration(milliseconds: 500), _openChest);
  }

  void _openChest() {
    if (_opened) return;
    setState(() => _opened = true);
    _chestCtrl.forward();
    _lightCtrl.forward();
    _confettiCtrl.play();
  }

  @override
  void dispose() {
    _confettiCtrl.dispose();
    _chestCtrl.dispose();
    _glowCtrl.dispose();
    _lightCtrl.dispose();
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
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(color: Colors.black.withOpacity(0.35)),
          ),

          // 🎊 Confetti bay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiCtrl,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 30,
              maxBlastForce: 18,
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

          // 🪩 Popup chính
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
                // 🌈 Ánh sáng bay lên từ rương
                AnimatedBuilder(
                  animation: _lightCtrl,
                  builder: (context, _) {
                    final progress = Curves.easeOut.transform(_lightCtrl.value);
                    final opacity = (1 - progress).clamp(0.0, 1.0);
                    return Positioned(
                      top: 100 - progress * 80,
                      child: Opacity(
                        opacity: opacity,
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                AppTheme.tpPurple.withOpacity(0.5 + t * 0.3),
                                AppTheme.tpOrange.withOpacity(0.3),
                                Colors.transparent,
                              ],
                              stops: const [0.1, 0.5, 1],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // 🔓 Rương vàng mở nắp
                AnimatedBuilder(
                  animation: _chestCtrl,
                  builder: (context, _) {
                    final openValue =
                    Curves.easeOutCubic.transform(_chestCtrl.value);
                    final lidRotation = openValue * pi / 4;

                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        // 💫 Glow quanh rương
                        Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                AppTheme.tpPurple
                                    .withOpacity(0.6 + t * 0.3),
                                Colors.transparent,
                              ],
                              stops: const [0.5, 1.0],
                            ),
                          ),
                        ),

                        // 🧱 Thân rương
                        Image.asset(
                          'assets/images/chest_bottom.png',
                          width: 150,
                          height: 100,
                        ),

                        // 🔑 Nắp rương xoay mở lên
                        Transform.translate(
                          offset: Offset(0, -openValue * 60),
                          child: Transform.rotate(
                            angle: -lidRotation,
                            alignment: Alignment.bottomCenter,
                            child: Image.asset(
                              'assets/images/chest_top.png',
                              width: 150,
                              height: 80,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 20),

                // ✨ Tiêu đề shimmer
                WonderKidsShimmerText(
                  text: widget.title,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 10),

                // 🌟 Nội dung phần thưởng
                Text(
                  widget.rewardText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.amberAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 16),

                // 🎖 Ảnh quà / huy hiệu nếu có
                if (widget.rewardIcon != null)
                  WonderKidsGlowEffect(
                    radius: 60,
                    intensity: 0.6,
                    child: Image.asset(
                      widget.rewardIcon!,
                      height: 80,
                      width: 80,
                    ),
                  ),

                const SizedBox(height: 24),

                // 🔘 Nút đóng
                GestureDetector(
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
    );
  }
}
