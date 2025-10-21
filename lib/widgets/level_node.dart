import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/level.dart';
import '../themes/app_theme.dart';

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
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
      lowerBound: 0.95,
      upperBound: 1.05,
    )..repeat(reverse: true);

    _pulseAnim = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  /// 🔹 Hiệu ứng sparkle bay quanh node
  Widget _buildSparkle(double radius, double speed, double size, Color color) {
    return AnimatedBuilder(
      animation: _sparkleController,
      builder: (context, child) {
        final angle = _sparkleController.value * 2 * pi * speed;
        final dx = cos(angle) * radius;
        final dy = sin(angle) * radius;
        return Transform.translate(
          offset: Offset(dx, dy),
          child: Icon(Icons.star, size: size, color: color),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLocked = widget.level.state == LevelState.locked;

    // 🎨 Màu tím–cam fintech
    const gradient = LinearGradient(
      colors: [AppTheme.tpPurple, AppTheme.tpOrange],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    Color glowColor;
    IconData icon;
    String label = widget.level.title;

    switch (widget.level.state) {
      case LevelState.completed:
        glowColor = Colors.greenAccent;
        icon = Icons.check_circle_rounded;
        break;
      case LevelState.playable:
        glowColor = AppTheme.tpOrange;
        icon = Icons.play_arrow_rounded;
        break;
      default:
        glowColor = Colors.grey;
        icon = Icons.lock;
        break;
    }

    return GestureDetector(
      onTap: isLocked
          ? null
          : () {
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: widget.isCenter ? _pulseAnim : const AlwaysStoppedAnimation(1),
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isLocked
                    ? const LinearGradient(colors: [Colors.grey, Colors.black26])
                    : gradient,
                boxShadow: [
                  BoxShadow(
                    color: glowColor.withOpacity(0.6),
                    blurRadius: widget.isCenter ? 30 : 15,
                    spreadRadius: widget.isCenter ? 8 : 4,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (!isLocked) ...[
                    _buildSparkle(60, 1.0, 10, Colors.white.withOpacity(0.8)),
                    _buildSparkle(80, -1.3, 14, Colors.yellowAccent.withOpacity(0.9)),
                    _buildSparkle(90, 0.6, 12, Colors.orangeAccent.withOpacity(0.7)),
                  ],
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.2),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(icon, color: Colors.white, size: 42),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Icon(
                      widget.level.state == LevelState.locked
                          ? Icons.lock
                          : Icons.star_rounded,
                      color: widget.level.state == LevelState.locked
                          ? Colors.white30
                          : Colors.yellowAccent,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          AnimatedOpacity(
            opacity: widget.isCenter ? 1 : 0.6,
            duration: const Duration(milliseconds: 400),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: widget.isCenter ? 18 : 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: glowColor.withOpacity(0.8),
                    blurRadius: 10,
                  ),
                  const Shadow(
                    color: Colors.black54,
                    blurRadius: 6,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
