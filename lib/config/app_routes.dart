import 'package:flutter/material.dart';
import 'package:wonder_kids_math/screens/learn_numbers.dart';

import '../screens/addition_screen.dart';
import '../screens/division_screen.dart';
import '../screens/game_fill.dart';
import '../screens/game_find.dart';
import '../screens/game_listen.dart';
import '../screens/game_match.dart';
import '../screens/multiplication_screen.dart';
import '../screens/start_screen.dart';
import '../screens/subtraction_screen.dart';

class AppRoutes {
  static const String start = '/';

  // 📚 Học Toán
  static const String numbers = "/numbers";
  static const String addition = "/addition";
  static const String subtraction = "/subtraction";
  static const String multiplication = "/multiplication";
  static const String division = "/division";

  // 🎮 Trò chơi
  static const String gameFind = '/game_find';
  static const String gameMatch = '/game_match';
  static const String gameFill = '/game_fill';
  static const String gameListen = '/game_listen';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case start:
        return MaterialPageRoute(
          builder: (_) => const StartScreen(),
          settings: settings,
        );

      case numbers:
        return MaterialPageRoute(
          builder: (_) => const LearnNumbersScreen(),
          settings: settings,
        );

      case addition:
        return MaterialPageRoute(
          builder: (_) => const AdditionScreen(),
          settings: settings,
        );

      case subtraction:
        return MaterialPageRoute(
          builder: (_) => const SubtractionScreen(),
          settings: settings,
        );

      case multiplication:
        return MaterialPageRoute(
          builder: (_) => const MultiplicationScreen(),
          settings: settings,
        );

      case division:
        return MaterialPageRoute(
          builder: (_) => const DivisionScreen(),
          settings: settings,
        );

      case gameFind:
        return MaterialPageRoute(
          builder: (_) => const GameFind(),
          settings: settings,
        );

      case gameMatch:
        return MaterialPageRoute(
          builder: (_) => const GameMatch(),
          settings: settings,
        );

      case gameFill:
        return MaterialPageRoute(
          builder: (_) => const GameFill(),
          settings: settings,
        );

      case gameListen:
        return MaterialPageRoute(
          builder: (_) => const GameListen(),
          settings: settings,
        );

      default:
        return _errorRoute("Route không tồn tại");
    }
  }

  static MaterialPageRoute _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        body: Center(
          child: Text(
            message,
            style: const TextStyle(fontSize: 18, color: Colors.red),
          ),
        ),
      ),
    );
  }
}
