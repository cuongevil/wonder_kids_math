import 'package:flutter/material.dart';

class WowMascot extends StatefulWidget {
  const WowMascot({super.key});

  @override
  State<WowMascot> createState() => _WowMascotState();
}

class _WowMascotState extends State<WowMascot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(begin: 0.95, end: 1.05).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: Image.asset(
        'assets/images/mascot/mascot.png',
        width: 80,
        height: 80,
      ),
    );
  }
}
