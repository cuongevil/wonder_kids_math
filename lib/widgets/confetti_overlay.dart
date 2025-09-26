import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class ConfettiOverlay extends StatelessWidget {
  final ConfettiController controller;
  final bool loop;

  const ConfettiOverlay({
    super.key,
    required this.controller,
    this.loop = false,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: ConfettiWidget(
        confettiController: controller,
        blastDirectionality: BlastDirectionality.explosive,
        shouldLoop: loop,
        numberOfParticles: 25,
        maxBlastForce: 20,
        minBlastForce: 8,
        emissionFrequency: 0.1,
      ),
    );
  }
}
