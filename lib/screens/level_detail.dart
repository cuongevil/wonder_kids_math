import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import 'base_screen.dart'; // 🔹 dùng BaseScreen

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

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

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

    /// 🔹 Phát confetti và âm thanh ngay khi mở màn (sau 300ms)
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _confettiController.play();
        _player.play(AssetSource("audios/welcome.mp3"));
      }
    });
  }

  @override
  void dispose() {
    _bounceController.stop();
    _sparkleController.stop();
    _confettiController.stop();

    _confettiController.dispose();
    _bounceController.dispose();
    _sparkleController.dispose();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int? levelIndex = ModalRoute.of(context)?.settings.arguments as int?;
    final bool isStartLevel = levelIndex == 0;

    return BaseScreen(
      title: isStartLevel ? "Xin chào" : "Chi tiết Level $levelIndex",
      child: Stack(
        children: [
          Center(
            child: isStartLevel
                ? _buildStartScreen(context)
                : _buildNormalLevel(context, levelIndex ?? -1),
          ),
          if (isStartLevel)
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

  /// 🔹 UI đặc biệt cho Level 0 (Start)
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
            textAlign: TextAlign.center,
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
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.6),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
              borderRadius: BorderRadius.circular(30),
            ),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow, color: Colors.white, size: 28),
              label: const Text(
                "Bắt đầu",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: const Size(200, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                if (mounted) {
                  _confettiController.play();
                }
                Future.delayed(const Duration(seconds: 2), () {
                  if (mounted) Navigator.pop(context, true);
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 UI mặc định cho level thường
  Widget _buildNormalLevel(BuildContext context, int levelIndex) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Đây là màn chơi số $levelIndex",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          const Text(
            "Hiện chưa có game cụ thể.\nBạn có thể hoàn thành thủ công.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            icon: const Icon(Icons.check_circle),
            label: const Text("Hoàn thành"),
            onPressed: () {
              Navigator.pop(context, true);
            },
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            icon: const Icon(Icons.arrow_back),
            label: const Text("Quay lại"),
            onPressed: () {
              Navigator.pop(context, false);
            },
          ),
        ],
      ),
    );
  }

  /// 🔹 Hiệu ứng lấp lánh
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
