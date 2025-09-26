import 'package:shared_preferences/shared_preferences.dart';

class ProgressService {
  static const _prefix = "progress_";

  /// Lưu tiến độ (số điểm, tổng số vòng)
  static Future<void> saveProgress(String key, int score, int total) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("${_prefix}${key}_score", score);
    await prefs.setInt("${_prefix}${key}_total", total);
  }

  /// Tải tiến độ (trả về Map {score, total})
  static Future<Map<String, int>> loadProgress(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final score = prefs.getInt("${_prefix}${key}_score") ?? 0;
    final total = prefs.getInt("${_prefix}${key}_total") ?? 0;
    return {"score": score, "total": total};
  }

  /// Lấy progress dạng phần trăm (0.0–1.0)
  static Future<double> getProgress(String key, int total) async {
    final prefs = await SharedPreferences.getInstance();
    final score = prefs.getInt("${_prefix}${key}_score") ?? 0;
    if (total <= 0) return 0.0;
    return score / total;
  }

  /// Update nhanh (nếu chỉ cần lưu số câu đúng)
  static Future<void> updateProgress(String key, int current) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("${_prefix}${key}_score", current);
  }

  /// Lấy raw score
  static Future<int> getRaw(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("${_prefix}${key}_score") ?? 0;
  }

  /// Reset toàn bộ 1 key
  static Future<void> reset(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("${_prefix}${key}_score");
    await prefs.remove("${_prefix}${key}_total");
  }
}
