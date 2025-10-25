import 'dart:ui';

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
  final bool showBottomNav; // ✅ mới thêm

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.levels,
    this.onLevelsChanged,
    this.showBottomNav = true, // ✅ mặc định hiển thị
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
    await ProgressService.resetAll();
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

  Future<void> _debugLevels() async {
    final totalStars = await ProgressService.getGrandTotal();
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("🐞 Debug Levels"),
        content: Text("⭐ Tổng sao: $totalStars"),
        actions: [
          TextButton(
            onPressed: () async {
              await ProgressService.resetAll();
              if (mounted) Navigator.pop(context);
              _showSnack("Reset all progress → OK");
            },
            child: const Text("🔄 Reset"),
          ),
          TextButton(
            onPressed: () async {
              await ProgressService.clear();
              if (mounted) Navigator.pop(context);
              _showSnack("Clear SharedPreferences → OK");
            },
            child: const Text("🗑️ Clear"),
          ),
          TextButton(
            onPressed: () async {
              final defaultLevels = _defaultLevels();
              final prefs = await SharedPreferences.getInstance();

              for (var lv in defaultLevels) {
                if (lv.levelKey != null && lv.levelKey!.isNotEmpty) {
                  await ProgressService.saveStars(lv.levelKey!, 0);
                  await ProgressService.saveLearnedIndexes(lv.levelKey!, {});
                  await prefs.setBool("isFinalRewardShown_${lv.levelKey}", false);
                }
              }

              widget.onLevelsChanged?.call(defaultLevels);

              if (mounted) {
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(context, "/", (_) => false);
                _showSnack("🔄 Đã reset toàn bộ levels về trạng thái ban đầu");
              }
            },
            child: const Text("🔄 Chơi lại toàn bộ"),
          ),
          TextButton(
            onPressed: () async {
              final updated = _defaultLevels();
              for (var lv in updated) {
                if (lv.state == LevelState.locked) {
                  lv.state = LevelState.playable;
                }
              }
              await ProgressService.saveLevels(updated);
              widget.onLevelsChanged?.call(updated);

              if (mounted) {
                Navigator.pop(context);
                _showSnack("🔓 Đã mở khóa toàn bộ levels (debug)");
              }
            },
            child: const Text("🔓 Unlock All"),
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

  List<Level> _defaultLevels() => ProgressService.defaultLevels();

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final isNight = hour >= 18 || hour < 6;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white.withOpacity(0.05),
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(color: Colors.white.withOpacity(0.05)),
          ),
        ),
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF5E2CED), Color(0xFFFF8B00)],
          ).createShader(bounds),
          child: Text(
            widget.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [Shadow(color: Colors.black26, blurRadius: 4)],
            ),
          ),
        ),
        actions: widget.actions ??
            (kDebugMode
                ? [
              IconButton(
                icon: const Icon(Icons.bug_report, color: Colors.white),
                onPressed: _debugLevels,
              )
            ]
                : null),
        centerTitle: true,
      ),
      body: widget.body,
      floatingActionButton: widget.floatingActionButton,
      bottomNavigationBar: widget.showBottomNav
          ? (widget.bottomNavigationBar ?? _buildDefaultBottomNav())
          : null, // ✅ không hiển thị nếu showBottomNav = false
    );
  }

  Widget _buildDefaultBottomNav() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF5E2CED), Color(0xFFFF8B00)],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
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
              icon: Icons.settings,
              tooltip: "Cài đặt",
              onTap: () => Navigator.pushNamed(context, "/settings"),
            ),
          ],
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
