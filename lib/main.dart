import 'package:flutter/material.dart';
import 'package:wonder_kids_math/screens/badge_collection_screen.dart';
import 'package:wonder_kids_math/screens/leaderboard_screen.dart';
import 'package:wonder_kids_math/screens/learn_numbers_100.dart';
import 'package:wonder_kids_math/screens/learn_numbers_50.dart';
import 'package:wonder_kids_math/screens/profile_screen.dart';

import 'screens/game_addition10.dart';
import 'screens/game_addition20.dart';
import 'screens/game_compare.dart';
import 'screens/game_final_boss.dart';
import 'screens/game_measure_time.dart';
import 'screens/game_shapes.dart';
import 'screens/game_subtraction10.dart';
import 'screens/game_subtraction20.dart';
import 'screens/learn_numbers.dart';
import 'screens/learn_numbers_20.dart';
import 'screens/level_detail.dart';
import 'screens/map_screen.dart';

void main() => runApp(const WonderKidsMathApp());

class WonderKidsMathApp extends StatelessWidget {
  const WonderKidsMathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wonder Kids Math',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepPurple),
      initialRoute: '/',
      routes: {
        '/': (_) => const MapScreen(),
        LevelDetail.routeName: (_) => const LevelDetail(),
        '/profile': (_) => const ProfileScreen(),
        '/leaderboard': (_) => const LeaderboardScreen(),
        '/badges': (_) => const BadgeCollectionScreen(),
        '/learn_numbers': (_) => const LearnNumbersScreen(),
        '/learn_numbers_20': (_) => const LearnNumbers20Screen(),
        '/learn_numbers_50': (_) => const LearnNumbers50Screen(),
        '/learn_numbers_100': (_) => const LearnNumbers100Screen(),
        '/game_addition10': (_) => const GameAddition10Screen(),
        '/game_subtraction10': (_) => const GameSubtraction10Screen(),
        '/game_compare': (_) => const GameCompareScreen(),
        '/game_addition20': (_) => const GameAddition20Screen(),
        '/game_subtraction20': (_) => const GameSubtraction20Screen(),
        '/game_shapes': (_) => const GameShapesScreen(),
        '/game_measure_time': (_) => const GameMeasureTimeScreen(),
        '/game_final_boss': (_) => const GameFinalBossScreen(),
      },
    );
  }
}
