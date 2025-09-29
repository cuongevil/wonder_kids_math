import 'dart:math';
import 'package:flutter/material.dart';

/// 🌥️☁️🎈 SkyWidget: Mây + Khinh khí cầu đổi màu + lắc nhẹ
class SkyWidget extends StatefulWidget {
  final int currentLevel;

  const SkyWidget({super.key, required this.currentLevel});

  @override
  State<SkyWidget> createState() => _SkyWidgetState();
}

class _SkyWidgetState extends State<SkyWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _fadeController;
  late AnimationController _swayController;

  final balloons = [
    "assets/images/balloon1.png",
    "assets/images/balloon2.png",
    "assets/images/balloon3.png",
  ];

  late String _currentBalloon;
  late String _nextBalloon;

  @override
  void initState() {
    super.initState();

    final rnd = Random();
    _currentBalloon = balloons[rnd.nextInt(balloons.length)];
    _nextBalloon = balloons[rnd.nextInt(balloons.length)];

    // control bay ngang
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();

    // control fade đổi màu balloon
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    // control lắc nhẹ
    _swayController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    // đổi balloon mỗi 20 giây
    Future.delayed(const Duration(seconds: 20), _changeBalloon);
  }

  void _changeBalloon() {
    final rnd = Random();
    _nextBalloon = balloons[rnd.nextInt(balloons.length)];

    _fadeController.forward(from: 0).whenComplete(() {
      setState(() {
        _currentBalloon = _nextBalloon;
      });
      Future.delayed(const Duration(seconds: 20), _changeBalloon);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _fadeController.dispose();
    _swayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final speedFactor = 1.0 + (widget.currentLevel * 0.2);
    final opacityFactor = (1.0 - widget.currentLevel * 0.05).clamp(0.3, 1.0);

    return AnimatedBuilder(
      animation: Listenable.merge([_controller, _swayController]),
      builder: (context, child) {
        final dx = width + 400;
        final offset = _controller.value * dx * speedFactor;

        // dao động qua lại
        final sway = sin(_swayController.value * 2 * pi) * 10;

        return Stack(
          children: [
            // ☁️ Mây lớn
            Positioned(
              left: -300 + offset % dx,
              top: 80,
              child: Opacity(
                opacity: 0.9 * opacityFactor,
                child: Image.asset("assets/images/cloud.png", width: 130),
              ),
            ),

            // ☁️ Mây nhỏ
            Positioned(
              right: -250 + offset % dx,
              top: 240,
              child: Opacity(
                opacity: 0.7 * opacityFactor,
                child: Image.asset("assets/images/cloud.png", width: 90),
              ),
            ),

            // ☁️ Mây trung bình
            Positioned(
              left: -200 + (offset * 1.5) % dx,
              top: 380,
              child: Opacity(
                opacity: 0.8 * opacityFactor,
                child: Image.asset("assets/images/cloud.png", width: 110),
              ),
            ),

            // 🎈 Khinh khí cầu bay chậm + đổi màu + lắc nhẹ
            Positioned(
              left: (offset * 0.3) % dx + sway,
              top: 60 + (offset * 0.1) % 200,
              child: Stack(
                children: [
                  Image.asset(_currentBalloon, width: 100),
                  FadeTransition(
                    opacity: _fadeController,
                    child: Image.asset(_nextBalloon, width: 100),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
