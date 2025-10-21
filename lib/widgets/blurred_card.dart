import 'dart:ui';
import 'package:flutter/material.dart';

class BlurredCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final Gradient? borderGradient;
  final VoidCallback? onTap;

  const BlurredCard({
    super.key,
    required this.child,
    this.padding,
    this.radius = 20,
    this.borderGradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final border = borderGradient != null
        ? BoxDecoration(
      gradient: borderGradient,
      borderRadius: BorderRadius.circular(radius),
    )
        : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: border,
        padding: border != null ? const EdgeInsets.all(1.5) : EdgeInsets.zero,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: padding ?? const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(radius),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
