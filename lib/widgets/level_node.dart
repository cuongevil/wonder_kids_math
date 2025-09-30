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
      duration: const Duration(seconds: 1),
      lowerBound: 0.95,
      upperBound: 1.05,
    );

    if (widget.level.state == LevelState.playable) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final level = widget.level;

    // gradient theo trạng thái
    LinearGradient gradient;
    IconData stateIcon;
    switch (level.state) {
      case LevelState.completed:
        gradient = const LinearGradient(colors: [Colors.greenAccent, Colors.teal]);
        stateIcon = Icons.check;
        break;
      case LevelState.playable:
        gradient = const LinearGradient(colors: [Colors.orange, Colors.amber]);
        stateIcon = Icons.play_arrow;
        break;
      case LevelState.locked:
        gradient = const LinearGradient(colors: [Colors.grey, Colors.black26]);
        stateIcon = Icons.lock;
        break;
      default:
        gradient = const LinearGradient(colors: [Colors.blue, Colors.lightBlueAccent]);
        stateIcon = Icons.circle;
    }

    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: gradient,
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.7),
            blurRadius: 20,
            spreadRadius: 4,
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(stateIcon, size: 40, color: Colors.white),
            const SizedBox(height: 6),
            Text(
              level.index.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [Shadow(color: Colors.black45, blurRadius: 3)],
              ),
            ),
          ],
        ),
      ),
    );

    return GestureDetector(
      onTap: level.state == LevelState.playable ? widget.onTap : null,
      child: level.state == LevelState.playable
          ? ScaleTransition(scale: _pulseController, child: content)
          : content,
    );
  }
}
