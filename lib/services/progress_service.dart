import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/level.dart';

class ProgressService {
  static const _kOrientationKey = 'map_orientation';
  static const _kLevelsKey = 'levels_v1';

  /// Lưu orientation của map (vertical / horizontal)
  static Future<void> saveOrientation(bool isVertical) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kOrientationKey, isVertical ? 'vertical' : 'horizontal');
  }

  /// Load orientation map
  static Future<bool> loadOrientation() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString(_kOrientationKey);
    if (v == null) return true; // mặc định vertical
    return v == 'vertical';
  }

  /// Lưu danh sách level (tiến độ)
  static Future<void> saveLevels(List<Level> levels) async {
    final prefs = await SharedPreferences.getInstance();
    final data = levels.map((e) => e.toJson()).toList();
    await prefs.setString(_kLevelsKey, jsonEncode(data));
  }

  /// Load danh sách level
  static Future<List<Level>?> loadLevels() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_kLevelsKey);
    if (s == null) return null;
    final list = (jsonDecode(s) as List).cast<Map<String, dynamic>>();
    return list.map(Level.fromJson).toList();
  }
}
