import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:wonderkids.math/screens/badge_collection_screen.dart';
import 'package:wonderkids.math/screens/game_addition100.dart';
import 'package:wonderkids.math/screens/game_addition50.dart';
import 'package:wonderkids.math/screens/game_subtraction100.dart';
import 'package:wonderkids.math/screens/game_subtraction50.dart';
import 'package:wonderkids.math/screens/leaderboard_screen.dart';
import 'package:wonderkids.math/screens/learn_numbers_100.dart';
import 'package:wonderkids.math/screens/learn_numbers_50.dart';
import 'package:wonderkids.math/screens/profile_screen.dart';
import 'package:wonderkids.math/screens/game_addition10.dart';
import 'package:wonderkids.math/screens/game_addition20.dart';
import 'package:wonderkids.math/screens/game_compare.dart';
import 'package:wonderkids.math/screens/game_final_boss.dart';
import 'package:wonderkids.math/screens/game_measure_time.dart';
import 'package:wonderkids.math/screens/game_shapes.dart';
import 'package:wonderkids.math/screens/game_subtraction10.dart';
import 'package:wonderkids.math/screens/game_subtraction20.dart';
import 'package:wonderkids.math/screens/learn_numbers.dart';
import 'package:wonderkids.math/screens/learn_numbers_20.dart';
import 'package:wonderkids.math/screens/level_detail.dart';
import 'package:wonderkids.math/screens/map_screen.dart';
import 'package:wonderkids.math/themes/app_theme.dart';
import 'package:wonderkids.math/utils/route_observer.dart';
import 'package:wonderkids.math/utils/custom_page_route.dart';
import 'package:wonderkids.math/widgets/animated_bottom_nav_bar.dart';

void main() {
  runApp(const WonderKidsMathApp());
}

/// 🌈 Wonder Kids Math — TPBank Fintech Style 2025
/// - Gradient tím–cam mượt
/// - AppBar mờ glass
/// - Hiệu ứng fade khi chuyển cảnh
/// - BottomNav icon scale animation + auto hide khi scroll map
class WonderKidsMathApp extends StatefulWidget {
  const WonderKidsMathApp({super.key});

  @override
  State<WonderKidsMathApp> createState() => _WonderKidsMathAppState();
}

class _WonderKidsMathAppState extends State<WonderKidsMathApp> {
  int _currentIndex = 0;
  final GlobalKey<AnimatedBottomNavBarState> _bottomNavKey =
  GlobalKey<AnimatedBottomNavBarState>();

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      // 👇 MapScreen gửi callback ẩn/hiện bar
      MapScreen(
        onScrollDirectionChanged: (isHidden) {
          if (isHidden) {
            _bottomNavKey.currentState?.hide();
          } else {
            _bottomNavKey.currentState?.show();
          }
        },
      ),
      const LeaderboardScreen(),
      const ProfileScreen(),
    ];

    return MaterialApp(
      title: 'Wonder Kids Vui Học Toán',
      debugShowCheckedModeBanner: false,
      navigatorObservers: [appRouteObserver],
      theme: AppTheme.light, // 🌞 Tone sáng
      darkTheme: AppTheme.dark, // 🌙 Tone tối fintech
      themeMode: ThemeMode.system, // Tự đổi theo hệ thống

      // 🌀 Custom fade route transition
      onGenerateRoute: (settings) {
        final routes = {
          LevelDetail.routeName: (_) => const LevelDetail(),
          '/badges': (_) => const BadgeCollectionScreen(),
          '/learn_numbers': (_) => const LearnNumbersScreen(),
          '/learn_numbers_20': (_) => const LearnNumbers20Screen(),
          '/learn_numbers_50': (_) => const LearnNumbers50Screen(),
          '/learn_numbers_100': (_) => const LearnNumbers100Screen(),
          '/game_compare': (_) => const GameCompareScreen(),
          '/game_addition10': (_) => const GameAddition10Screen(),
          '/game_subtraction10': (_) => const GameSubtraction10Screen(),
          '/game_addition20': (_) => const GameAddition20Screen(),
          '/game_subtraction20': (_) => const GameSubtraction20Screen(),
          '/game_addition50': (_) => const GameAddition50Screen(),
          '/game_subtraction50': (_) => const GameSubtraction50Screen(),
          '/game_addition100': (_) => const GameAddition100Screen(),
          '/game_subtraction100': (_) => const GameSubtraction100Screen(),
          '/game_shapes': (_) => const GameShapesScreen(),
          '/game_measure_time': (_) => const GameMeasureTimeScreen(),
          '/game_final_boss': (_) => const GameFinalBossScreen(),
        };

        final builder = routes[settings.name];
        if (builder != null) {
          return CustomPageRoute(child: builder(context));
        }
        return null;
      },

      // 🌟 Layout chính có BottomNav glass + animation scale
      home: Scaffold(
        extendBody: true,
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: screens[_currentIndex],
        ),

        // 🔹 Bottom Navigation Bar — glass blur + auto hide
        bottomNavigationBar: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: AnimatedBottomNavBar(
              key: _bottomNavKey,
              currentIndex: _currentIndex,
              onTap: (i) => setState(() => _currentIndex = i),
              icons: const [
                Icons.map_rounded,
                Icons.leaderboard_rounded,
                Icons.person_rounded,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
