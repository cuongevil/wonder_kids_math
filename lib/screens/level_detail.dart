import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import '../services/progress_service.dart';
import '../models/level.dart';
import 'base_screen.dart';

/// 🌈 LevelDetail v3.9 — Robust args + Unlock Next + Auto Navigate
class LevelDetail extends StatefulWidget {
  static const routeName = '/level_detail';
  const LevelDetail({super.key});

  @override
  State<LevelDetail> createState() => _LevelDetailState();
}

class _LevelDetailState extends State<LevelDetail> with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _bounceController;
  late AnimationController _sparkleController;
  late AnimationController _glowController;
  final AudioPlayer _player = AudioPlayer();

  Level? _currentLevel;     // ✅ Level hiện tại
  int? _levelIndex;         // chỉ dùng hiển thị khi thiếu title
  List<Level> _levels = [];
  bool _argsParsed = false; // tránh parse nhiều lần

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

    _sparkleController = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();
    _glowController = AnimationController(vsync: this, duration: const Duration(seconds: 2), lowerBound: 0.7, upperBound: 1.0)..repeat(reverse: true);

    // 🔊 Hiệu ứng chào mừng
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

  Future<void> _parseArgsAndLoad() async {
    // 1) Tải levels hiện có (không tạo mới ở đây để không reset progress)
    final loaded = await ProgressService.loadLevels();
    if (loaded.isEmpty) {
      // nếu chưa có, mới khởi tạo theo map mặc định của MapScreen (nếu cần)
      _levels = await ProgressService.ensureDefaultLevels(() => []);
    } else {
      _levels = loaded;
    }

    // 2) Đọc tham số truyền vào
    final arg = ModalRoute.of(context)?.settings.arguments;

    if (arg is Level) {
      _currentLevel = arg;
      _levelIndex = arg.index;
    } else if (arg is int) {
      _levelIndex = arg;
      if (_levelIndex != null && _levelIndex! >= 0 && _levelIndex! < _levels.length) {
        _currentLevel = _levels[_levelIndex!];
      }
    } else if (arg is Map) {
      final idx = arg['index'] as int?;
      final key = arg['levelKey'] as String?;
      if (idx != null && idx >= 0 && idx < _levels.length) {
        _currentLevel = _levels[idx];
        _levelIndex = idx;
      } else if (key != null) {
        final found = _levels.indexWhere((e) => e.levelKey == key);
        if (found != -1) {
          _currentLevel = _levels[found];
          _levelIndex = found;
        }
      }
    }

    // 3) Fallback an toàn: chọn level "start" hoặc playable đầu tiên
    _currentLevel ??= _levels.firstWhere(
          (e) => e.levelKey == 'start',
      orElse: () {
        final i = _levels.indexWhere((e) => e.state == LevelState.playable);
        return i != -1 ? _levels[i] : (_levels.isNotEmpty ? _levels.first : Level(index: 0, title: 'Bắt đầu', type: LevelType.start, state: LevelState.playable, levelKey: 'start'));
      },
    );
    _levelIndex ??= _currentLevel?.index ?? 0;

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
    final bool isStartLevel = (_currentLevel?.levelKey == "start") || (_levelIndex == 0);

    return BaseScreen(
      title: isStartLevel ? "Bắt đầu" : "Chi tiết Level ${_currentLevel?.title ?? _levelIndex ?? ''}",
      child: Stack(
        children: [
          Center(
            child: isStartLevel
                ? _buildStartScreen(context)
                : _buildNormalLevel(context, _levelIndex ?? -1),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 25,
              gravity: 0.3,
              colors: const [Color(0xFF5E2CED), Color(0xFFA58CFF), Color(0xFFFF8B00), Colors.white],
            ),
          ),
        ],
      ),
    );
  }

  /// 🌟 Màn hình mở đầu (Level 0)
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
                    BoxShadow(color: const Color(0xFF5E2CED).withOpacity(0.6), blurRadius: 30, spreadRadius: -4),
                    BoxShadow(color: const Color(0xFFFF8B00).withOpacity(0.4), blurRadius: 20, spreadRadius: -2),
                  ],
                ),
                child: ScaleTransition(
                  scale: _bounceController,
                  child: Image.asset("assets/images/mascot/mascot_10.png", width: 160, height: 160),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ShaderMask(
            shaderCallback: (rect) => const LinearGradient(colors: [Color(0xFF5E2CED), Color(0xFFFF8B00)]).createShader(rect),
            child: const Text("Xin chào 👋", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          const SizedBox(height: 12),
          const Text("Cùng học số và phép tính thật vui nhé!", textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: Colors.white70)),
          const SizedBox(height: 50),

          /// 🔹 Nút CTA phát sáng động
          AnimatedBuilder(
            animation: _glowController,
            builder: (context, child) {
              final glow = _glowController.value;
              return Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF5E2CED), Color(0xFFFF8B00)]),
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF5E2CED).withOpacity(0.4 * glow.clamp(0.6, 1.0)), blurRadius: 25 * glow, spreadRadius: 1),
                    BoxShadow(color: const Color(0xFFFF8B00).withOpacity(0.3 * glow.clamp(0.6, 1.0)), blurRadius: 20 * glow, spreadRadius: 1),
                  ],
                ),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.play_arrow, color: Colors.white, size: 28),
                  label: const Text("Bắt đầu thôi!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    minimumSize: const Size(220, 60),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                  ),
                  onPressed: () async {
                    if (!mounted) return;
                    _confettiController.play();
                    await _player.play(AssetSource("audios/crown.mp3"));

                    // Đánh dấu start hoàn thành -> mở khóa level kế tiếp
                    await ProgressService.markLevelCompleted("start");

                    // Load lại danh sách để lấy route kế tiếp
                    _levels = await ProgressService.loadLevels();
                    final nextIndex = 1; // sau "start"
                    if (nextIndex < _levels.length) {
                      final next = _levels[nextIndex];
                      if ((next.route ?? '').isNotEmpty) {
                        await Future.delayed(const Duration(milliseconds: 600));
                        if (!mounted) return;
                        Navigator.pushReplacementNamed(context, next.route!, arguments: next);
                        return;
                      }
                    }
                    if (mounted) Navigator.pop(context, true);
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// 🧩 Màn hình chi tiết level thường
  Widget _buildNormalLevel(BuildContext context, int levelIndex) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ShaderMask(
            shaderCallback: (rect) => const LinearGradient(colors: [Color(0xFF5E2CED), Color(0xFFFF8B00)]).createShader(rect),
            child: Text(
              "Màn chơi ${_currentLevel?.title ?? levelIndex}",
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          const Text("Chưa có nội dung game cụ thể.\nBạn có thể hoàn thành thủ công.",
              textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.white70)),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            icon: const Icon(Icons.check_circle, color: Colors.white),
            label: const Text("Hoàn thành Level"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF8B00),
              foregroundColor: Colors.white,
              minimumSize: const Size(220, 55),
              elevation: 6,
              shadowColor: const Color(0xFFFF8B00).withOpacity(0.4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            onPressed: () async => _completeLevel(context),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            icon: const Icon(Icons.arrow_back),
            label: const Text("Quay lại"),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white70,
              side: const BorderSide(color: Colors.white38),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            ),
            onPressed: () {
              if (mounted) Navigator.pop(context, false);
            },
          ),
        ],
      ),
    );
  }

  /// 🏆 Hoàn thành level và mở khoá + điều hướng tiếp
  Future<void> _completeLevel(BuildContext context) async {
    if (!mounted) return;

    _confettiController.play();
    await _player.play(AssetSource("audios/crown.mp3"));

    // Lấy key hiện tại an toàn
    final currentKey = _currentLevel?.levelKey ?? '';
    if (currentKey.isNotEmpty) {
      await ProgressService.markLevelCompleted(currentKey);
    }

    // Load lại để lấy route next
    _levels = await ProgressService.loadLevels();
    final curIdx = _currentLevel?.index ?? -1;
    final nextIdx = curIdx + 1;

    // Popup chúc mừng
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.emoji_events, color: Colors.amber, size: 60),
            SizedBox(height: 12),
            Text("Hoàn thành xuất sắc!", style: TextStyle(fontSize: 20, color: Colors.white)),
            SizedBox(height: 8),
            Text("Đã mở khóa level tiếp theo 🎯", style: TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    if (nextIdx >= 0 && nextIdx < _levels.length) {
      final next = _levels[nextIdx];
      if ((next.route ?? '').isNotEmpty) {
        Navigator.pushReplacementNamed(context, next.route!, arguments: next); // ✅ truyền object Level
        return;
      }
    }

    // Fallback: quay về map để refresh
    Navigator.pop(context, true);
  }

  /// ✨ Hiệu ứng sao lấp lánh
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
