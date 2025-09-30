import 'dart:math';
import 'package:flutter/material.dart';

class MapBackground extends StatefulWidget {
  final ScrollController scrollController;
  final int currentLevel;
  const MapBackground({super.key, required this.scrollController, required this.currentLevel});

  @override
  State<MapBackground> createState() => _MapBackgroundState();
}

class CloudConfig {
  final double top;
  final double size;
  final double speed;
  final double opacity;
  CloudConfig({required this.top, required this.size, required this.speed, required this.opacity});
}

class FallingItem {
  final IconData icon;
  final Color color;
  final double startX;
  final double size;
  final AnimationController controller;

  FallingItem({
    required this.icon,
    required this.color,
    required this.startX,
    required this.size,
    required this.controller,
  });
}

class ShootingStar {
  final AnimationController controller;
  final double startX;
  final double startY;
  ShootingStar({required this.controller, required this.startX, required this.startY});
}

class _MapBackgroundState extends State<MapBackground> with TickerProviderStateMixin {
  late bool isNight;

  late AnimationController _fadeController;
  late AnimationController _swayController;
  late AnimationController _starController;
  late AnimationController _skyBodyController;
  late AnimationController _cloudController;

  final balloons = [
    "assets/images/balloon1.png",
    "assets/images/balloon2.png",
    "assets/images/balloon3.png",
  ];

  late String _currentBalloon;
  late String _nextBalloon;
  double _balloonYOffset = 0;

  late final List<Offset> _starPositions;
  late final List<Offset> _sparklePositions;
  final List<FallingItem> _fallingItems = [];

  late final List<CloudConfig> _clouds;
  final List<ShootingStar> _shootingStars = []; // 🌠 danh sách sao băng

  @override
  void initState() {
    super.initState();
    final hour = DateTime.now().hour;
    isNight = hour >= 18 || hour < 6;

    final rnd = Random();
    _currentBalloon = balloons[rnd.nextInt(balloons.length)];
    _nextBalloon = balloons[rnd.nextInt(balloons.length)];
    _balloonYOffset = 50 + rnd.nextDouble() * 120;

    _fadeController = AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _swayController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
    _starController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _skyBodyController = AnimationController(vsync: this, duration: const Duration(seconds: 60))..repeat();
    _cloudController = AnimationController(vsync: this, duration: const Duration(seconds: 120))..repeat();

    _starPositions = List.generate(20, (_) => Offset(rnd.nextDouble() * 400, rnd.nextDouble() * 300));
    _sparklePositions = List.generate(
      8,
          (_) {
        final angle = rnd.nextDouble() * 2 * pi;
        final r = 60 + rnd.nextDouble() * 30;
        return Offset(cos(angle) * r, sin(angle) * r);
      },
    );

    _clouds = List.generate(6 + rnd.nextInt(3), (_) {
      return CloudConfig(
        top: 80 + rnd.nextDouble() * 300,
        size: 100 + rnd.nextDouble() * 150,
        speed: 0.2 + rnd.nextDouble() * 0.8,
        opacity: 0.4 + rnd.nextDouble() * 0.6,
      );
    });

    Future.delayed(const Duration(seconds: 20), _changeBalloon);
    _startAutoSpawn();
    _startShootingStar(); // 🌠 bắt đầu spawn sao băng

    // auto update ngày ↔ đêm
    Future.doWhile(() async {
      await Future.delayed(const Duration(minutes: 1));
      if (!mounted) return false;
      final hourNow = DateTime.now().hour;
      final newIsNight = hourNow >= 18 || hourNow < 6;
      if (newIsNight != isNight) {
        setState(() => isNight = newIsNight);
      }
      return mounted;
    });
  }

  void _startAutoSpawn() {
    final rnd = Random();
    Future.delayed(Duration(seconds: 3 + rnd.nextInt(3)), () {
      if (!mounted) return;
      final balloonX = MediaQuery.of(context).size.width / 2;
      _spawnFallingItem(balloonX);
      _startAutoSpawn();
    });
  }

