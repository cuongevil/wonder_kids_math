import 'package:flutter/material.dart';

import '../themes/app_theme.dart';

/// ✨ WonderKidsShimmerButton
/// Nút gradient tím–cam có ánh sáng shimmer lướt qua (hiệu ứng kiểu TPBank)
class WonderKidsShimmerButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool loading;
  final double height;
  final double borderRadius;

  const WonderKidsShimmerButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.height = 56,
    this.borderRadius = 18,
  });

  @override
  State<WonderKidsShimmerButton> createState() =>
      _WonderKidsShimmerButtonState();
}

class _WonderKidsShimmerButtonState extends State<WonderKidsShimmerButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerCtrl;

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseGradient = const LinearGradient(
      colors: [AppTheme.tpPurple, AppTheme.tpOrange],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return GestureDetector(
      onTap: widget.loading ? null : widget.onPressed,
      child: AnimatedBuilder(
        animation: _shimmerCtrl,
        builder: (context, _) {
          final shimmerValue = _shimmerCtrl.value;
          final shimmerStart = shimmerValue - 0.3;
          final shimmerEnd = shimmerValue + 0.3;

          final shimmerGradient = LinearGradient(
            colors: [
              Colors.white.withOpacity(0.0),
              Colors.white.withOpacity(0.4),
              Colors.white.withOpacity(0.0),
            ],
            stops: const [0.0, 0.5, 1.0],
            begin: Alignment(-1.0 + shimmerValue * 2, 0),
            end: Alignment(1.0 + shimmerValue * 2, 0),
          );

          return Container(
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              gradient: baseGradient,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.tpPurple.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // ✨ Lớp shimmer sáng lướt qua
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    gradient: shimmerGradient,
                    backgroundBlendMode: BlendMode.plus,
                  ),
                ),

                // 💫 Nội dung nút
                Center(
                  child: widget.loading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.icon != null)
                              Icon(widget.icon, color: Colors.white, size: 22),
                            if (widget.icon != null) const SizedBox(width: 8),
                            Text(
                              widget.label,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.6,
                                shadows: [
                                  Shadow(
                                    color: Colors.black26,
                                    blurRadius: 3,
                                    offset: Offset(1, 1),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),

                // 🌈 Glow tím mờ lan tỏa
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.tpPurple.withOpacity(0.4),
                          blurRadius: 25,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
