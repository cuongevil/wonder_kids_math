import 'dart:math';
import 'package:flutter/material.dart';
import '../models/level.dart';

class LevelNode extends StatefulWidget {
  final Level level;
  final VoidCallback onTap;
  final bool isCenter;
  final bool isNight;

  const LevelNode({
    super.key,
    required this.level,
    required this.onTap,
    required this.isCenter,
    required this.isNight,
  });

  @override
  State<LevelNode> createState() => _LevelNodeState();
}

class _LevelNodeState extends State<LevelNode> with TickerProviderStateMixin {
  late final AnimationController _sparkleController;

  @override
  void initState() {
    super.initState();
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    super.dispose();
  }

  Widget _buildSparkle(double radius, double speed, double size, Color color) {
    return AnimatedBuilder(
      animation: _sparkleController,
      builder: (context, child) {
        final angle = _sparkleController.value * 2 * pi * speed;
        final dx = cos(angle) * radius;
        final dy = sin(angle) * radius;
        return Transform.translate(
          offset: Offset(dx, dy),
          child: Icon(
            Icons.star,
            size: size,
            color: color,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Color baseColor;
    Color bgColor;
    IconData stateIcon;

    switch (widget.level.state) {
      case LevelState.completed:
        baseColor = Colors.greenAccent;
        bgColor = Colors.green.shade400;
        stateIcon = Icons.check;
        break;
      case LevelState.playable:
        baseColor = Colors.orangeAccent;
        bgColor = Colors.orange.shade400;
        stateIcon = Icons.play_arrow;
        break;
      default:
        baseColor = Colors.grey;
        bgColor = Colors.grey.shade600;
        stateIcon = Icons.lock;
    }

    return GestureDetector(
      onTap: widget.level.state == LevelState.playable ? widget.onTap : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 140,
            height: 140,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        baseColor.withOpacity(0.6),
                        baseColor.withOpacity(0.0),
                      ],
                      stops: const [0.6, 1.0],
                    ),
                  ),
                ),
                _buildSparkle(75, 1.0, 14, Colors.yellowAccent.withOpacity(0.9)),
                _buildSparkle(60, -1.5, 12, Colors.white.withOpacity(0.8)),
                _buildSparkle(85, 0.7, 16, Colors.orangeAccent.withOpacity(0.7)),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: bgColor,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        widget.level.index.toString(),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [Shadow(color: Colors.black26, blurRadius: 4)],
                        ),
                      ),
                      Positioned(
                        bottom: 6,
                        right: 6,
                        child: Icon(
                          stateIcon,
                          size: 22,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          AnimatedOpacity(
            opacity: widget.isCenter ? 1.0 : 0.6,
            duration: const Duration(milliseconds: 400),
            child: AnimatedScale(
              scale: widget.isCenter ? 1.1 : 0.9,
              duration: const Duration(milliseconds: 400),
              child: Text(
                widget.level.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: widget.isCenter ? 16 : 14,
                  fontWeight: FontWeight.w700,
                  color: widget.isNight ? Colors.white : Colors.black87,
                  shadows: widget.isNight
                      ? const [
                    Shadow(color: Colors.black, blurRadius: 4),
                    Shadow(color: Colors.white70, blurRadius: 6),
                  ]
                      : const [
                    Shadow(color: Colors.white, blurRadius: 3),
                    Shadow(color: Colors.black45, blurRadius: 2),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
