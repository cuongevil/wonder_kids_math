import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wonderkids.math/themes/app_theme.dart';

/// 🌈 GradientButton — Chuẩn TPBank Fintech 2025
/// - Gradient tím–cam
/// - Ripple & glow nhẹ
/// - Haptic feedback khi nhấn
class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final double height;
  final double borderRadius;
  final bool isLoading;
  final bool enabled;
  final EdgeInsetsGeometry padding;
  final double fontSize;
  final FontWeight fontWeight;

  const GradientButton({
    super.key,
    required this.label,
    this.onTap,
    this.height = 56,
    this.borderRadius = 20,
    this.isLoading = false,
    this.enabled = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 24),
    this.fontSize = 16,
    this.fontWeight = FontWeight.bold,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: enabled ? 1.0 : 0.6,
      child: GestureDetector(
        onTap: enabled && !isLoading
            ? () {
          HapticFeedback.lightImpact();
          onTap?.call();
        }
            : null,
        child: Container(
          height: height,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: padding,
          decoration: BoxDecoration(
            gradient: enabled
                ? AppTheme.primaryGradient
                : LinearGradient(
              colors: [
                Colors.grey.withOpacity(0.3),
                Colors.grey.withOpacity(0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: enabled
                ? [
              BoxShadow(
                color: const Color(0xFF5E2CED).withOpacity(0.4),
                blurRadius: 25,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: const Color(0xFFFF8B00).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 3),
              ),
            ]
                : [],
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            )
                : Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: Colors.white,
                letterSpacing: 0.5,
                shadows: [
                  Shadow(
                    color: isDark
                        ? Colors.black.withOpacity(0.4)
                        : Colors.white.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
