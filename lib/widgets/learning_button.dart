import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LearningButton extends StatefulWidget {
  final String title;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;

  const LearningButton({
    super.key,
    required this.title,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  State<LearningButton> createState() => _LearningButtonState();
}

class _LearningButtonState extends State<LearningButton>
    with TickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnim;
  late Animation<double> _shakeAnim;

  late AnimationController _particleController;
  final List<_Particle> _particles = [];

  @override
  void initState() {
    super.initState();

    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnim = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.elasticOut),
    );

    _shakeAnim = Tween<double>(begin: -6.0, end: 6.0).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.elasticIn),
    );

    _particleController =
    AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _pressController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  void _spawnParticles() {
    _particles.clear();
    final random = Random();
    for (int i = 0; i < 12; i++) {
      _particles.add(_Particle(
        dx: random.nextDouble() * 100 - 50,
        dy: random.nextDouble() * -100 - 30,
        emoji: ["✨", "💖", "🎈", "🌟"][random.nextInt(4)],
      ));
    }
    _particleController.forward(from: 0);
  }

  void _handleTap() {
    if (_pressController.isAnimating) {
      _pressController.reset();
    }
    _pressController.forward();
    _spawnParticles();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _pressController,
          builder: (context, child) {
            final scale = _scaleAnim.value;
            final shake = _shakeAnim.value * (1 - _pressController.value);

            return Transform.scale(
              scale: scale,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: widget.gradient),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: widget.gradient.last.withOpacity(0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  leading: Transform.translate(
                    offset: Offset(shake, 0),
                    child: Icon(widget.icon, color: Colors.white, size: 30),
                  ),
                  title: Text(
                    widget.title,
                    style: GoogleFonts.baloo2(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  onTap: _handleTap,
                ),
              ),
            );
          },
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _ParticlePainter(_particles, _particleController.value),
            ),
          ),
        ),
      ],
    );
  }
}

class _Particle {
  final double dx;
  final double dy;
  final String emoji;

  _Particle({required this.dx, required this.dy, required this.emoji});
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _ParticlePainter(this.particles, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (var p in particles) {
      final offset = Offset(
        size.width / 2 + p.dx * progress,
        size.height / 2 + p.dy * progress,
      );

      textPainter.text = TextSpan(
        text: p.emoji,
        style: TextStyle(fontSize: 22 * (1 - progress)),
      );
      textPainter.layout();
      textPainter.paint(canvas, offset);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}
