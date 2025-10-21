import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

class MapBackground extends StatefulWidget {
  final ScrollController scrollController;
  final int currentLevel;

  const MapBackground({
    super.key,
    required this.scrollController,
    required this.currentLevel,
  });

  @override
  State<MapBackground> createState() => _MapBackgroundState();
}

class CloudConfig {
  final double top;
  final double size;
  final double speed;
  final double opacity;

  CloudConfig({
    required this.top,
    required this.size,
    required this.speed,
    required this.opacity,
  });
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

  ShootingStar({
    required this.controller,
    required this.startX,
    required this.startY,
  });
}

class _MapBackgroundState extends State<MapBackground>
    with TickerProviderStateMixin {
  late bool isNight;

  // 🌈 Controllers
  late AnimationController _overlayController;
  late AnimationController _glowController;
  late AnimationController _skyBodyController;
  late AnimationController _swayController;
  late AnimationController _cloudController;

  final List<CloudConfig> _clouds = [];
  final List<ShootingStar> _shootingStars = [];
  final List<FallingItem> _fallingItems = [];
  final balloons = [
    "assets/images/balloon1.png",
    "assets/images/balloon2.png",
    "assets/images/balloon3.png",
  ];

  late String _currentBalloon;
  late String _nextBalloon;
  late AnimationController _fadeController;
  double _balloonYOffset = 0;

  @override
  void initState() {
    super.initState();
    final rnd = Random();
    final hour = DateTime.now().hour;
    isNight = hour >= 18 || hour < 6;

    // 🌫 breathing overlay (day/night speed khác nhau)
    _overlayController = AnimationController(
      vsync: this,
      duration: Duration(seconds: isNight ? 3 : 6),
    )..repeat(reverse: true);

    // 🌈 tím–cam ánh sáng chậm
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(reverse: true);

    // ☀️ / 🌙 di chuyển chậm
    _skyBodyController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();

    // 🌬 Mây bay
    _cloudController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 120),
    )..repeat();

    // 🎈 Balloon fade
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _swayController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    // 🌥 Tạo mây ngẫu nhiên
    for (int i = 0; i < 6 + rnd.nextInt(3); i++) {
      _clouds.add(CloudConfig(
        top: 80 + rnd.nextDouble() * 300,
        size: 100 + rnd.nextDouble() * 150,
        speed: 0.3 + rnd.nextDouble() * 0.7,
        opacity: 0.4 + rnd.nextDouble() * 0.6,
      ));
    }

    // 🎈 Balloon khởi tạo
    _currentBalloon = balloons[rnd.nextInt(balloons.length)];
    _nextBalloon = balloons[rnd.nextInt(balloons.length)];
    _balloonYOffset = 50 + rnd.nextDouble() * 120;

    Future.delayed(const Duration(seconds: 20), _changeBalloon);
    _spawnAutoFallingItem();
    _spawnShootingStar();

    // Tự động chuyển ngày / đêm
    Future.doWhile(() async {
      await Future.delayed(const Duration(minutes: 1));
      if (!mounted) return false;
      final newNight = DateTime.now().hour >= 18 || DateTime.now().hour < 6;
      if (newNight != isNight) {
        setState(() {
          isNight = newNight;
          _overlayController.duration = Duration(seconds: isNight ? 3 : 6);
          _overlayController.reset();
          _overlayController.repeat(reverse: true);
        });
      }
      return mounted;
    });
  }

  // ❤️ Spawn item rơi nhẹ
  void _spawnAutoFallingItem() {
    final rnd = Random();
    Future.delayed(Duration(seconds: 3 + rnd.nextInt(4)), () {
      if (!mounted) return;
      final screenW = MediaQuery.of(context).size.width;
      final controller = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 4),
      )..forward();

      final item = FallingItem(
        icon: rnd.nextBool() ? Icons.favorite : Icons.star,
        color: rnd.nextBool() ? Colors.pinkAccent : Colors.amberAccent,
        startX: screenW / 2 + rnd.nextDouble() * 80 - 40,
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
      _spawnAutoFallingItem();
    });
  }

  // 🌠 Sao băng
  void _spawnShootingStar() {
    final rnd = Random();
    Future.delayed(Duration(seconds: 8 + rnd.nextInt(10)), () {
      if (!mounted) return;
      if (isNight) {
        final width = MediaQuery.of(context).size.width;
        final startX = rnd.nextDouble() * width * 0.5;
        final startY = rnd.nextDouble() * 200.0;
        final controller = AnimationController(
          vsync: this,
          duration: const Duration(seconds: 2),
        )..forward();

        final star = ShootingStar(
          controller: controller,
          startX: startX,
          startY: startY,
        );

        controller.addStatusListener((s) {
          if (s == AnimationStatus.completed) {
            _shootingStars.remove(star);
            controller.dispose();
          }
        });

        setState(() => _shootingStars.add(star));
      }
      _spawnShootingStar();
    });
  }

  // 🎈 Thay balloon
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
    _overlayController.dispose();
    _glowController.dispose();
    _skyBodyController.dispose();
    _swayController.dispose();
    _fadeController.dispose();
    _cloudController.dispose();
    for (var f in _fallingItems) {
      f.controller.dispose();
    }
    for (var s in _shootingStars) {
      s.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final sway = sin(_swayController.value * 2 * pi) * 10;
    final skyBodyX = isNight
        ? (1 - _skyBodyController.value) * width
        : _skyBodyController.value * width;

    return AnimatedBuilder(
      animation:
      Listenable.merge([_overlayController, _glowController, _cloudController]),
      builder: (context, _) {
        final glowShift = sin(_glowController.value * 2 * pi) * 0.5 + 0.5;
        final breath =
            sin(_overlayController.value * 2 * pi) * (isNight ? 0.06 : 0.03);
        final baseColors = isNight
            ? const [Color(0xFF0D1B2A), Color(0xFF1B263B)]
            : const [Color(0xFFE1F5FE), Color(0xFFFFF9C4)];

        final overlayGradient = LinearGradient(
          colors: [
            AppTheme.tpPurple.withOpacity(0.3 + breath),
            AppTheme.tpOrange.withOpacity(0.3 - breath),
          ],
          begin: Alignment(-1.0 + glowShift, -1.0),
          end: Alignment(1.0 - glowShift, 1.0),
        );

        return Stack(
          children: [
            // 🌅 Base sky gradient
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: baseColors,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            // 🌈 Moving purple-orange light overlay
            Container(
              decoration: BoxDecoration(
                gradient: overlayGradient,
                backgroundBlendMode: BlendMode.screen,
              ),
            ),

            // ☀️ or 🌙
            Positioned(
              top: 80,
              left: skyBodyX - 60,
              child: Image.asset(
                isNight
                    ? 'assets/images/moon.png'
                    : 'assets/images/sun.png',
                width: 120,
                opacity: const AlwaysStoppedAnimation(0.9),
              ),
            ),

            // ☁️ Clouds moving slowly
            AnimatedBuilder(
              animation: _cloudController,
              builder: (_, __) {
                final base = _cloudController.value * (width + 800);
                return Stack(
                  children: [
                    for (var c in _clouds)
                      Positioned(
                        left: -400 + (base * c.speed) % (width + 800),
                        top: c.top,
                        child: Opacity(
                          opacity: c.opacity,
                          child: Image.asset(
                            "assets/images/cloud.png",
                            width: c.size,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),

            // 🌠 Shooting stars
            for (var star in _shootingStars)
              AnimatedBuilder(
                animation: star.controller,
                builder: (context, _) {
                  final t = star.controller.value;
                  return Positioned(
                    left: star.startX + t * 300,
                    top: star.startY + t * 150,
                    child: Opacity(
                      opacity: 1 - t,
                      child:
                      const Icon(Icons.star, color: Colors.white, size: 12),
                    ),
                  );
                },
              ),

            // 🎈 Balloon with sway and fade transition
            Positioned(
              left: (width * 0.4) + sway,
              top: 160 + _balloonYOffset,
              child: Stack(
                children: [
                  Image.asset(_currentBalloon,
                      width: 100, gaplessPlayback: true),
                  FadeTransition(
                    opacity: _fadeController,
                    child: Image.asset(_nextBalloon,
                        width: 100, gaplessPlayback: true),
                  ),
                ],
              ),
            ),

            // ❤️ Falling items
            for (var item in _fallingItems)
              AnimatedBuilder(
                animation: item.controller,
                builder: (context, _) {
                  final t = item.controller.value;
                  return Positioned(
                    left: item.startX,
                    top: 200 + t * 400,
                    child: Opacity(
                      opacity: 1 - t,
                      child: Icon(item.icon,
                          color: item.color, size: item.size),
                    ),
                  );
                },
              ),

            // 🌫 Breathing blur overlay
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: Container(
                  color: isNight
                      ? Colors.black.withOpacity(0.25 + breath.abs())
                      : Colors.white.withOpacity(0.10 + breath.abs()),
                ),
              ),
            ),

            // 🏔️ Mountains base layer
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Image.asset(
                'assets/images/mountains_layer1.png',
                fit: BoxFit.cover,
                height: MediaQuery.of(context).size.height * 0.3,
              ),
            ),
          ],
        );
      },
    );
  }
}
