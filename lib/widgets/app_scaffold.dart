import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/level.dart';
import '../services/progress_service.dart';

class AppScaffold extends StatefulWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final List<Level>? levels;
  final Function(List<Level>)? onLevelsChanged;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.levels,
    this.onLevelsChanged,
  });

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  List<Level> get levels => widget.levels ?? [];

  Future<void> _resetLevels() async {
    final defaultLevels = _defaultLevels();
    await ProgressService.resetAll();
    widget.onLevelsChanged?.call(defaultLevels);
    _showSnack("Đã reset levels");
  }

  Future<void> _clearCache() async {
    await ProgressService.resetAll(); // 🔹 xóa sao + learnedIndexes
    final defaultLevels = _defaultLevels();
    widget.onLevelsChanged?.call(defaultLevels);
    _showSnack("Đã xóa cache toàn bộ");
  }

  Future<void> _unlockAll() async {
    final updated = [...levels];
    for (var lv in updated) {
      if (lv.state != LevelState.completed) {
        lv.state = LevelState.playable;
      }
    }
    widget.onLevelsChanged?.call(updated);
    _showSnack("Đã mở khóa tất cả level");
  }

  /// 🐞 Debug popup
  Future<void> _debugLevels() async {
    final totalStars = await ProgressService.getGrandTotal();
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("🐞 Debug Levels"),
        content: Text("⭐ Tổng sao: $totalStars"),
        actions: [
          // Reset toàn bộ progress (grand total + levels)
          TextButton(
            onPressed: () async {
              await ProgressService.resetAll();
              if (mounted) Navigator.pop(context);
              _showSnack("Reset all progress → OK");
            },
            child: const Text("🔄 Reset"),
          ),
          // Clear SharedPreferences
          TextButton(
            onPressed: () async {
              await ProgressService.clear();
              if (mounted) Navigator.pop(context);
              _showSnack("Clear SharedPreferences → OK");
            },
            child: const Text("🗑️ Clear"),
          ),
          // ✅ Chơi lại từ đầu toàn bộ levels
          TextButton(
            onPressed: () async {
              final defaultLevels = _defaultLevels();
              final prefs = await SharedPreferences.getInstance();

              for (var lv in defaultLevels) {
                if (lv.levelKey != null && lv.levelKey!.isNotEmpty) {
                  await ProgressService.saveStars(lv.levelKey!, 0);
                  await ProgressService.saveLearnedIndexes(lv.levelKey!, {});
                  await prefs.setBool(
                    "isFinalRewardShown_${lv.levelKey}",
                    false,
                  );
                }
              }

              // 🔹 Cập nhật lại levels trong UI
              widget.onLevelsChanged?.call(defaultLevels);

              // 🔹 Đóng dialog + quay về MapScreen
              if (mounted) {
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(context, "/", (_) => false);
                _showSnack("🔄 Đã reset toàn bộ levels về trạng thái ban đầu");
              }
            },
            child: const Text("🔄 Chơi lại toàn bộ levels"),
          ),
          TextButton(
            onPressed: () {
              if (mounted) Navigator.pop(context);
            },
            child: const Text("Đóng"),
          ),
        ],
      ),
    );
  }

  void _goHome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, "/", (_) => false);
  }

  void _showSnack(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 1)),
      );
    }
  }

  List<Level> _defaultLevels() {
    return [
      Level(
        index: 0,
        title: 'Bắt đầu',
        type: LevelType.start,
        state: LevelState.playable,
      ),
      Level(
        index: 1,
        title: 'Số 0–10',
        type: LevelType.topic,
        state: LevelState.locked,
        route: '/learn_numbers',
        levelKey: "0_10",
      ),
      Level(
        index: 2,
        title: 'Số 11–20',
        type: LevelType.topic,
        state: LevelState.locked,
        route: '/learn_numbers_20',
        levelKey: "11_20",
      ),
      Level(
        index: 3,
        title: 'Số 21–50',
        type: LevelType.topic,
        state: LevelState.locked,
        route: '/learn_numbers_50',
        levelKey: "21_50",
      ),
      Level(
        index: 4,
        title: 'Số 51–100',
        type: LevelType.topic,
        state: LevelState.locked,
        route: '/learn_numbers_100',
        levelKey: "51_100",
      ),
      Level(
        index: 5,
        title: 'Cộng ≤10',
        type: LevelType.topic,
        state: LevelState.locked,
        route: '/game_addition10',
        levelKey: "addition10",
      ),
      Level(
        index: 6,
        title: 'Trừ ≤10',
        type: LevelType.topic,
        state: LevelState.locked,
        route: '/game_subtraction10',
        levelKey: "subtraction10",
      ),
      Level(
        index: 7,
        title: 'So Sánh',
        type: LevelType.topic,
        state: LevelState.locked,
        route: '/game_compare',
        levelKey: "compare",
      ),
      Level(
        index: 8,
        title: 'Cộng ≤20',
        type: LevelType.topic,
        state: LevelState.locked,
        route: '/game_addition20',
        levelKey: "addition20",
      ),
      Level(
        index: 9,
        title: 'Trừ ≤20',
        type: LevelType.topic,
        state: LevelState.locked,
        route: '/game_subtraction20',
        levelKey: "subtraction20",
      ),
      Level(
        index: 10,
        title: 'Hình Học',
        type: LevelType.topic,
        state: LevelState.locked,
        route: '/game_shapes',
        levelKey: "shapes",
      ),
      Level(
        index: 11,
        title: 'Đo Lường',
        type: LevelType.topic,
        state: LevelState.locked,
        route: '/game_measure_time',
        levelKey: "measure",
      ),
      Level(
        index: 12,
        title: 'Tổng hợp',
        type: LevelType.boss,
        state: LevelState.locked,
        route: '/game_final_boss',
        levelKey: "final_boss",
      ),
      Level(
        index: 13,
        title: 'Kết thúc',
        type: LevelType.end,
        state: LevelState.locked,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final isNight = hour >= 18 || hour < 6;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [Shadow(color: Colors.black26, blurRadius: 4)],
          ),
        ),
        actions: widget.actions,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isNight
                  ? [const Color(0xFF0D47A1), const Color(0xFF1A237E)]
                  : [const Color(0xFF81D4FA), const Color(0xFFF48FB1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: widget.body,
      floatingActionButton: widget.floatingActionButton,
      bottomNavigationBar:
          widget.bottomNavigationBar ??
          BottomAppBar(
            color: Colors.white,
            elevation: 8,
            child: SizedBox(
              height: 72,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildKidIconButton(
                    context: context,
                    color: Colors.deepPurpleAccent,
                    icon: Icons.home,
                    tooltip: "Trang chủ",
                    onTap: () => _goHome(context),
                  ),
                  _buildKidIconButton(
                    context: context,
                    color: Colors.pinkAccent,
                    icon: Icons.person,
                    tooltip: "Thành tích",
                    onTap: () => Navigator.pushNamed(context, "/profile"),
                  ),
                  _buildKidIconButton(
                    context: context,
                    color: Colors.orangeAccent,
                    icon: Icons.leaderboard,
                    tooltip: "Bảng xếp hạng",
                    onTap: () => Navigator.pushNamed(context, "/leaderboard"),
                  ),
                  _buildKidIconButton(
                    context: context,
                    color: Colors.lightBlueAccent,
                    icon: Icons.collections,
                    tooltip: "Bộ sưu tập huy hiệu",
                    onTap: () => Navigator.pushNamed(context, "/badges"),
                  ),
                  if (kDebugMode)
                    _buildKidIconButton(
                      context: context,
                      color: Colors.orangeAccent,
                      icon: Icons.bug_report,
                      tooltip: "Debug Levels",
                      onTap: _debugLevels,
                    ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildKidIconButton({
    required BuildContext context,
    required Color color,
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(icon, size: 26, color: Colors.white),
        ),
      ),
    );
  }
}
