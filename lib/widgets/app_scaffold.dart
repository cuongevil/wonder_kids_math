import 'package:flutter/material.dart';
import '../models/level.dart';
import '../services/progress_service.dart';

class AppScaffold extends StatefulWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;

  /// levels hiện tại (truyền từ màn MapScreen)
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
    await ProgressService.saveLevels(defaultLevels);
    widget.onLevelsChanged?.call(defaultLevels);
    _showSnack("Đã reset levels");
  }

  Future<void> _clearCache() async {
    await ProgressService.clear();
    final defaultLevels = _defaultLevels();
    await ProgressService.saveLevels(defaultLevels);
    widget.onLevelsChanged?.call(defaultLevels);
    _showSnack("Đã xóa cache");
  }

  Future<void> _unlockAll() async {
    final updated = [...levels];
    for (var lv in updated) {
      if (lv.state != LevelState.completed) {
        lv.state = LevelState.playable;
      }
    }
    await ProgressService.saveLevels(updated);
    widget.onLevelsChanged?.call(updated);
    _showSnack("Đã mở khóa tất cả level");
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
      Level(index: 0, title: 'Bắt đầu', type: LevelType.start, state: LevelState.playable),
      Level(index: 1, title: 'Làng Số 0–10', type: LevelType.topic, state: LevelState.locked, route: '/learn_numbers'),
      Level(index: 2, title: 'Rừng Số 11–20', type: LevelType.topic, state: LevelState.locked, route: '/learn_numbers_20'),
      Level(index: 3, title: 'Cầu Cộng ≤10', type: LevelType.topic, state: LevelState.locked, route: '/game_addition10'),
      Level(index: 4, title: 'Hang Trừ ≤10', type: LevelType.topic, state: LevelState.locked, route: '/game_subtraction10'),
      Level(index: 5, title: 'Đồng Bằng So Sánh', type: LevelType.topic, state: LevelState.locked, route: '/game_compare'),
      Level(index: 6, title: 'Sông Cộng ≤20', type: LevelType.topic, state: LevelState.locked, route: '/game_addition20'),
      Level(index: 7, title: 'Sa Mạc Trừ ≤20', type: LevelType.topic, state: LevelState.locked, route: '/game_subtraction20'),
      Level(index: 8, title: 'Thành Phố Hình Học', type: LevelType.topic, state: LevelState.locked, route: '/game_shapes'),
      Level(index: 9, title: 'Thung Lũng Đo Lường', type: LevelType.topic, state: LevelState.locked, route: '/game_measure_time'),
      Level(index: 10, title: 'Lâu Đài Boss Cuối', type: LevelType.boss, state: LevelState.locked, route: '/game_final_boss'),
      Level(index: 11, title: 'Kết thúc', type: LevelType.end, state: LevelState.locked),
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

      bottomNavigationBar: widget.bottomNavigationBar ??
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
                    icon: Icons.refresh,
                    tooltip: "Reset Levels",
                    onTap: _resetLevels,
                  ),
                  _buildKidIconButton(
                    context: context,
                    color: Colors.lightBlueAccent,
                    icon: Icons.delete,
                    tooltip: "Clear Cache",
                    onTap: _clearCache,
                  ),
                  _buildKidIconButton(
                    context: context,
                    color: Colors.greenAccent,
                    icon: Icons.lock_open,
                    tooltip: "Unlock All",
                    onTap: _unlockAll,
                  ),
                ],
              ),
            ),
          ),
    );
  }

  /// 🔹 Nút pastel tròn + tooltip
  Widget _buildKidIconButton({
    required BuildContext context,
    required Color color,
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 6,
            spreadRadius: 1,
          )
        ],
      ),
      textStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      preferBelow: false,
      verticalOffset: 40,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedScale(
          scale: 1.0,
          duration: const Duration(milliseconds: 150),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                )
              ],
            ),
            child: Icon(icon, size: 30, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
