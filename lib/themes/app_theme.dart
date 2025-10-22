import 'package:flutter/material.dart';
import 'dart:ui';

/// 🎨 TPBank Fintech Theme — Light / Dark Mode (2025 Edition)
class AppTheme {
  // 🔹 Màu chuẩn TPBank
  static const Color tpPurple = Color(0xFF5E2CED);
  static const Color tpOrange = Color(0xFFFF8B00);
  static const Color tpLightPurple = Color(0xFFA58CFF);
  static const Color tpDarkBg = Color(0xFF1E1E2E);

  /// 💡 Theme sáng — tone tím–cam, sang trọng, tinh tế
  static final ThemeData light = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF9F8FF),
    fontFamily: 'Inter',
    useMaterial3: true,

    colorScheme: const ColorScheme.light(
      primary: tpPurple,
      secondary: tpOrange,
      surface: Colors.white,
      background: Color(0xFFF3F2FA),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Color(0xFF1E1E2E),
      onBackground: Color(0xFF1E1E2E),
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white.withOpacity(0.05),
      elevation: 0,
      centerTitle: true,
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1E1E2E),
      ),
      iconTheme: const IconThemeData(color: tpPurple),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: tpPurple,
      foregroundColor: Colors.white,
    ),

    // ✅ Đổi sang CardThemeData
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      shadowColor: tpPurple.withOpacity(0.15),
    ),

    textTheme: const TextTheme(
      headlineLarge:
      TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E1E2E)),
      headlineMedium:
      TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF1E1E2E)),
      bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF3A3A4F)),
      bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF6E6E80)),
      labelLarge:
      TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: tpPurple),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withOpacity(0.9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      hintStyle: TextStyle(color: Colors.grey[500]),
    ),

    splashFactory: InkRipple.splashFactory,
  );

  /// 🌙 Theme tối — tone tím ánh neon, cảm giác fintech premium
  static final ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: tpDarkBg,
    fontFamily: 'Inter',
    useMaterial3: true,

    colorScheme: const ColorScheme.dark(
      primary: tpPurple,
      secondary: tpOrange,
      surface: Color(0xFF252540),
      background: tpDarkBg,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      onBackground: Colors.white,
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white.withOpacity(0.05),
      elevation: 0,
      centerTitle: true,
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: tpPurple,
      foregroundColor: Colors.white,
    ),

    // ✅ Đổi sang CardThemeData
    cardTheme: CardThemeData(
      color: const Color(0xFF252540).withOpacity(0.8),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      shadowColor: tpPurple.withOpacity(0.25),
    ),

    textTheme: const TextTheme(
      headlineLarge:
      TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
      headlineMedium:
      TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
      bodyLarge: TextStyle(fontSize: 16, color: Color(0xFFCCCCE5)),
      bodyMedium: TextStyle(fontSize: 14, color: Color(0xFFAAAACC)),
      labelLarge:
      TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: tpOrange),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2B2B45).withOpacity(0.8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      hintStyle: TextStyle(color: Colors.grey[400]),
    ),

    splashFactory: InkRipple.splashFactory,
  );

  /// 🌈 Gradient tím–cam chủ đạo
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [tpPurple, tpOrange],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// ✨ Hiệu ứng AppBar mờ chuẩn TPBank
  static Widget buildGlassAppBar({required Widget child}) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          color: Colors.white.withOpacity(0.05),
          child: child,
        ),
      ),
    );
  }
}
