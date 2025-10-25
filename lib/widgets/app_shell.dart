import 'dart:ui';
import 'package:flutter/material.dart';
import '../themes/app_theme.dart';
import '../widgets/animated_bottom_nav_bar.dart';
import '../screens/map_screen.dart';
import '../screens/leaderboard_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/setting_screen.dart';

/// 💎 AppShell 2025 — khung giao diện chính fintech, có thể dùng cho cả màn con
class AppShell extends StatefulWidget {
  final Widget? child; // ✅ cho phép hiển thị màn phụ bên trong (LevelDetail)
  final int initialIndex;

  const AppShell({super.key, this.child, this.initialIndex = 0});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    MapScreen(),
    LeaderboardScreen(),
    ProfileScreen(),
    SettingScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // ✅ Nếu có child → hiển thị nội dung màn con, vẫn nằm trong AppShell
    final screen = widget.child ?? _screens[_currentIndex];

    return Scaffold(
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        switchInCurve: Curves.easeInOutCubic,
        child: screen,
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                  AppTheme.tpPurple.withOpacity(0.95),
                  AppTheme.tpOrange.withOpacity(0.9)
                ]
                    : [
                  AppTheme.tpPurple.withOpacity(0.9),
                  AppTheme.tpLightPurple
                ],
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: AnimatedBottomNavBar(
              currentIndex: _currentIndex,
              onTap: (i) => setState(() => _currentIndex = i),
              icons: const [
                Icons.map_rounded,
                Icons.leaderboard_rounded,
                Icons.person_rounded,
                Icons.settings_rounded,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
