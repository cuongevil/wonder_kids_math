import 'dart:math';
import 'package:flutter/material.dart';

/// Nút có hiệu ứng WOW:
/// - Gradient pastel nền
/// - Nhún khi bấm
/// - Glossy shine quét ngang
/// - Particle (sao ✨) nổ ra khi tap
class WowButton extends StatefulWidget {
  final Widget child; // Nội dung hiển thị trong nút (chữ, ảnh…)
  final Gradient gradient; // Gradient nền
  final VoidCallback? onTap;
  final double borderRadius;
  final double shineWidthFactor;

  const WowButton({
    super.key,
    required this.child,
    required this.gradient,
    this.onTap,
    this.borderRadius = 24,
    this.shineWidthFactor = 0.3,
  });

  @override
  State<WowButton> createState() => _WowButtonState();
}

class _WowButtonState extends State<WowButton>
    with TickerProviderStateMixin {
  late AnimationController _tapController;
  late AnimationController _shineController;
  late AnimationController _particleController;
  late Animation<double> _scaleAnimation;

  final List<_Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    // Scale nhún khi tap
    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _tapController, curve: Curves.easeOutBack),
    );

    // Glossy shine
    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // Particle sao ✨
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..addListener(() {
      setState(() {});
    });
  }

  void _spawnParticles() {
    _particles.clear();
    for (int i = 0; i < 10; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final distance = 20 + _random.nextDouble() * 40;
      _particles.add(
        _Particle(
          dx: cos(angle) * distance,
          dy: sin(angle) * distance,
          size: 8 + _random.nextDouble() * 8,
          rotation: _random.nextDouble() * 2 * pi,
        ),
      );
    }
  }

  void _onTap() {
    _tapController.forward().then((_) => _tapController.reverse());
    _spawnParticles();
    _particleController.forward(from: 0);

    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTap: _onTap,
        child: AnimatedBuilder(
          animation: _shineController,
          builder: (context, child) {
            return Stack(
              clipBehavior: Clip.none,
              children: [
                // Nút chính
                Container(
                  decoration: BoxDecoration(
                    gradient: widget.gradient,
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(2, 4),
                      ),
                    ],
                  ),
                  child: widget.child,
                ),

                // Glossy shine 🌈
                Positioned.fill(
                  child: IgnorePointer(
                    child: FractionallySizedBox(
                      alignment: Alignment(
                        -1.0 + 2.0 * _shineController.value,
                        0,
                      ),
                      widthFactor: widget.shineWidthFactor,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.0),
                              Colors.white.withOpacity(0.4),
                              Colors.white.withOpacity(0.0),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(widget.borderRadius),
                        ),
                      ),
                    ),
                  ),
                ),

                // Particle stars ✨
                ..._particles.map((p) {
                  final progress = _particleController.value;
                  final dx = p.dx * progress;
                  final dy = p.dy * progress;
                  final opacity = (1 - progress).clamp(0.0, 1.0);
                  return Positioned.fill(
                    child: Transform.translate(
                      offset: Offset(dx, dy),
                      child: Transform.rotate(
                        angle: p.rotation,
                        child: Opacity(
                          opacity: opacity,
                          child: Icon(
                            Icons.star,
                            size: p.size,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tapController.dispose();
    _shineController.dispose();
    _particleController.dispose();
    super.dispose();
  }
}

class _Particle {
  final double dx;
  final double dy;
  final double size;
  final double rotation;

  _Particle({
    required this.dx,
    required this.dy,
    required this.size,
    required this.rotation,
  });
}
