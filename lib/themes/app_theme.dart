import 'package:flutter/material.dart';

class AppTheme {
  static const Color tpPurple = Color(0xFF5E2CED);
  static const Color tpOrange = Color(0xFFFF8B00);
  static const Color tpDark = Color(0xFF1E1E2E);
  static const Color tpText = Colors.white;

  static final Gradient primaryGradient = const LinearGradient(
    colors: [tpPurple, tpOrange],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: 'Poppins',
    colorScheme: ColorScheme.fromSeed(
      seedColor: tpPurple,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: const Color(0xFFF8F8FF),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: tpPurple,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: tpPurple,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        backgroundColor: tpPurple,
        foregroundColor: Colors.white,
      ),
    ),
  );

  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Poppins',
    colorScheme: ColorScheme.fromSeed(
      seedColor: tpPurple,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: tpDark,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
  );
}
