import 'package:flutter/material.dart';

class LevelCompleteDialog extends StatelessWidget {
  final int level;
  final VoidCallback onNext;
  const LevelCompleteDialog({super.key, required this.level, required this.onNext});
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text("🎉 Hoàn thành cấp độ!"),
      content: Text("Bạn đã hoàn thành cấp độ $level với 10 câu đúng!"),
      actions: [TextButton(onPressed: () { Navigator.of(context).pop(); onNext(); }, child: const Text("Tiếp tục"))],
    );
  }
}
