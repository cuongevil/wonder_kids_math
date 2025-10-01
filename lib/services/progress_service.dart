import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/level.dart';

class ProgressService {
  static const String _levelsKey = "levels";

  // Lưu danh sách level
  static Future<void> saveLevels(List<Level> levels) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = jsonEncode(levels.map((e) => e.toJson()).toList());
    await prefs.setString(_levelsKey, jsonData);
  }

  // Load danh sách level
  static Future<List<Level>?> loadLevels() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = prefs.getString(_levelsKey);
    if (jsonData == null) return null;
    final List<dynamic> decoded = jsonDecode(jsonData);
    return decoded.map((e) => Level.fromJson(e)).toList();
  }

  // 🔹 Hàm reset về mặc định
  static Future<void> resetLevels(List<Level> defaults) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = jsonEncode(defaults.map((e) => e.toJson()).toList());
    await prefs.setString(_levelsKey, jsonData);
  }

  // 🔹 Hàm xóa cache (nếu muốn clear hẳn)
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_levelsKey);
  }
}
