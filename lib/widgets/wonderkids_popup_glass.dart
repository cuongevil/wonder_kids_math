import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../themes/app_theme.dart';
import 'wonderkids_shimmer_text.dart';
import 'wonderkids_shimmer_button.dart';
import 'wonderkids_glow_effect.dart';

/// 🌌 WonderKidsPopupGlass
/// Popup kiểu kính mờ – bo tròn – ánh sáng tím–cam động.
/// Dùng cho: chúc mừng, mở khóa, xác nhận, cảnh báo.
class WonderKidsPopupGlass extends StatefulWidget {
  final String title;
  final String message;
  final String? image;
  final String buttonLabel;
  final VoidCallback onPressed;

  const WonderKidsPopupGlass({
    super.key,
    required this.title,
    required this.message,
    required this.buttonLabel,
    required this.onPressed,
    this.image,
  });

  @override
  State<WonderKidsPopupGlass> createState() => _WonderKidsPopupGlassState();
}

class _WonderKidsPopupGlassState extends State<WonderKidsPopupGlass>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shineCtrl;

  @override
  void initState() {
    super.initState();
    _shineCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _shineCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.85;

    return AnimatedBuilder(
      animation: _shineCtrl,
      builder: (context, _) {
        final t = (sin(_shineCtrl.value * 2 * pi) * 0.5 + 0.5);
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
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(color: Colors.black.withOpacity(0.3)),
              ),

              // 🪩 Popup chính
              Container(
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
                  border: Border.all(
                    width: 2,
                    color: Colors.white.withOpacity(0.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.tpPurple.withOpacity(0.3),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // ✨ Viền sáng động tím–cam
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            width: 2.5,
                            color: Colors.transparent,
                          ),
                          gradient: borderGradient,
                        ),
                      ),
                    ),

                    // 💫 Nội dung popup
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.image != null) ...[
                          Image.asset(widget.image!,
                              height: 100, fit: BoxFit.contain),
                          const SizedBox(height: 12),
                        ],
                        WonderKidsShimmerText(
                          text: widget.title,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 🔮 Nút có glow
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
      },
    );
  }
}
