import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/app_routes.dart';
import '../models/learning_info.dart';
import '../models/vn_letter.dart';
import 'progress_service.dart';

class LearningRegistry {
  static final List<LearningInfo> _learnings = [
    LearningInfo(
      id: "learn1",
      title: "Chữ cái",
      icon: Icons.sort_by_alpha,
      gradient: [Colors.orange, Colors.yellow],
      route: AppRoutes.home,
      total: 29,
    ),
    LearningInfo(
      id: "learn2",
      title: "Thẻ chữ",
      icon: Icons.style,
      gradient: [Colors.blue, Colors.purple],
      route: AppRoutes.flashcard,
      total: 29,
    ),
    LearningInfo(
      id: "learn3",
      title: "Tập viết",
      icon: Icons.edit,
      gradient: [Colors.green, Colors.lightGreen],
      route: AppRoutes.write,
      total: 29,
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

  /// 🔹 Load toàn bộ chữ cái từ JSON (assets/config/letters.json)
  static Future<List<VnLetter>> loadLetters() async {
    final raw = await rootBundle.loadString('assets/config/letters.json');
    final List<dynamic> data = jsonDecode(raw);
    return data.map((e) => VnLetter.fromJson(e)).toList();
  }
}
