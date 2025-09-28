import 'package:flutter/material.dart';
import '../models/level.dart';

class LevelNode extends StatefulWidget {
  final Level level;
  final VoidCallback onTap;

  const LevelNode({super.key, required this.level, required this.onTap});

  @override
  State<LevelNode> createState() => _LevelNodeState();
}

class _LevelNodeState extends State<LevelNode>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lv = widget.level;

    Color bg;
    IconData icon;
    switch (lv.state) {
      case LevelState.locked:
        bg = Colors.grey.shade400;
        icon = Icons.lock;
        break;
      case LevelState.playable:
        bg = Colors.orangeAccent;
        icon = Icons.play_arrow;
        break;
      case LevelState.completed:
        bg = Colors.greenAccent;
        icon = Icons.check;
        break;
    }

    return ScaleTransition(
      scale: lv.state == LevelState.playable
          ? Tween(begin: 0.9, end: 1.1).animate(CurvedAnimation(
          parent: _pulseController, curve: Curves.easeInOut))
          : const AlwaysStoppedAnimation(1.0),
      child: GestureDetector(
        onTap: lv.state != LevelState.locked ? widget.onTap : null,
        child: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                bg.withOpacity(0.9),
                bg.withOpacity(0.6),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: bg.withOpacity(0.7),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 36, color: Colors.white),
              const SizedBox(height: 4),
              Text(
                lv.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(blurRadius: 4, color: Colors.black45),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
