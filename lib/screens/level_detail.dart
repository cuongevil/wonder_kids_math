// 📄 lib/screens/level_detail.dart
import 'dart:math';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import '../models/level.dart';
import '../services/progress_service.dart';
import '../themes/app_theme.dart';

/// 🌈 LevelDetail 2025 — CHỈ render nội dung màn chơi
/// ⚠️ KHÔNG bọc AppShell ở đây để tránh “double shell” → bug chỉ về Map
class LevelDetail extends StatefulWidget {
  static const routeName = '/level_detail';
  const LevelDetail({super.key});

  @override
  State<LevelDetail> createState() => _LevelDetailState();
}

class _LevelDetailState extends State<LevelDetail>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _bounceController;
  late AnimationController _sparkleController;
  late AnimationController _glowController;
  final AudioPlayer _player = AudioPlayer();

  Level? _currentLevel;
  int? _levelIndex;
  List<Level> _levels = [];
  bool _argsParsed = false;

  @override
  void initState() {
    super.initState();

    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
      lowerBound: 0.9,
      upperBound: 1.1,
    )..repeat(reverse: true);

    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
      lowerBound: 0.7,
      upperBound: 1.0,
    )..repeat(reverse: true);

    Future.delayed(const Duration(milliseconds: 300), () async {
      if (!mounted) return;
      _confettiController.play();
      await _player.play(AssetSource("audios/welcome.mp3"));
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsParsed) return;
    _argsParsed = true;
    _parseArgsAndLoad();
  }

  /// 🔁 Load dữ liệu Level + cập nhật trạng thái ban đầu
  Future<void> _parseArgsAndLoad() async {
    final loaded = await ProgressService.loadLevels();
    _levels = loaded.isEmpty
        ? await ProgressService.ensureDefaultLevels(() => [])
        : loaded;

    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is Level) {
      _currentLevel = arg;
      _levelIndex = arg.index;
    } else if (arg is int) {
      _levelIndex = arg;
      if (_levelIndex! >= 0 && _levelIndex! < _levels.length) {
        _currentLevel = _levels[_levelIndex!];
      }
    }

    _currentLevel ??= _levels.isNotEmpty
        ? _levels.first
        : Level(
      index: 0,
      title: 'Bắt đầu',
      type: LevelType.start,
      state: LevelState.playable,
      levelKey: 'start',
    );

    _levelIndex ??= _currentLevel?.index ?? 0;

    // ✅ Nếu level bị khóa → mở ra
    if (_currentLevel!.state == LevelState.locked) {
      _currentLevel!.state = LevelState.playable;
      await ProgressService.updateLevelState(
        _currentLevel!.index,
        LevelState.playable,
      );
    }

    // ✅ Nếu là màn “Bắt đầu” → reset
    if (_currentLevel!.levelKey == "start") {
      _currentLevel!.stars = 0;
      _currentLevel!.total = 0;
      await ProgressService.saveLevel(_currentLevel!);
    }

    await ProgressService.saveLevels(_levels);

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _sparkleController.dispose();
    _confettiController.dispose();
    _glowController.dispose();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isStartLevel =
        (_currentLevel?.levelKey == "start") || (_levelIndex == 0);

    // ❗️KHÔNG bọc AppShell — để Shell gốc của app vẫn là duy nhất
    return Scaffold(
      backgroundColor: AppTheme.tpDarkBg,
      body: Stack(
        children: [
          _buildGradientBackground(),
          Center(
            child: isStartLevel
                ? _buildStartScreen(context)
                : _buildNormalLevel(context),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 25,
              gravity: 0.3,
              colors: const [
                Color(0xFF5E2CED),
                Color(0xFFA58CFF),
                Color(0xFFFF8B00),
                Colors.white,
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🌈 Nền gradient động fintech
  Widget _buildGradientBackground() {
    return Positioned.fill(
      child: AnimatedContainer(
        duration: const Duration(seconds: 2),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.tpDarkBg,
              Color(0xFF5E2CED),
              Color(0xFFA58CFF),
              Color(0xFFFF8B00),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    );
  }

  // 🟣 Màn hình khởi đầu
  Widget _buildStartScreen(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              _buildSparkle(80, 1.0, const Color(0xFFFF8B00)),
              _buildSparkle(60, -1.5, const Color(0xFF5E2CED)),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF5E2CED).withOpacity(0.6),
                      blurRadius: 30,
                    ),
                    BoxShadow(
                      color: const Color(0xFFFF8B00).withOpacity(0.4),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: ScaleTransition(
                  scale: _bounceController,
                  child: Image.asset(
                    "assets/images/mascot/mascot_10.png",
                    width: 160,
                    height: 160,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ShaderMask(
            shaderCallback: (rect) =>
                AppTheme.primaryGradient.createShader(rect),
            child: const Text(
              "Xin chào 👋",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Cùng học số và phép tính thật vui nhé!",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.white70),
          ),
          const SizedBox(height: 50),
          _buildActionButton(
            label: "Bắt đầu thôi!",
            icon: Icons.play_arrow_rounded,
            color: AppTheme.tpPurple,
            onPressed: () async {
              _confettiController.play();
              await _player.play(AssetSource("audios/crown.mp3"));
              await Future.delayed(const Duration(milliseconds: 600));

              // ✅ Hoàn thành màn start → mở khóa level tiếp theo
              await ProgressService.markLevelCompleted("start");

              if (!mounted) return;
              Navigator.pop(context, true); // quay về Shell gốc (tab giữ nguyên)
            },
          ),
        ],
      ),
    );
  }

  // 🧩 Màn Level thông thường
  Widget _buildNormalLevel(BuildContext context) {
    final level = _currentLevel;
    if (level == null) return const SizedBox();

    final isCompleted = level.state == LevelState.completed;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ShaderMask(
            shaderCallback: (rect) =>
                AppTheme.primaryGradient.createShader(rect),
            child: Text(
              level.title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isCompleted
                ? "Bạn đã hoàn thành màn này 🎉"
                : "Chưa có nội dung game cụ thể.\nBạn có thể hoàn thành thủ công.",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            icon: Icon(
              isCompleted ? Icons.check_circle : Icons.flag_rounded,
              color: Colors.white,
            ),
            label: Text(isCompleted ? "Quay lại bản đồ" : "Hoàn thành Level"),
            style: ElevatedButton.styleFrom(
              backgroundColor: isCompleted ? Colors.grey : AppTheme.tpOrange,
              minimumSize: const Size(220, 55),
              elevation: 6,
              shadowColor: AppTheme.tpOrange.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: () async {
              if (isCompleted) {
                Navigator.pop(context, true);
                return;
              }

              _confettiController.play();
              await _player.play(AssetSource("audios/crown.mp3"));
              await Future.delayed(const Duration(milliseconds: 500));

              // ✅ Đánh dấu hoàn thành + mở khóa kế tiếp
              await ProgressService.markLevelCompleted(level.levelKey!);

              if (!mounted) return;
              Navigator.pop(context, true); // trở về AppShell gốc
            },
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            icon: const Icon(Icons.arrow_back),
            label: const Text("Quay lại bản đồ"),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white70,
              side: const BorderSide(color: Colors.white38),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            onPressed: () => Navigator.pop(context, false),
          ),
        ],
      ),
    );
  }

  // 🌟 Nút hành động gradient + glow mềm
  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final glow = _glowController.value;
        return Container(
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4 * glow),
                blurRadius: 25 * glow,
              ),
              BoxShadow(
                color: AppTheme.tpOrange.withOpacity(0.3 * glow),
                blurRadius: 20 * glow,
              ),
            ],
          ),
          child: ElevatedButton.icon(
            icon: Icon(icon, color: Colors.white, size: 26),
            label: Text(
              label,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              minimumSize: const Size(220, 60),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
            ),
            onPressed: onPressed,
          ),
        );
      },
    );
  }

  // ✨ Hiệu ứng sao quay quanh mascot
  Widget _buildSparkle(double radius, double speed, Color color) {
    return AnimatedBuilder(
      animation: _sparkleController,
      builder: (context, child) {
        final angle = _sparkleController.value * 2 * pi * speed;
        final dx = cos(angle) * radius;
        final dy = sin(angle) * radius;
        return Transform.translate(
          offset: Offset(dx, dy),
          child: Icon(Icons.star, color: color.withOpacity(0.8), size: 16),
        );
      },
    );
  }
}
