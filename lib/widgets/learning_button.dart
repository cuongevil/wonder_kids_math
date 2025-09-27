import 'package:flutter/material.dart';
import '../models/learning_info.dart';

class LearningButton extends StatefulWidget {
  final LearningInfo info;
  final VoidCallback onTap;
  final double? progress;

  const LearningButton({
    super.key,
    required this.info,
    required this.onTap,
    this.progress,
  });

  @override
  State<LearningButton> createState() => _LearningButtonState();
}

class _LearningButtonState extends State<LearningButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Widget _buildIcon() {
    final info = widget.info;

    if (info.group == "counting") {
      // 👉 Nhóm "Số đếm": có mascot nhỏ đi kèm
      return Stack(
        alignment: Alignment.center,
        children: [
          Icon(info.icon, size: 32, color: Colors.white),
          Positioned(
            right: -8,
            bottom: -8,
            child: Image.asset(
              "assets/images/mascot/mascot.png", // 👈 cần có ảnh mascot
              width: 28,
            ),
          ),
        ],
      );
    } else {
      // 👉 Nhóm "Phép toán": thêm sparkle
      return Stack(
        alignment: Alignment.center,
        children: [
          Icon(info.icon, size: 32, color: Colors.white),
          Positioned(
            top: -6,
            right: -6,
            child: Icon(Icons.star, size: 16, color: Colors.yellowAccent),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = widget.info;

    return ScaleTransition(
      scale: _ctrl,
      child: GestureDetector(
        onTapDown: (_) => _ctrl.reverse(),
        onTapUp: (_) {
          _ctrl.forward();
          widget.onTap();
        },
        onTapCancel: () => _ctrl.forward(),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: info.gradient),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: info.gradient.last.withOpacity(0.5),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            children: [
              _buildIcon(),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  info.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              if (widget.progress != null)
                Text(
                  "⭐ ${(widget.progress! * info.total).round()}/${info.total}",
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
