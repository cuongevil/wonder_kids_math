import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/level.dart';

class ProgressService {
  // --------------------------
  // ⭐ Progress theo levelKey
  // --------------------------

  static Future<int> getStars(String levelKey) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("stars_level_$levelKey") ?? 0;
  }

  static Future<void> saveStars(String levelKey, int stars) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("stars_level_$levelKey", stars);
    await _updateGrandTotal();
  }

  static Future<Set<int>> getLearnedIndexes(String levelKey) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("learnedIndexes_level_$levelKey")) {
      return Set<int>.from(
          jsonDecode(prefs.getString("learnedIndexes_level_$levelKey")!));
    }
    return {};
  }

  static Future<void> saveLearnedIndexes(
      String levelKey, Set<int> indexes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        "learnedIndexes_level_$levelKey", jsonEncode(indexes.toList()));
  }

  static Future<int> getGrandTotal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("totalStars") ?? 0;
  }

  static Future<void> _updateGrandTotal() async {
    final prefs = await SharedPreferences.getInstance();
    int grandTotal = 0;
    for (var key in prefs.getKeys()) {
      if (key.startsWith("stars_level_")) {
        grandTotal += prefs.getInt(key) ?? 0;
      }
    }
    await prefs.setInt("totalStars", grandTotal);
  }

  static Future<void> resetLevel(String levelKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("stars_level_$levelKey");
    await prefs.remove("learnedIndexes_level_$levelKey");
    await _updateGrandTotal();
  }

  static Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) =>
    k.startsWith("stars_level_") || k.startsWith("learnedIndexes_level_"));
    for (var k in keys) {
      await prefs.remove(k);
    }
    await prefs.setInt("totalStars", 0);
    await prefs.remove("levels");
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // --------------------------
  // 📌 Quản lý danh sách Level
  // --------------------------

  static Future<void> saveLevels(List<Level> levels) async {
    final prefs = await SharedPreferences.getInstance();
    final data = levels.map((e) => e.toJson()).toList();
    await prefs.setString("levels", jsonEncode(data));
  }

  static Future<List<Level>> loadLevels() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey("levels")) return [];
    final jsonStr = prefs.getString("levels")!;
    final data = jsonDecode(jsonStr) as List;
    return data.map((e) => Level.fromJson(e)).toList();
  }

  static Future<void> resetLevels(List<Level> defaultLevels) async {
    await saveLevels(defaultLevels);
  }

  /// 🔹 Tiện ích: luôn đảm bảo có dữ liệu levels
  static Future<List<Level>> ensureDefaultLevels(
      List<Level> Function() defaultBuilder) async {
    final loaded = await loadLevels();
    if (loaded.isNotEmpty) return loaded;

    final defaults = defaultBuilder();
    await saveLevels(defaults);
    return defaults;
  }
}
