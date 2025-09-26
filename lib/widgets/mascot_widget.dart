import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/audio_service.dart';
import '../models/mascot_mood.dart';

class MascotWidget extends StatefulWidget {
  final MascotMood mood;

  const MascotWidget({super.key, this.mood = MascotMood.idle});

  @override
  State<MascotWidget> createState() => _MascotWidgetState();
}

class _MascotWidgetState extends State<MascotWidget>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _orbitController;
  late AnimationController _glowController;
  late AnimationController _rotateController;
  late Animation<double> _scaleAnimation;

  final List<String> _expressions = [
    "assets/images/mascot/mascot.png",
    "assets/images/mascot/mascot_1.png",
    "assets/images/mascot/mascot_2.png",
    "assets/images/mascot/mascot_3.png",
    "assets/images/mascot/mascot_4.png",
    "assets/images/mascot/mascot_5.png",
    "assets/images/mascot/mascot_6.png",
    "assets/images/mascot/mascot_7.png",
    "assets/images/mascot/mascot_8.png",
    "assets/images/mascot/mascot_9.png",
    "assets/images/mascot/mascot_10.png",
  ];
  late String _currentExpression;
  Timer? _expressionTimer;

  @override
  void initState() {
    super.initState();
    _currentExpression = _expressions.first;

    _bounceController =
    AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat();

    _orbitController =
    AnimationController(vsync: this, duration: const Duration(seconds: 8))
      ..repeat();

    _glowController =
    AnimationController(vsync: this, duration: const Duration(seconds: 4))
      ..repeat(reverse: true);

    _rotateController =
    AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    _expressionTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      setState(() {
        _currentExpression = (_expressions..shuffle()).first;
      });
    });
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _orbitController.dispose();
    _glowController.dispose();
    _rotateController.dispose();
    _expressionTimer?.cancel();
    super.dispose();
  }

  /// 🌈 chọn màu gradient theo trạng thái
  List<Color> _getMoodColors() {
    switch (widget.mood) {
      case MascotMood.happy:
        return [Colors.greenAccent.withOpacity(0.6), Colors.blueAccent.withOpacity(0.3)];
      case MascotMood.sad:
        return [Colors.grey.withOpacity(0.6), Colors.blueGrey.withOpacity(0.3)];
      case MascotMood.celebrate:
        return [
          Colors.redAccent.withOpacity(0.6),
          Colors.orangeAccent.withOpacity(0.6),
          Colors.yellowAccent.withOpacity(0.6),
          Colors.greenAccent.withOpacity(0.6),
          Colors.blueAccent.withOpacity(0.6),
          Colors.purpleAccent.withOpacity(0.6),
        ];
      default:
        return [Colors.yellow.withOpacity(0.6), Colors.pink.withOpacity(0.3)];
    }
  }

  Widget _floatingHearts() {
    return SizedBox(
      height: 40,
      child: Stack(
        alignment: Alignment.center,
        children: List.generate(3, (i) {
          final dx = (i - 1) * 40.0;
          return AnimatedBuilder(
            animation: _bounceController,
            builder: (_, __) {
              final offsetY =
                  math.sin(_bounceController.value * 2 * math.pi + i) * 8;
              return Transform.translate(
                offset: Offset(dx, offsetY),
                child: const Icon(Icons.favorite,
                    color: Colors.pinkAccent, size: 18),
              );
            },
          );
        }),
      ),
    );
  }

  Widget _floatingStars() {
    return SizedBox(
      height: 40,
      child: Stack(
        alignment: Alignment.center,
        children: List.generate(3, (i) {
          final dx = (i - 1) * 40.0;
          return AnimatedBuilder(
            animation: _bounceController,
            builder: (_, __) {
              final offsetY =
                  math.cos(_bounceController.value * 2 * math.pi + i) * 8;
              return Transform.translate(
                offset: Offset(dx, offsetY),
                child: const Icon(Icons.star, color: Colors.yellow, size: 20),
              );
            },
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget mascotImg = AnimatedBuilder(
      animation: _bounceController,
      builder: (context, child) {
        final offset =
            math.sin(_bounceController.value * 2 * math.pi) * 8; // nhảy
        return Transform.translate(offset: Offset(0, offset), child: child);
      },
      child: Image.asset(_currentExpression, height: 120),
    );

    switch (widget.mood) {
      case MascotMood.happy:
        mascotImg = Column(children: [
          _floatingHearts(),
          ScaleTransition(scale: _scaleAnimation, child: mascotImg),
        ]);
        break;
      case MascotMood.sad:
        mascotImg = Column(children: [
          const Icon(Icons.cloud, color: Colors.grey, size: 30),
          Opacity(opacity: 0.6, child: mascotImg),
        ]);
        break;
      case MascotMood.celebrate:
        mascotImg = Column(children: [
          _floatingStars(),
          RotationTransition(
            turns: Tween<double>(begin: -0.05, end: 0.05).animate(
              CurvedAnimation(
                parent: _rotateController,
                curve: Curves.elasticInOut,
              ),
            ),
            child: mascotImg,
          ),
        ]);
        break;
      default:
        break;
    }

    return Hero(
      tag: "mascot",
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          AudioService.play("correct.mp3");
          _bounceController.forward(from: 0.0);
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 🌈 Glow đổi màu theo mood
            AnimatedBuilder(
              animation: _glowController,
              builder: (context, child) {
                final scale = 1 + 0.2 * _glowController.value;
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: _getMoodColors(),
                        stops: const [0.2, 0.8],
                      ),
                    ),
                  ),
                );
              },
            ),
            mascotImg,
          ],
        ),
      ),
    );
  }
}
