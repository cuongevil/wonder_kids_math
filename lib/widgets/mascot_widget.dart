import 'package:flutter/material.dart';
import 'dart:math' as math;

class MascotWidget extends StatefulWidget {
  final Offset? position; // vị trí mascot di chuyển theo path
  final double size;
  final String assetPath;

  const MascotWidget({
    super.key,
    this.position,
    this.size = 80,
    this.assetPath = 'assets/images/mascot/mascot.png',
  });

  @override
  State<MascotWidget> createState() => _MascotWidgetState();
}

class _MascotWidgetState extends State<MascotWidget>
    with TickerProviderStateMixin {
  late AnimationController _idleController;
  late Animation<double> _jumpAnimation;
  late Animation<double> _tiltAnimation;

  late AnimationController _waveController;
  late Animation<double> _waveTilt;
  late Animation<double> _waveScale;

  @override
  void initState() {
    super.initState();

    // 🟢 Idle animation (nhảy + nghiêng)
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _jumpAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _idleController, curve: Curves.easeInOutBack),
    );

    _tiltAnimation = Tween<double>(begin: -5, end: 5).animate(
      CurvedAnimation(parent: _idleController, curve: Curves.easeInOut),
    );

    // 👋 Wave animation
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _waveTilt = Tween<double>(begin: 0, end: 20).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.elasticOut),
    );

    _waveScale = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.easeInOut),
    );

    // Auto trigger wave mỗi 10 giây
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 10));
      if (mounted) {
        _waveController.forward(from: 0);
      }
      return mounted;
    });
  }

  @override
  void dispose() {
    _idleController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pos = widget.position ?? Offset.zero;

    return AnimatedBuilder(
      animation: Listenable.merge([_idleController, _waveController]),
      builder: (context, child) {
        final jump = _jumpAnimation.value;
        final tilt = _tiltAnimation.value + _waveTilt.value; // wave tilt
        final scale = _waveScale.value;

        final mascot = Transform.rotate(
          angle: tilt * math.pi / 180,
          child: Transform.scale(
            scale: scale,
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: Image.asset(widget.assetPath),
            ),
          ),
        );

        return Positioned(
          left: 20 + pos.dx,
          bottom: 40 + pos.dy + jump,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              mascot,

              // ✨ Sparkles quanh mascot khi wave
              if (_waveController.isAnimating)
                ..._buildSparkles(widget.size),
            ],
          ),
        );
      },
    );
  }

  /// Tạo hiệu ứng sparkles bay quanh mascot
  List<Widget> _buildSparkles(double size) {
    final sparkles = <Widget>[];
    final random = math.Random();

    for (int i = 0; i < 6; i++) {
      final angle = (i / 6) * 2 * math.pi;
      final radius = size / 1.2 + random.nextDouble() * 10;

      final dx = math.cos(angle) * radius;
      final dy = math.sin(angle) * radius;

      sparkles.add(Positioned(
        left: size / 2 + dx,
        top: size / 2 + dy,
        child: Opacity(
          opacity: 1 - _waveController.value, // mờ dần khi wave xong
          child: Transform.scale(
            scale: 1 + _waveController.value,
            child: Icon(
              Icons.star,
              size: 12 + random.nextDouble() * 6,
              color: Colors.yellowAccent.withOpacity(0.9),
            ),
          ),
        ),
      ));
    }

    return sparkles;
  }
}
