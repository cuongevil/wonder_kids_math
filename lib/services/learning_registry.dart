import 'package:flutter/material.dart';
import '../config/app_routes.dart';
import '../models/learning_info.dart';
import 'progress_service.dart';

class LearningRegistry {
  static final List<LearningInfo> _learnings = [
    // 🔢 Số đếm
    LearningInfo(
      id: "num1",
      title: "Số đếm 1-100",
      icon: Icons.numbers,
      gradient: [Colors.teal, Colors.cyan],
      route: AppRoutes.numbers,
      total: 100,
      group: "counting",
    ),

    // ➕ Cộng
    LearningInfo(
      id: "num2",
      title: "Cộng",
      icon: Icons.add_circle,
      gradient: [Colors.pinkAccent, Colors.redAccent],
      route: AppRoutes.addition,
      total: 50,
      group: "operation",
    ),

    // ➖ Trừ
    LearningInfo(
      id: "num3",
      title: "Trừ",
      icon: Icons.remove_circle,
      gradient: [Colors.indigo, Colors.deepPurpleAccent],
      route: AppRoutes.subtraction,
      total: 50,
      group: "operation",
    ),

    // ✖️ Nhân
    LearningInfo(
      id: "num4",
      title: "Nhân",
      icon: Icons.clear,
      gradient: [Colors.green, Colors.lightGreenAccent],
      route: AppRoutes.multiplication,
      total: 81,
      group: "operation",
    ),

    // ➗ Chia
    LearningInfo(
      id: "num5",
      title: "Chia",
      icon: Icons.percent,
      gradient: [Colors.blueAccent, Colors.lightBlue],
      route: AppRoutes.division,
      total: 81,
      group: "operation",
    ),
  ];

  static List<LearningInfo> getLearnings() => _learnings;

  static Future<String?> getProgress(LearningInfo learning) async {
    final data = await ProgressService.loadProgress(learning.id);
    final score = data['score'] ?? 0;
    final total = data['total'] ?? learning.total;
    if (total > 0) return "⭐ $score/$total";
    return null;
  }

  static Future<void> resetAllProgress() async {
    for (final l in _learnings) {
      await ProgressService.saveProgress(l.id, 0, l.total);
    }
  }
}
