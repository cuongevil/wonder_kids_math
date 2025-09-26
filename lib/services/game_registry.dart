import 'package:flutter/material.dart';
import '../config/app_routes.dart';
import '../models/game_info.dart';
import 'progress_service.dart';

class GameRegistry {
  static final List<GameInfo> _games = [
    GameInfo(
      id: "game1",
      title: "Tìm chữ",
      icon: Icons.search,
      color: Colors.pink,
      route: AppRoutes.gameFind,
      total: 10,
    ),
    GameInfo(
      id: "game2",
      title: "Ghép chữ",
      icon: Icons.image,
      color: Colors.teal,
      route: AppRoutes.gameMatch,
      total: 8,
    ),
    GameInfo(
      id: "game3",
      title: "Điền chữ",
      icon: Icons.edit,
      color: Colors.blue,
      route: AppRoutes.gameFill,
      total: 12,
    ),
    GameInfo(
      id: "game4",
      title: "Nghe và Chọn",
      icon: Icons.volume_up,
      color: Colors.orange,
      route: AppRoutes.gameListen,
      total: 15,
    ),
  ];

  static List<GameInfo> getGames() => _games;

  static Future<String?> getProgress(GameInfo game) async {
    final data = await ProgressService.loadProgress(game.id);
    final score = data['score'] ?? 0;
    final total = data['total'] ?? game.total;
    if (total > 0) return "⭐ $score/$total";
    return null;
  }

  static Future<void> resetAllProgress() async {
    for (final g in _games) {
      await ProgressService.saveProgress(g.id, 0, g.total);
    }
  }
}
