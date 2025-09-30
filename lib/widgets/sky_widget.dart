import 'dart:math';
import 'package:flutter/material.dart';

class SkyWidget extends StatefulWidget {
  final int currentLevel;

  const SkyWidget({super.key, required this.currentLevel});

  @override
  State<SkyWidget> createState() => _SkyWidgetState();
}

class _SkyWidgetState extends State<SkyWidget> with TickerProviderStateMixin {
  late AnimationController _cloudController;
  late AnimationController _fadeController;
  late AnimationController _swayController;
  late AnimationController _starController;
  late AnimationController _skyBodyController;

  final balloons = [
    "assets/images/balloon1.png",
    "assets/images/balloon2.png",
    "assets/images/balloon3.png",
  ];

  late String _currentBalloon;
  late String _nextBalloon;

  late final List<Offset> _starPositions;

  @override
  void initState() {
    super.initState();

    final rnd = Random();
    _currentBalloon = balloons[rnd.nextInt(balloons.length)];
    _nextBalloon = balloons[rnd.nextInt(balloons.length)];

    _cloudController = AnimationController(vsync: this, duration: const Duration(seconds: 40))..repeat();
    _fadeController = AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _swayController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
    _starController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _skyBodyController = AnimationController(vsync: this, duration: const Duration(seconds: 60))..repeat();

    _starPositions = List.generate(
      20,
          (_) => Offset(rnd.nextDouble() * 400, rnd.nextDouble() * 300),
    );

    Future.delayed(const Duration(seconds: 20), _changeBalloon);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // preload để tránh nháy
    for (final b in balloons) {
      precacheImage(AssetImage(b), context);
    }
    precacheImage(const AssetImage("assets/images/cloud.png"), context);
  }

  void _changeBalloon() {
    final rnd = Random();
    _nextBalloon = balloons[rnd.nextInt(balloons.length)];
    _fadeController.forward(from: 0).whenComplete(() {
      setState(() => _currentBalloon = _nextBalloon);
      Future.delayed(const Duration(seconds: 20), _changeBalloon);
    });
  }

  @override
  void dispose() {
    _cloudController.dispose();
    _fadeController.dispose();
    _swayController.dispose();
    _starController.dispose();
    _skyBodyController.dispose();
    super.dispose();
  }

  List<Color> _getGradient() {
    const night = [Color(0xFF0D47A1), Color(0xFF311B92), Colors.black];
    const day = [Color(0xFFB3E5FC), Color(0xFFE1F5FE), Colors.white];
    final h = DateTime.now().hour;
    return (h >= 6 && h < 18) ? day : night;
  }

  bool _isDayTime() {
    final h = DateTime.now().hour;
    return h >= 6 && h < 18;
  }

  Widget _buildSkyContent(double width) {
    final isDay = _isDayTime();
    final dx = width + 400;
    final offset = _cloudController.value * dx * (1.0 + widget.currentLevel * 0.2);
    final sway = sin(_swayController.value * 2 * pi) * 10;
    final skyBodyX = isDay
        ? _skyBodyController.value * width
        : (1 - _skyBodyController.value) * width;

    return Stack(
      children: [
        // ☀️ / 🌙
        Positioned(
          top: 80,
          left: skyBodyX - 50,
          child: Container(
            width: isDay ? 100 : 80,
            height: isDay ? 100 : 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDay ? Colors.yellow : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: isDay ? Colors.orange : Colors.white,
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),
        ),

        // ✨ Stars
        if (!isDay)
          for (var pos in _starPositions)
            Positioned(
              left: pos.dx,
              top: pos.dy,
              child: FadeTransition(
                opacity: Tween(begin: 0.2, end: 1.0).animate(_starController),
                child: const Icon(Icons.star, color: Colors.white, size: 14),
              ),
            ),

        // ☁️ Clouds
        Positioned(
          left: -300 + offset % dx,
          top: 80,
          child: Image.asset(
            "assets/images/cloud.png",
            width: 130,
            gaplessPlayback: true,
          ),
        ),
        Positioned(
          right: -250 + offset % dx,
          top: 240,
          child: Image.asset(
            "assets/images/cloud.png",
            width: 90,
            gaplessPlayback: true,
          ),
        ),
        Positioned(
          left: -200 + (offset * 1.5) % dx,
          top: 380,
          child: Image.asset(
            "assets/images/cloud.png",
            width: 110,
            gaplessPlayback: true,
          ),
        ),

        // 🎈 Balloon
        Positioned(
          left: (offset * 0.3) % dx + sway,
          top: 60 + (offset * 0.1) % 200,
          child: Stack(
            children: [
              Image.asset(
                _currentBalloon,
                width: 100,
                gaplessPlayback: true,
              ),
              FadeTransition(
                opacity: _fadeController,
                child: Image.asset(
                  _nextBalloon,
                  width: 100,
                  gaplessPlayback: true,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return SizedBox.expand(
      child: Stack(
        children: [
          /// 👉 Nền fallback trắng chống nháy xám
          Positioned.fill(
            child: Container(color: Colors.white),
          ),

          /// Gradient + animation
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: _getGradient(),
                ),
              ),
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _cloudController,
                  _swayController,
                  _starController,
                  _skyBodyController,
                ]),
                builder: (context, _) {
                  return _buildSkyContent(width);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
