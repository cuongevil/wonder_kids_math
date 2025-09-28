import 'package:flutter/material.dart';
import '../models/level.dart';
import 'glow_ring.dart';

class LevelNode extends StatelessWidget {
  final Level level;
  final VoidCallback? onTap;

  const LevelNode({super.key, required this.level, this.onTap});

  /// Màu nền theo loại level
  Color _bgColor() {
    switch (level.type) {
      case LevelType.start:
      case LevelType.end:
        return const Color(0xFFE3F2FD);
      case LevelType.boss:
        return const Color(0xFFF3E5F5);
      case LevelType.topic:
        if (level.title.contains('So Sánh')) return const Color(0xFFE8F5E9);
        return const Color(0xFFFFF8E1);
    }
  }

  /// Màu viền theo loại level
  Color _borderColor() {
    switch (level.type) {
      case LevelType.start:
      case LevelType.end:
        return const Color(0xFF1E88E5);
      case LevelType.boss:
        return const Color(0xFF8E24AA);
      case LevelType.topic:
        if (level.title.contains('So Sánh')) return const Color(0xFF43A047);
        return const Color(0xFFFB8C00);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = level.state == LevelState.completed;
    final isLocked = level.state == LevelState.locked;

    return InkWell(
      onTap: isLocked ? null : onTap,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              if (isCompleted) const GlowRing(size: 92),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: _bgColor(),
                  shape: BoxShape.circle,
                  border: Border.all(color: _borderColor(), width: 2),
                ),
                alignment: Alignment.center,
                child: Icon(
                  isLocked ? Icons.lock : (isCompleted ? Icons.check : Icons.play_arrow),
                  size: 28,
                  color: isLocked ? Colors.grey : _borderColor(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 220,
            child: Text(
              level.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isLocked ? Colors.black54 : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
