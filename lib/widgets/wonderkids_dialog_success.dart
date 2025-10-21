import 'dart:math';
import 'dart:ui';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import '../themes/app_theme.dart';
import 'wonderkids_glow_effect.dart';
import 'wonderkids_shimmer_button.dart';
import 'wonderkids_shimmer_text.dart';

/// 🏆 WonderKidsDialogSuccess
/// Popup “Chúc mừng” có confetti bay, emoji động, ánh sáng tím–cam phản chiếu.
class WonderKidsDialogSuccess extends StatefulWidget {
  final String title;
  final String message;
  final String? emoji;
  final String buttonLabel;
  final VoidCallback onPressed;

  const WonderKidsDialogSuccess({
    super.key,
    required this.title,
    required this.message,
    required this.buttonLabel,
    required this.onPressed,
    this.emoji,
  });

  @override
  State<WonderKidsDialogSuccess> createState() =>
      _WonderKidsDialogSuccessState();
}

class _WonderKidsDialogSuccessState extends State<WonderKidsDialogSuccess>
    with TickerProviderStateMixin {
  late ConfettiController _confettiCtrl;
  late AnimationController _emojiCtrl;
  late AnimationController _glowCtrl;

  @override
  void initState() {
    super.initState();
    _confettiCtrl = ConfettiController(duration: const Duration(seconds: 3))
      ..play();
    _emojiCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _confettiCtrl.dispose();
    _emojiCtrl.dispose();
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

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 🌫 Mờ nền
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

                // 💫 Nội dung popup
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 😍 Emoji động
                    if (widget.emoji != null)
                      ScaleTransition(
                        scale: Tween(begin: 0.9, end: 1.1).animate(
                          CurvedAnimation(
                            parent: _emojiCtrl,
                            curve: Curves.easeInOut,
                          ),
                        ),
                        child: Text(
                          widget.emoji!,
                          style: const TextStyle(fontSize: 72),
                        ),
                      ),

                    // 🏆 Tiêu đề shimmer
                    WonderKidsShimmerText(
                      text: widget.title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 🌟 Nội dung
                    Text(
                      widget.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // 🔮 Nút CTA
                    WonderKidsGlowEffect(
                      radius: 70,
                      intensity: 0.6,
                      child: WonderKidsShimmerButton(
                        label: widget.buttonLabel,
                        onPressed: widget.onPressed,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
