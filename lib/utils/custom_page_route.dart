import 'package:flutter/material.dart';

/// 🌀 Custom fade transition route (với tham số settings tuỳ chọn)
class CustomPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;

  CustomPageRoute({
    required this.child,
    RouteSettings? settings, // ✅ thêm dòng này
  }) : super(
    settings: settings,
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (context, animation, secondaryAnimation) => child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        ),
        child: child,
      );
    },
  );
}
