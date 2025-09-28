import 'package:flutter/material.dart';

class GlowRing extends StatefulWidget {
  final double size;
  const GlowRing({super.key, this.size = 84});

  @override
  State<GlowRing> createState() => _GlowRingState();
}

class _GlowRingState extends State<GlowRing> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        final t = 0.5 + 0.5 * _ctrl.value; // dao động từ 0.5 → 1
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                blurRadius: 18 * t,
                spreadRadius: 2 * t,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.6 * t),
              ),
            ],
          ),
        );
      },
    );
  }
}
