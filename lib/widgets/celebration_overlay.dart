import 'dart:math';

import 'package:flutter/material.dart';

class CelebrationOverlay {
  static void show(BuildContext context) {
    final overlay = Overlay.of(context);
    final entries = <OverlayEntry>[];

    for (int i = 0; i < 6; i++) {
      final random = Random();
      final entry = OverlayEntry(
        builder: (context) {
          final left = random.nextDouble() * MediaQuery.of(context).size.width;
          final isStar = random.nextBool();

          return Positioned(
            bottom: -50,
            left: left,
            child: _AnimatedParticle(isStar: isStar),
          );
        },
      );
      entries.add(entry);
      overlay.insert(entry);
    }

    Future.delayed(const Duration(seconds: 2), () {
      for (final e in entries) {
        e.remove();
      }
    });
  }
}

class _AnimatedParticle extends StatefulWidget {
  final bool isStar;

  const _AnimatedParticle({required this.isStar});

  @override
  State<_AnimatedParticle> createState() => _AnimatedParticleState();
}

class _AnimatedParticleState extends State<_AnimatedParticle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    final dx = (random.nextDouble() * 100) - 50;
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final progress = _animation.value;
        return Transform.translate(
          offset: Offset(dx * progress, -200 * progress),
          child: Opacity(opacity: 1 - progress, child: child),
        );
      },
      child: Icon(
        widget.isStar ? Icons.star : Icons.circle,
        size: widget.isStar ? 28 : 20,
        color: widget.isStar ? Colors.amber : Colors.pinkAccent,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
