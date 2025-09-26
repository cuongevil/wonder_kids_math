import 'package:flutter/material.dart';

import '../models/vn_letter.dart';
import '../screens/flashcard_screen.dart';
import '../screens/game_fill.dart';
import '../screens/game_find.dart';
import '../screens/game_listen.dart';
import '../screens/game_match.dart';
import '../screens/home_screen.dart';
import '../screens/letter_screen.dart';
import '../screens/start_screen.dart';
import '../screens/write_screen.dart';

class AppRoutes {
  static const String start = '/';
  static const String home = '/home';
  static const String flashcard = '/flashcard';
  static const String letter = '/letter';
  static const String write = '/write';
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

      case home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );

      case flashcard:
        return MaterialPageRoute(
          builder: (_) => const FlashcardScreen(),
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

      case letter:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        final letters = args['letters'] as List<VnLetter>? ?? [];
        final index = args['currentIndex'] as int? ?? 0;

        if (letters.isEmpty) {
          return _errorRoute("Không có dữ liệu chữ để hiển thị");
        }

        return MaterialPageRoute(
          builder: (_) => LetterScreen(
            letters: letters,
            currentIndex: index,
          ),
          settings: settings,
        );

      case write:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        final letters = args['letters'] as List<VnLetter>? ?? [];
        final index = args['startIndex'] as int? ?? 0;

        if (letters.isEmpty) {
          return _errorRoute("Không có dữ liệu chữ để luyện viết");
        }

        return MaterialPageRoute(
          builder: (_) => WriteScreen(
            letters: letters,
            startIndex: index,
          ),
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
