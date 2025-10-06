import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import '../services/progress_service.dart';
import '../models/level.dart';
import 'base_screen.dart';

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
  final AudioPlayer _player = AudioPlayer();

  int? levelIndex;
  List<Level> _levels = [];

  @override
  void initState() {
    super.initState();

    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));

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

    // 🔹 Delay nhỏ nhưng kiểm tra mounted trước khi chạy animation
    Future.delayed(const Duration(milliseconds: 300), () async {
      if (!mounted) return;
      _confettiController.play();
      await _player.play(AssetSource("audios/welcome.mp3"));
    });
  }

  @override
  void dispose() {
    _bounceController.stop();
    _sparkleController.stop();
    _confettiController.stop();

    _bounceController.dispose();
    _sparkleController.dispose();
    _confettiController.dispose();
    _player.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    levelIndex = ModalRoute.of(context)?.settings.arguments as int?;
    final bool isStartLevel = levelIndex == 0;

    return BaseScreen(
      title: isStartLevel ? "Bắt đầu" : "Chi tiết Level $levelIndex",
      child: Stack(
        children: [
          Center(
            child: isStartLevel
                ? _buildStartScreen(context)
                : _buildNormalLevel(context, levelIndex ?? -1),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 25,
              gravity: 0.3,
              colors: const [
                Colors.pink,
                Colors.blue,
                Colors.yellow,
                Colors.green,
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 Màn hình mở đầu (Level 0)
  Widget _buildStartScreen(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              _buildSparkle(80, 1.0, Colors.yellowAccent),
              _buildSparkle(60, -1.5, Colors.pinkAccent),
              ScaleTransition(
                scale: _bounceController,
                child: Image.asset(
                  "assets/images/mascot/mascot_10.png",
                  width: 160,
                  height: 160,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            "Xin chào 👋",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.deepOrange,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Cùng học số và phép tính thật vui nhé!",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.lightGreenAccent),
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            icon: const Icon(Icons.play_arrow, color: Colors.white, size: 28),
            label: const Text(
              "Bắt đầu thôi!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              minimumSize: const Size(200, 55),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: () async {
              if (!mounted) return;

              _confettiController.play();
              await _player.play(AssetSource("audios/crown.mp3"));

              // 🔹 Cập nhật trạng thái: Level 0 hoàn thành, Level 1 playable
              _levels = await ProgressService.ensureDefaultLevels(() => []);
              await ProgressService.markLevelCompleted("start");

              // 🔹 Chờ hiệu ứng rồi quay lại Map
              await Future.delayed(const Duration(seconds: 2));
              if (mounted) Navigator.pop(context, true);
            },
          ),
        ],
      ),
    );
  }

  /// 🔹 Màn hình chi tiết level thường
  Widget _buildNormalLevel(BuildContext context, int levelIndex) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Đây là màn chơi số $levelIndex",
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            "Chưa có game cụ thể, bạn có thể hoàn thành thủ công.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            icon: const Icon(Icons.check_circle, color: Colors.white),
            label: const Text("Hoàn thành Level"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              minimumSize: const Size(200, 55),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            onPressed: () async {
              await _completeLevel(context, levelIndex);
            },
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            icon: const Icon(Icons.arrow_back),
            label: const Text("Quay lại"),
            onPressed: () {
              if (mounted) Navigator.pop(context, false);
            },
          ),
        ],
      ),
    );
  }

  /// 🔹 Hoàn thành level và mở khoá kế tiếp
  Future<void> _completeLevel(BuildContext context, int index) async {
    if (!mounted) return;
    _confettiController.play();
    await _player.play(AssetSource("audios/crown.mp3"));

    _levels = await ProgressService.ensureDefaultLevels(() => []);

    await ProgressService.markLevelCompleted("addition10");

    await Future.delayed(const Duration(seconds: 2));
    if (mounted) Navigator.pop(context, true);
  }

  /// 🔹 Hiệu ứng sao lấp lánh
  Widget _buildSparkle(double radius, double speed, Color color) {
    return AnimatedBuilder(
      animation: _sparkleController,
      builder: (context, child) {
        final angle = _sparkleController.value * 2 * pi * speed;
        final dx = cos(angle) * radius;
        final dy = sin(angle) * radius;
        return Transform.translate(
          offset: Offset(dx, dy),
          child: Icon(Icons.star, color: color.withOpacity(0.7), size: 18),
        );
      },
    );
  }
}
