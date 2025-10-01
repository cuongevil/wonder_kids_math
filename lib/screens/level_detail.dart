import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';

import '../widgets/app_scaffold.dart';

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
  late AnimationController _floatingController; // 🎈 Trái tim + bóng bay

  final AudioPlayer _player = AudioPlayer();
  final Random _random = Random();

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

    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    /// 🔹 Phát confetti và âm thanh ngay khi mở màn
    Future.delayed(const Duration(milliseconds: 300), () {
      _confettiController.play();
      _player.play(AssetSource("audios/welcome.mp3"));
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _bounceController.dispose();
    _sparkleController.dispose();
    _floatingController.dispose();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int? levelIndex =
    ModalRoute.of(context)?.settings.arguments as int?;
    final bool isStartLevel = levelIndex == 0;

    return AppScaffold(
      title: isStartLevel ? "Chào mừng!" : "Chi tiết Level $levelIndex",
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB3E5FC), Color(0xFFE1BEE7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
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
                    Colors.green
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 🔹 UI đặc biệt cho Level 0 (Start)
  Widget _buildStartScreen(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Stack(
        alignment: Alignment.center,
        children: [
          /// 🎈 Trái tim & bóng bay bay lên
          Positioned.fill(child: _buildFloatingItems()),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Mascot bounce + sparkle
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
                style: TextStyle(fontSize: 18, color: Colors.black87),
              ),
              const SizedBox(height: 40),
              _buildStartButton(context),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Bỏ qua"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 🔹 Nút bắt đầu
  Widget _buildStartButton(BuildContext context) {
    return Container(
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
          _confettiController.play();
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.pop(context, true); // báo Completed cho Map
          });
        },
      ),
    );
  }

  /// 🔹 UI mặc định cho các level khác
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

  /// 🔹 Hiệu ứng sparkle quanh mascot
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

  /// 🔹 Trái tim & bóng bay bay lên
  Widget _buildFloatingItems() {
    return AnimatedBuilder(
      animation: _floatingController,
      builder: (context, child) {
        final items = List.generate(6, (i) {
          final progress =
              (_floatingController.value + i * 0.2) % 1.0; // 0..1
          final dx = _random.nextDouble() *
              MediaQuery.of(context).size.width; // random vị trí X
          final dy =
              MediaQuery.of(context).size.height * (1 - progress); // bay lên
          final isHeart = i % 2 == 0;

          return Positioned(
            left: dx,
            top: dy,
            child: Opacity(
              opacity: (1 - progress),
              child: Icon(
                isHeart ? Icons.favorite : Icons.circle,
                size: isHeart ? 24 : 30,
                color: isHeart
                    ? Colors.pinkAccent.withOpacity(0.8)
                    : Colors.lightBlueAccent.withOpacity(0.7),
              ),
            ),
          );
        });

        return Stack(children: items);
      },
    );
  }
}
