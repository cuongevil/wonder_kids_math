import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/level.dart';

class ProgressService {
  // ======================================================
  // ⭐ QUẢN LÝ SAO & TIẾN TRÌNH TRONG MỖI LEVEL
  // ======================================================

  /// 🔹 Lấy số sao đã học trong level
  static Future<int> getStars(String levelKey) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("stars_level_$levelKey") ?? 0;
  }

  /// 🔹 Lưu số sao mới cho level
  static Future<void> saveStars(String levelKey, int stars) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("stars_level_$levelKey", stars);
    await _updateGrandTotal();
  }

  /// 🔹 Lấy danh sách chỉ số bài đã học trong level (ví dụ các số đã xem)
  static Future<Set<int>> getLearnedIndexes(String levelKey) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("learnedIndexes_level_$levelKey")) {
      return Set<int>.from(
        jsonDecode(prefs.getString("learnedIndexes_level_$levelKey")!),
      );
    }
    return {};
  }

  /// 🔹 Lưu danh sách các chỉ số bài đã học
  static Future<void> saveLearnedIndexes(
      String levelKey, Set<int> indexes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      "learnedIndexes_level_$levelKey",
      jsonEncode(indexes.toList()),
    );
  }

  /// 🔹 Tổng số sao toàn hệ thống
  static Future<int> getGrandTotal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("totalStars") ?? 0;
  }

  /// 🔹 Cập nhật lại tổng sao toàn bộ
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

  /// 🔹 Reset 1 level riêng lẻ (xoá sao, chỉ số, cập nhật tổng)
  static Future<void> resetLevel(String levelKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("stars_level_$levelKey");
    await prefs.remove("learnedIndexes_level_$levelKey");
    await _updateGrandTotal();
  }

  /// 🔹 Reset toàn bộ dữ liệu (dành cho debug / nút "Bắt đầu lại")
  static Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where(
          (k) =>
      k.startsWith("stars_level_") ||
          k.startsWith("learnedIndexes_level_"),
    );
    for (var k in keys) {
      await prefs.remove(k);
    }
    await prefs.setInt("totalStars", 0);
    await prefs.remove("levels");
  }

  /// 🔹 Xoá sạch toàn bộ SharedPreferences (cực đoan hơn resetAll)
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ======================================================
  // 📘 QUẢN LÝ DANH SÁCH LEVEL
  // ======================================================

  /// 🔹 Lưu danh sách level vào local
  static Future<void> saveLevels(List<Level> levels) async {
    final prefs = await SharedPreferences.getInstance();
    final data = levels.map((e) => e.toJson()).toList();
    await prefs.setString("levels", jsonEncode(data));
  }

  /// 🔹 Load danh sách level từ local
  static Future<List<Level>> loadLevels() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey("levels")) return [];
    final jsonStr = prefs.getString("levels")!;
    final data = jsonDecode(jsonStr) as List;
    return data.map((e) => Level.fromJson(e)).toList();
  }

  /// 🔹 Reset về danh sách mặc định
  static Future<void> resetLevels(List<Level> defaultLevels) async {
    await saveLevels(defaultLevels);
  }

  /// 🔹 Đảm bảo luôn có danh sách level (dùng trong init MapScreen)
  static Future<List<Level>> ensureDefaultLevels(
      List<Level> Function() defaultBuilder) async {
    final loaded = await loadLevels();
    if (loaded.isNotEmpty) return loaded;

    final defaults = defaultBuilder();
    await saveLevels(defaults);
    return defaults;
  }

  // ======================================================
  // 🧩 TIỆN ÍCH THÊM
  // ======================================================

  /// 🔹 Cập nhật trạng thái level (hoàn thành / mở khoá tiếp theo)
  static Future<void> markLevelCompletedByIndex(
      List<Level> levels, int index) async {
    if (index < 0 || index >= levels.length) return;
    levels[index].state = LevelState.completed;
    if (index + 1 < levels.length &&
        levels[index + 1].state == LevelState.locked) {
      levels[index + 1].state = LevelState.playable;
    }
    await saveLevels(levels);
  }

  /// 🔹 Đánh dấu level hoàn thành theo levelKey
  static Future<void> markLevelCompleted(String levelKey) async {
    final levels = await ensureDefaultLevels(() => []);
    final index = levels.indexWhere((e) => e.levelKey == levelKey);
    if (index != -1) {
      levels[index].state = LevelState.completed;
      if (index + 1 < levels.length &&
          levels[index + 1].state == LevelState.locked) {
        levels[index + 1].state = LevelState.playable;
      }
      await saveLevels(levels);
    }
  }

  /// 🔹 Kiểm tra xem tất cả các level có ít nhất 1 playable chưa
  static Future<bool> hasPlayableLevel() async {
    final levels = await loadLevels();
    return levels.any((e) => e.state == LevelState.playable);
  }

  /// 🔹 Reset trạng thái 1 level (debug)
  static Future<void> resetLevelState(String levelKey) async {
    final levels = await loadLevels();
    final index = levels.indexWhere((e) => e.levelKey == levelKey);
    if (index != -1) {
      levels[index].state = LevelState.playable;
      await saveLevels(levels);
    }
  }
}
