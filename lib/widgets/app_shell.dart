import 'dart:ui';
import 'package:flutter/material.dart';
import '../themes/app_theme.dart';
import '../widgets/animated_bottom_nav_bar.dart';
import '../screens/map_screen.dart';
import '../screens/leaderboard_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/setting_screen.dart';
import '../services/app_shell_controller.dart';

/// 💎 AppShell 2025 — hoạt động đúng với Global Controller
/// - Khi bấm tab → cập nhật controller toàn cục
/// - Khi đang ở LevelDetail → pop và hiển thị đúng tab mong muốn
class AppShell extends StatefulWidget {
  final Widget? child;

  const AppShell({super.key, this.child});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final controller = AppShellController.instance;

  final List<Widget> _screens = const [
    MapScreen(),
    LeaderboardScreen(),
    ProfileScreen(),
    SettingScreen(),
  ];

  @override
  void initState() {
    super.initState();
    controller.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    controller.removeListener(_onTabChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasChild = widget.child != null;
    final int currentIndex = controller.currentIndex;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        switchInCurve: Curves.easeInOutCubic,
        child: Stack(
          key: ValueKey<int>(currentIndex),
          children: [
            _screens[currentIndex],
            if (hasChild)
              IgnorePointer(
                ignoring: false,
                child: widget.child!,
              ),
          ],
        ),
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
                  AppTheme.tpOrange.withOpacity(0.9),
                ]
                    : [
                  AppTheme.tpPurple.withOpacity(0.9),
                  AppTheme.tpLightPurple,
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
              currentIndex: currentIndex,
              icons: const [
                Icons.map_rounded,
                Icons.leaderboard_rounded,
                Icons.person_rounded,
                Icons.settings_rounded,
              ],
              onTap: (index) {
                // 🔹 Cập nhật tab toàn cục
                controller.changeTab(index);

                // 🔹 Nếu đang ở màn con → pop ra
                if (hasChild && Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
