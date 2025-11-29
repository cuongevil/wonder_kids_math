import 'dart:ui';
import 'package:flutter/material.dart';
import '../themes/app_theme.dart';
import '../widgets/animated_bottom_nav_bar.dart';
import '../screens/map_screen.dart';
import '../screens/leaderboard_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/setting_screen.dart';
import '../services/app_shell_controller.dart';

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
    final padding = MediaQuery.of(context).padding;
    final hasChild = widget.child != null;
    final currentIndex = controller.currentIndex;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,

      // ⭐ SAFE AREA CHUẨN FINTECH 2025
      body: SafeArea(
        top: true,
        bottom: false,
        minimum: EdgeInsets.only(top: padding.top + 12),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          switchInCurve: Curves.easeInOutCubic,
          child: Stack(
            key: ValueKey<int>(currentIndex),
            children: [
              // ⭐ Màn chính theo tab
              Positioned.fill(
                child: _screens[currentIndex],
              ),

              // ⭐ Màn con (LevelDetail...) dạng overlay fintech
              if (hasChild)
                IgnorePointer(
                  ignoring: false,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Container(
                      color: Colors.black.withOpacity(0.15),
                      child: widget.child!,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),

      // ⭐ Bottom Nav fintech đẹp + nâng khỏi gesture bar
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: padding.bottom > 0 ? padding.bottom : 12),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              height: 82,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                    AppTheme.tpPurple.withOpacity(0.93),
                    AppTheme.tpOrange.withOpacity(0.88),
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
                  controller.changeTab(index);

                  // Nếu đang ở màn con → pop ra
                  if (hasChild && Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
