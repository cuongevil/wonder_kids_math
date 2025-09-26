import 'dart:math';
import 'package:flutter/material.dart';

/// Widget Card với hiệu ứng WOW cho bé:
/// - Idle bounce (nhún lên xuống)
/// - Tap scale + particles (sao, tim, nốt nhạc bay ra)
/// - Shine quét ngang card
/// - Idle particles (sao nhỏ bay quanh liên tục)
class WowCard extends StatefulWidget {
  final Widget child; // Nội dung (ảnh, chữ...)
  final Gradient gradient; // Nền gradient
  final double borderWidth;
  final double size; // kích thước card (vuông, nhưng sẽ là tròn)
  final VoidCallback? onTap;

  const WowCard({
    super.key,
    required this.child,
    required this.gradient,
    this.borderWidth = 4,
    this.size = 120,
    this.onTap,
  });

  @override
  State<WowCard> createState() => _WowCardState();
}

class _WowCardState extends State<WowCard>
    with TickerProviderStateMixin {
  late AnimationController _tapController;
  late AnimationController _idleController;
  late AnimationController _shineController;
  late AnimationController _particleController;
  late AnimationController _idleParticleController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _bounceAnimation;

  final List<_Particle> _tapParticles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    // Tap scale
    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _tapController, curve: Curves.easeOutBack),
    );

    // Idle bounce
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _bounceAnimation = Tween<double>(begin: -4, end: 4).animate(
      CurvedAnimation(parent: _idleController, curve: Curves.easeInOut),
    );

    // Shine effect
    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // Tap particles
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..addListener(() => setState(() {}));

    // Idle particles
    _idleParticleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  void _spawnTapParticles() {
    _tapParticles.clear();
    const icons = [Icons.star, Icons.favorite, Icons.music_note];
    for (int i = 0; i < 8; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final distance = 30 + _random.nextDouble() * 40;
      _tapParticles.add(
        _Particle(
          dx: cos(angle) * distance,
          dy: sin(angle) * distance,
          size: 12 + _random.nextDouble() * 12,
          rotation: _random.nextDouble() * 2 * pi,
          icon: icons[_random.nextInt(icons.length)],
          color: Colors.primaries[_random.nextInt(Colors.primaries.length)]
              .shade300,
        ),
      );
    }
  }

  void _onTap() {
    _tapController.forward().then((_) => _tapController.reverse());
    _spawnTapParticles();
    _particleController.forward(from: 0);

    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _tapController,
          _idleController,
          _shineController,
          _particleController,
          _idleParticleController,
        ]),
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _bounceAnimation.value),
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: GestureDetector(
                onTap: _onTap,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Card chính
                    Container(
                      decoration: BoxDecoration(
                        gradient: widget.gradient,
                        shape: BoxShape.circle,
                        border:
                        Border.all(color: Colors.white, width: widget.borderWidth),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(2, 6),
                          ),
                        ],
                      ),
                      child: widget.child,
                    ),

                    // Shine ✨
                    Positioned.fill(
                      child: IgnorePointer(
                        child: FractionallySizedBox(
                          alignment: Alignment(
                            -1.0 + 2.0 * _shineController.value,
                            0,
                          ),
                          widthFactor: 0.3,
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0x00FFFFFF),
                                  Color(0x66FFFFFF),
                                  Color(0x00FFFFFF),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Tap Particles
                    ..._tapParticles.map((p) {
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
                                p.icon,
                                size: p.size,
                                color: p.color,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),

                    // Idle Particles (sao nhỏ bay quanh)
                    ...List.generate(3, (i) {
                      final progress =
                          (_idleParticleController.value + i * 0.33) % 1.0;
                      final angle = progress * 2 * pi;
                      final radius = widget.size / 2 + 20;
                      final dx = cos(angle) * radius;
                      final dy = sin(angle) * radius;
                      return Positioned.fill(
                        child: Transform.translate(
                          offset: Offset(dx, dy),
                          child: Opacity(
                            opacity: 0.6,
                            child: Icon(
                              Icons.star,
                              size: 8 + (i * 2),
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _tapController.dispose();
    _idleController.dispose();
    _shineController.dispose();
    _particleController.dispose();
    _idleParticleController.dispose();
    super.dispose();
  }
}

class _Particle {
  final double dx;
  final double dy;
  final double size;
  final double rotation;
  final IconData icon;
  final Color color;

  _Particle({
    required this.dx,
    required this.dy,
    required this.size,
    required this.rotation,
    required this.icon,
    required this.color,
  });
}
