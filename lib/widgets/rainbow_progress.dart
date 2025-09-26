import 'dart:math';
import 'package:flutter/material.dart';

class RainbowProgress extends StatelessWidget {
  final double progress;
  final AnimationController controller;

  const RainbowProgress({
    super.key,
    required this.progress,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final barWidth = constraints.maxWidth;
          const starSize = 18.0;
          final starX = (barWidth - starSize) * progress.clamp(0.0, 1.0);

          return Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: 24,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Colors.red,
                      Colors.orange,
                      Colors.yellow,
                      Colors.green,
                      Colors.blue,
                      Colors.purple
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              Positioned(
                left: starX,
                child: AnimatedBuilder(
                  animation: controller,
                  builder: (context, child) {
                    final bounceY = sin(controller.value * 2 * pi) * 3;
                    return Transform.translate(
                      offset: Offset(0, bounceY),
                      child: const Icon(Icons.star,
                          color: Colors.white, size: starSize),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
