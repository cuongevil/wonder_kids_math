import 'package:flutter/material.dart';
import '../models/level.dart';

class LevelNode extends StatelessWidget {
  final Level level;
  final VoidCallback onTap;

  const LevelNode({super.key, required this.level, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // chọn icon/image theo level
    final iconPath = _getIconForLevel(level.index);

    // màu glow theo trạng thái
    Color glowColor;
    Widget childIcon;

    switch (level.state) {
      case LevelState.completed:
        glowColor = Colors.greenAccent;
        childIcon = const Icon(Icons.check, size: 40, color: Colors.white);
        break;
      case LevelState.playable:
        glowColor = Colors.orangeAccent;
        childIcon = const Icon(Icons.play_arrow, size: 40, color: Colors.white);
        break;
      case LevelState.locked:
        glowColor = Colors.grey;
        childIcon = const Icon(Icons.lock, size: 32, color: Colors.white70);
        break;
      default:
        glowColor = Colors.blueAccent;
        childIcon = const Icon(Icons.circle, size: 32, color: Colors.white);
    }

    return GestureDetector(
      onTap: level.state == LevelState.playable ? onTap : null,
      child: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: glowColor.withOpacity(0.6),
              blurRadius: 25,
              spreadRadius: 5,
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // icon riêng cho level
              if (iconPath != null)
                Image.asset(iconPath, width: 48, height: 48, fit: BoxFit.contain),
              // overlay trạng thái
              childIcon,
            ],
          ),
        ),
      ),
    );
  }

  String? _getIconForLevel(int index) {
    switch (index) {
      case 1:
        return "assets/images/icon_apple.png"; // 🍎
      case 2:
        return "assets/images/icon_tree.png"; // 🌲
      case 3:
        return "assets/images/icon_bridge.png"; // 🌉
      case 4:
        return "assets/images/icon_cave.png"; // ⛰️
      case 5:
        return "assets/images/icon_scale.png"; // ⚖️
      case 6:
        return "assets/images/icon_river.png"; // 🌊
      case 7:
        return "assets/images/icon_desert.png"; // 🏜️
      case 8:
        return "assets/images/icon_city.png"; // 🏙️
      case 9:
        return "assets/images/icon_clock.png"; // ⏰
      case 10:
        return "assets/images/icon_castle.png"; // 🏰🐉
      default:
        return null;
    }
  }
}