  void _spawnFallingItem(double balloonX) {
    final rnd = Random();
    final isHeart = rnd.nextBool();

    final controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..forward();

    final item = FallingItem(
      icon: isHeart ? Icons.favorite : Icons.star,
      color: isHeart ? Colors.pinkAccent : Colors.amber,
      startX: balloonX + rnd.nextDouble() * 80 - 40,
      size: 14 + rnd.nextDouble() * 8,
      controller: controller,
    );

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _fallingItems.remove(item);
        controller.dispose();
      }
    });

    setState(() => _fallingItems.add(item));
  }

  void _startShootingStar() {
    final rnd = Random();
    Future.delayed(Duration(seconds: 8 + rnd.nextInt(12)), () {
      if (!mounted) return;
      if (isNight) {
        final width = MediaQuery.of(context).size.width;
        final startX = rnd.nextDouble() * width * 0.5;
        final startY = rnd.nextDouble() * 200.0;

        final controller = AnimationController(
          vsync: this,
          duration: const Duration(seconds: 2),
        )..forward();

        final star = ShootingStar(controller: controller, startX: startX, startY: startY);

        controller.addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            _shootingStars.remove(star);
            controller.dispose();
          }
        });

        setState(() => _shootingStars.add(star));
      }
      _startShootingStar(); // loop
    });
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
    _fadeController.dispose();
    _swayController.dispose();
    _starController.dispose();
    _skyBodyController.dispose();
    _cloudController.dispose();
    for (var item in _fallingItems) {
      item.controller.dispose();
    }
    for (var star in _shootingStars) {
      star.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final skyBodyX = isNight
        ? (1 - _skyBodyController.value) * width
        : _skyBodyController.value * width;
    final sway = sin(_swayController.value * 2 * pi) * 10;

    return AnimatedSwitcher(
      duration: const Duration(seconds: 2),
      child: Stack(
        key: ValueKey(isNight ? "night" : "day"),
        children: [
          // 🌅 Gradient
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isNight
                    ? const [Color(0xFF0D1B2A), Color(0xFF1B263B)]
                    : const [Color(0xFFE1F5FE), Color(0xFFFFF9C4)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // ☀️/🌙 Sun/Moon + sparkles
          Positioned(
            top: 80,
            left: skyBodyX - 60,
            child: Stack(
              children: [
                Image.asset(isNight ? 'assets/images/moon.png' : 'assets/images/sun.png',
                    width: 120),
                for (var pos in _sparklePositions)
                  Positioned(
                    left: 60 + pos.dx,
                    top: 60 + pos.dy,
                    child: ScaleTransition(
                      scale: Tween(begin: 0.5, end: 1.2).animate(
                        CurvedAnimation(parent: _starController, curve: Curves.easeInOut),
                      ),
                      child: Icon(Icons.star,
                          size: 10,
                          color: isNight ? Colors.yellowAccent : Colors.white70),
                    ),
                  ),
              ],
            ),
          ),

          // ✨ Stars ban đêm
          if (isNight)
            for (var pos in _starPositions)
              Positioned(
                left: pos.dx,
                top: pos.dy,
                child: FadeTransition(
                  opacity: Tween(begin: 0.2, end: 1.0).animate(_starController),
                  child: const Icon(Icons.star, color: Colors.white, size: 14),
                ),
              ),

          // 🌠 Shooting stars
          for (var star in _shootingStars)
            AnimatedBuilder(
              animation: star.controller,
              builder: (context, _) {
                final progress = star.controller.value;
                return Positioned(
                  left: star.startX + progress * 300,
                  top: star.startY + progress * 150,
                  child: Opacity(
                    opacity: 1 - progress,
                    child: Icon(Icons.star, color: Colors.white, size: 12),
                  ),
                );
              },
            ),

          // 🎈 Balloon
          Positioned(
            left: (width * 0.4) + sway,
            top: 160 + _balloonYOffset,
            child: Stack(
              children: [
                Image.asset(_currentBalloon, width: 100, gaplessPlayback: true),
                FadeTransition(
                  opacity: _fadeController,
                  child: Image.asset(_nextBalloon, width: 100, gaplessPlayback: true),
                ),
              ],
            ),
          ),

          // ❤️ Falling items
          for (var item in _fallingItems)
            AnimatedBuilder(
              animation: item.controller,
              builder: (context, _) {
                final progress = item.controller.value;
                return Positioned(
                  left: item.startX,
                  top: 200 + progress * 400,
                  child: Opacity(
                    opacity: 1 - progress,
                    child: Icon(item.icon, color: item.color, size: item.size),
                  ),
                );
              },
            ),

          // ☁️ Clouds random parallax + opacity
          AnimatedBuilder(
            animation: _cloudController,
            builder: (context, _) {
              final base = _cloudController.value * (width + 800);
              return Stack(
                children: [
                  for (var cloud in _clouds)
                    Positioned(
                      left: -400 + (base * cloud.speed) % (width + 800),
                      top: cloud.top,
                      child: Opacity(
                        opacity: cloud.opacity,
                        child: Image.asset("assets/images/cloud.png", width: cloud.size),
                      ),
                    ),
                ],
              );
            },
          ),

          // 🏔️ Mountains
          _Mountains(isNight: isNight),
        ],
      ),
    );
  }
}

class _Mountains extends StatelessWidget {
  final bool isNight;
  const _Mountains({required this.isNight});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Image.asset(
        'assets/images/mountains_layer1.png',
        fit: BoxFit.cover,
        height: size.height * 0.3,
      ),
    );
  }
}
