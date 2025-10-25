import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/level.dart';

/// 🧮 ProgressService v3.7 — Quản lý tiến độ học + mở khóa level kế tiếp + đồng bộ cloud
/// ✅ Local (SharedPreferences)
/// ✅ Cloud (Firebase Firestore)
/// ✅ Hỗ trợ lưu bài học con (learnedIndexes)
class ProgressService {
  static const _progressKey = 'progress_data_v1';
  static const _learnedPrefix = 'learned_indexes_';
  static const _lastSyncKey = 'last_sync_time';

  /// ✅ Lấy danh sách level hiện tại (hoặc tạo mặc định)
  static Future<List<Level>> ensureDefaultLevels(List<Level> Function() factory) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_progressKey);
    if (jsonStr == null) {
      final levels = factory();
      await _saveProgress(levels);
      return levels;
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonStr);
      return jsonList.map((e) => Level.fromJson(e)).toList();
    } catch (_) {
      final levels = factory();
      await _saveProgress(levels);
      return levels;
    }
  }

  /// ✅ Lấy số sao của 1 level
  static Future<int> getStars(String levelKey) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_progressKey);
    if (jsonStr == null) return 0;
    final List<dynamic> jsonList = jsonDecode(jsonStr);
    final found = jsonList.cast<Map<String, dynamic>>().firstWhere(
          (e) => e['levelKey'] == levelKey,
      orElse: () => {},
    );
    return found['stars'] ?? 0;
  }

  /// ✅ Lưu số sao cho 1 level
  static Future<void> saveStars(String levelKey, int stars) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_progressKey);
    if (jsonStr == null) return;

    final List<dynamic> jsonList = jsonDecode(jsonStr);
    for (final e in jsonList) {
      if (e['levelKey'] == levelKey) e['stars'] = stars;
    }

    await prefs.setString(_progressKey, jsonEncode(jsonList));
    await _syncToFirebase(jsonList);
  }

  /// ✅ Đánh dấu level đã hoàn thành (và mở khóa level kế tiếp)
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

    // 🔹 Sau khi hoàn thành, mở khóa kế tiếp
    await unlockNextLevel(levelKey);
  }

  /// ✅ Mở khóa level kế tiếp (kể cả khi currentKey là "start")
  static Future<void> unlockNextLevel(String currentKey) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_progressKey);
    if (jsonStr == null) return;

    final List<dynamic> jsonList = jsonDecode(jsonStr);
    final index = jsonList.indexWhere((e) => e['levelKey'] == currentKey);

    if (index != -1 && index + 1 < jsonList.length) {
      // Mở khóa level kế tiếp nếu chưa hoàn thành
      if (jsonList[index + 1]['state'] != 'completed') {
        jsonList[index + 1]['state'] = 'playable';
      }
    }
    // Nếu là "start" mà chưa có trong danh sách → mở level đầu tiên
    else if (currentKey == 'start' && jsonList.isNotEmpty) {
      if (jsonList.first['state'] != 'completed') {
        jsonList.first['state'] = 'playable';
      }
    }

    await prefs.setString(_progressKey, jsonEncode(jsonList));
    await _syncToFirebase(jsonList);
  }

  /// ✅ Lưu danh sách chỉ số bài đã học (learnedIndexes)
  static Future<void> saveLearnedIndexes(
      String levelKey, Map<String, bool> learnedIndexes) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_learnedPrefix$levelKey';
    await prefs.setString(key, jsonEncode(learnedIndexes));
    await _syncLearnedIndexesToFirebase(levelKey, learnedIndexes);
  }

  /// ✅ Lấy danh sách chỉ số bài đã học (learnedIndexes)
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

  /// ✅ Reset toàn bộ tiến độ học local + cloud
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

  /// ✅ Lấy thời gian đồng bộ gần nhất
  static Future<String?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastSyncKey);
  }

  /// ✅ Đồng bộ local → Firebase
  static Future<void> _syncToFirebase(List<dynamic> jsonList) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final prefs = await SharedPreferences.getInstance();
    final learnedKeys =
    prefs.getKeys().where((k) => k.startsWith(_learnedPrefix));
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

  /// ✅ Đồng bộ riêng từng learnedIndexes (khi học xong 1 bài nhỏ)
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

  /// ✅ Khôi phục tiến độ học từ Firebase → local
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
        final key = '$_learnedPrefix${entry.key}';
        await prefs.setString(key, jsonEncode(entry.value));
      }
    }

    final updated = data['updated'] ?? DateTime.now().toIso8601String();
    await prefs.setString(_lastSyncKey, updated);
    return true;
  }

  /// 🔹 Lưu danh sách level xuống local
  static Future<void> _saveProgress(List<Level> levels) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = levels.map((e) => e.toJson()).toList();
    await prefs.setString(_progressKey, jsonEncode(jsonList));
  }

  // 🧩 Alias methods (cho code cũ)
  static Future<void> saveLevels(List<Level> levels) async => _saveProgress(levels);

  static Future<List<Level>> loadLevels() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_progressKey);
    if (jsonStr == null) return [];
    final List<dynamic> jsonList = jsonDecode(jsonStr);
    return jsonList.map((e) => Level.fromJson(e)).toList();
  }

  static Future<void> clear() async => resetAll();

  static Future<int> getGrandTotal() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_progressKey);
    if (jsonStr == null) return 0;
    final List<dynamic> jsonList = jsonDecode(jsonStr);
    int total = 0;
    for (final e in jsonList) {
      if (e is Map<String, dynamic>) {
        total += (e['stars'] ?? 0) as int;
      }
    }
    return total;
  }
}
