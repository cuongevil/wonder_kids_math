import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/level.dart';

/// 🧮 ProgressService v3.8 — Quản lý tiến độ học + mở khóa level kế tiếp + đồng bộ cloud
/// ✅ Local (SharedPreferences)
/// ✅ Cloud (Firebase Firestore)
/// ✅ Hỗ trợ lưu sao, trạng thái, learnedIndexes
class ProgressService {
  static const _progressKey = 'progress_data_v1';
  static const _learnedPrefix = 'learned_indexes_';
  static const _lastSyncKey = 'last_sync_time';

  // ---------------------------------------------------------------------------
  // 📦 LOAD & SAVE LEVELS
  // ---------------------------------------------------------------------------

  /// ✅ Lấy danh sách level hiện tại (hoặc tạo mặc định)
  static Future<List<Level>> ensureDefaultLevels(List<Level> Function() factory) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_progressKey);
    if (jsonStr == null) {
      final levels = factory();
      await saveLevels(levels);
      return levels;
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonStr);
      return jsonList.map((e) => Level.fromJson(e)).toList();
    } catch (_) {
      final levels = factory();
      await saveLevels(levels);
      return levels;
    }
  }

  static Future<List<Level>> loadLevels() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_progressKey);
    if (jsonStr == null) return [];
    try {
      final List<dynamic> jsonList = jsonDecode(jsonStr);
      return jsonList.map((e) => Level.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveLevels(List<Level> levels) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _progressKey,
      jsonEncode(levels.map((e) => e.toJson()).toList()),
    );
  }

  static Future<void> saveLevel(Level level) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_progressKey);
    List<dynamic> list = [];
    if (jsonStr != null) {
      try {
        list = jsonDecode(jsonStr);
      } catch (_) {}
    }

    final idx = list.indexWhere((e) => e['levelKey'] == level.levelKey);
    final json = level.toJson();
    if (idx != -1) {
      list[idx] = json;
    } else {
      list.add(json);
    }

    await prefs.setString(_progressKey, jsonEncode(list));
  }

  // ---------------------------------------------------------------------------
  // ⭐ STARS & STATE
  // ---------------------------------------------------------------------------

  static Future<int> getStars(String levelKey) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_progressKey);
    if (jsonStr == null) return 0;
    try {
      final List<dynamic> list = jsonDecode(jsonStr);
      final found = list.cast<Map<String, dynamic>>().firstWhere(
            (e) => e['levelKey'] == levelKey,
        orElse: () => {},
      );
      return found['stars'] ?? 0;
    } catch (_) {
      return 0;
    }
  }

  static Future<void> saveStars(String levelKey, int stars) async {
    final levels = await loadLevels();
    for (final lv in levels) {
      if (lv.levelKey == levelKey) lv.stars = stars;
    }
    await saveLevels(levels);
    await _syncToFirebase(levels.map((e) => e.toJson()).toList());
  }

  /// ✅ Cập nhật trạng thái của một level cụ thể
  static Future<void> updateLevelState(int index, LevelState state) async {
    final levels = await loadLevels();
    if (index >= 0 && index < levels.length) {
      levels[index].state = state;
      await saveLevels(levels);
      await _syncToFirebase(levels.map((e) => e.toJson()).toList());
    }
  }

  /// ✅ Đánh dấu level hoàn thành và mở khóa kế tiếp
  static Future<void> markLevelCompleted(String levelKey) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_progressKey);
    if (jsonStr == null) return;

    final List<dynamic> jsonList = jsonDecode(jsonStr);

    // 🔹 Tìm và đánh dấu completed
    for (var i = 0; i < jsonList.length; i++) {
      if (jsonList[i]['levelKey'] == levelKey) {
        jsonList[i]['state'] = 'completed';
        break;
      }
    }

    await prefs.setString(_progressKey, jsonEncode(jsonList));
    await _syncToFirebase(jsonList);

    // 🔹 Mở khóa level kế tiếp
    await unlockNextLevel(levelKey);
  }

  /// ✅ Mở khóa level kế tiếp (hoặc mở màn đầu nếu là start)
  static Future<void> unlockNextLevel(String currentKey) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_progressKey);
    if (jsonStr == null) return;

    final List<dynamic> jsonList = jsonDecode(jsonStr);
    final index = jsonList.indexWhere((e) => e['levelKey'] == currentKey);

    if (index != -1 && index + 1 < jsonList.length) {
      if (jsonList[index + 1]['state'] != 'completed') {
        jsonList[index + 1]['state'] = 'playable';
      }
    } else if (currentKey == 'start' && jsonList.isNotEmpty) {
      jsonList.first['state'] = 'playable';
    }

    await prefs.setString(_progressKey, jsonEncode(jsonList));
    await _syncToFirebase(jsonList);
  }

  // ---------------------------------------------------------------------------
  // 🧩 LEARNED INDEXES
  // ---------------------------------------------------------------------------

  static Future<void> saveLearnedIndexes(
      String levelKey, Map<String, bool> learnedIndexes) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_learnedPrefix$levelKey';
    await prefs.setString(key, jsonEncode(learnedIndexes));
    await _syncLearnedIndexesToFirebase(levelKey, learnedIndexes);
  }

  static Future<Map<String, bool>> getLearnedIndexes(String levelKey) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_learnedPrefix$levelKey';
    final jsonStr = prefs.getString(key);
    if (jsonStr == null) return {};
    try {
      final Map<String, dynamic> map = jsonDecode(jsonStr);
      return map.map((k, v) => MapEntry(k, v as bool));
    } catch (_) {
      return {};
    }
  }

  // ---------------------------------------------------------------------------
  // ☁️ FIREBASE SYNC
  // ---------------------------------------------------------------------------

  static Future<void> _syncToFirebase(List<dynamic> jsonList) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final prefs = await SharedPreferences.getInstance();
    final learnedKeys = prefs.getKeys().where((k) => k.startsWith(_learnedPrefix));
    final learnedData = <String, Map<String, bool>>{};

    for (final k in learnedKeys) {
      final jsonStr = prefs.getString(k);
      if (jsonStr != null) {
        final levelKey = k.replaceFirst(_learnedPrefix, '');
        learnedData[levelKey] = Map<String, bool>.from(jsonDecode(jsonStr));
      }
    }

    final now = DateTime.now().toIso8601String();
    await FirebaseFirestore.instance
        .collection('wonderkids_progress')
        .doc(user.uid)
        .set({
      'levels': jsonList,
      'learned': learnedData,
      'updated': now,
    });

    await prefs.setString(_lastSyncKey, now);
  }

  static Future<void> _syncLearnedIndexesToFirebase(
      String levelKey, Map<String, bool> data) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final now = DateTime.now().toIso8601String();
    await FirebaseFirestore.instance
        .collection('wonderkids_progress')
        .doc(user.uid)
        .set({
      'learned.$levelKey': data,
      'updated': now,
    }, SetOptions(merge: true));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSyncKey, now);
  }

  static Future<bool> restoreFromFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final doc = await FirebaseFirestore.instance
        .collection('wonderkids_progress')
        .doc(user.uid)
        .get();
    if (!doc.exists) return false;

    final data = doc.data();
    if (data == null) return false;

    final prefs = await SharedPreferences.getInstance();

    if (data['levels'] != null) {
      await prefs.setString(_progressKey, jsonEncode(data['levels']));
    }

    if (data['learned'] != null) {
      final learned = Map<String, dynamic>.from(data['learned']);
      for (final entry in learned.entries) {
        await prefs.setString('$_learnedPrefix${entry.key}', jsonEncode(entry.value));
      }
    }

    final updated = data['updated'] ?? DateTime.now().toIso8601String();
    await prefs.setString(_lastSyncKey, updated);
    return true;
  }

  // ---------------------------------------------------------------------------
  // ⚙️ RESET / CLEAR
  // ---------------------------------------------------------------------------

  static Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_progressKey);

    final keys = prefs.getKeys().where((k) => k.startsWith(_learnedPrefix));
    for (final k in keys) {
      await prefs.remove(k);
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('wonderkids_progress')
          .doc(user.uid)
          .delete();
    }
  }

  static Future<void> clear() async => resetAll();

  static Future<String?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastSyncKey);
  }

  static Future<int> getGrandTotal() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_progressKey);
    if (jsonStr == null) return 0;
    final List<dynamic> list = jsonDecode(jsonStr);
    int total = 0;
    for (final e in list) {
      if (e is Map<String, dynamic>) {
        total += (e['stars'] ?? 0) as int;
      }
    }
    return total;
  }

  // ---------------------------------------------------------------------------
  // 📘 DEFAULT LEVELS
  // ---------------------------------------------------------------------------

  static List<Level> defaultLevels() {
    return [
      Level(index: 0, title: 'Bắt đầu', type: LevelType.start, state: LevelState.playable, levelKey: "start"),
      Level(index: 1, title: 'Số 0–10', type: LevelType.topic, state: LevelState.locked, route: '/learn_numbers', levelKey: "0_10"),
      Level(index: 2, title: 'Số 0–20', type: LevelType.topic, state: LevelState.locked, route: '/learn_numbers_20', levelKey: "0_20"),
      Level(index: 3, title: 'Số 0–50', type: LevelType.topic, state: LevelState.locked, route: '/learn_numbers_50', levelKey: "0_50"),
      Level(index: 4, title: 'Số 0–100', type: LevelType.topic, state: LevelState.locked, route: '/learn_numbers_100', levelKey: "0_100"),
      Level(index: 5, title: 'So sánh', type: LevelType.topic, state: LevelState.locked, route: '/game_compare', levelKey: "compare"),
      Level(index: 6, title: 'Cộng ≤10', type: LevelType.topic, state: LevelState.locked, route: '/game_addition10', levelKey: "addition10"),
      Level(index: 7, title: 'Trừ ≤10', type: LevelType.topic, state: LevelState.locked, route: '/game_subtraction10', levelKey: "subtraction10"),
      Level(index: 8, title: 'Cộng ≤20', type: LevelType.topic, state: LevelState.locked, route: '/game_addition20', levelKey: "addition20"),
      Level(index: 9, title: 'Trừ ≤20', type: LevelType.topic, state: LevelState.locked, route: '/game_subtraction20', levelKey: "subtraction20"),
      Level(index: 10, title: 'Cộng ≤50', type: LevelType.topic, state: LevelState.locked, route: '/game_addition50', levelKey: "addition50"),
      Level(index: 11, title: 'Trừ ≤50', type: LevelType.topic, state: LevelState.locked, route: '/game_subtraction50', levelKey: "subtraction50"),
      Level(index: 12, title: 'Cộng ≤100', type: LevelType.topic, state: LevelState.locked, route: '/game_addition100', levelKey: "addition100"),
      Level(index: 13, title: 'Trừ ≤100', type: LevelType.topic, state: LevelState.locked, route: '/game_subtraction100', levelKey: "subtraction100"),
      Level(index: 14, title: 'Hình học', type: LevelType.topic, state: LevelState.locked, route: '/game_shapes', levelKey: "shapes"),
      Level(index: 15, title: 'Đo lường', type: LevelType.topic, state: LevelState.locked, route: '/game_measure_time', levelKey: "measure"),
    ];
  }
}
