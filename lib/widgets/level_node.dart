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
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _sparkleController;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
      lowerBound: 0.9,
      upperBound: 1.1,
    );

    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    if (widget.level.state == LevelState.playable) {
      _pulseController.repeat(reverse: true);
      _sparkleController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final level = widget.level;

    // gradient theo trạng thái
    RadialGradient gradient;
    IconData stateIcon;
    switch (level.state) {
      case LevelState.completed:
        gradient = const RadialGradient(
          colors: [Colors.greenAccent, Colors.teal],
          center: Alignment.center,
          radius: 0.9,
        );
        stateIcon = Icons.check;
        break;
      case LevelState.playable:
        gradient = const RadialGradient(
          colors: [Colors.orangeAccent, Colors.deepOrange],
          center: Alignment.center,
          radius: 0.9,
        );
        stateIcon = Icons.play_arrow;
        break;
      case LevelState.locked:
        gradient = const RadialGradient(
          colors: [Colors.grey, Colors.black26],
          center: Alignment.center,
          radius: 0.9,
        );
        stateIcon = Icons.lock;
        break;
      default:
        gradient = const RadialGradient(
          colors: [Colors.blue, Colors.lightBlueAccent],
          center: Alignment.center,
          radius: 0.9,
        );
        stateIcon = Icons.circle;
    }

    final nodeContent = AnimatedBuilder(
      animation: _sparkleController,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.all(18),
          width: 140, // 👈 to hơn
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: gradient,
            boxShadow: [
              BoxShadow(
                color: gradient.colors.first.withOpacity(
                    0.6 + 0.4 * _sparkleController.value),
                blurRadius: 45, // 👈 glow to hơn
                spreadRadius: 12,
              )
            ],
          ),
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // icon lớn, mờ (watermark)
                Opacity(
                  opacity: 0.18,
                  child: Icon(
                    stateIcon,
                    size: 100, // 👈 icon nền to
                    color: Colors.white,
                  ),
                ),
                // số level nổi bật
                Text(
                  level.index.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 48, // 👈 số to nổi bật
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(color: Colors.black54, blurRadius: 6),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    return GestureDetector(
      onTap: level.state == LevelState.playable ? widget.onTap : null,
      child: level.state == LevelState.playable
          ? ScaleTransition(scale: _pulseController, child: nodeContent)
          : nodeContent,
    );
  }
}
