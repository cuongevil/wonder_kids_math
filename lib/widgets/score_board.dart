import 'package:flutter/material.dart';

class ScoreBoard extends StatelessWidget {
  final int streak;
  final int maxStreak;
  final int totalCorrect;

  const ScoreBoard({
    super.key,
    required this.streak,
    required this.maxStreak,
    required this.totalCorrect,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("⭐ ",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text("$streak  ",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        const Text("🔥 ",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text("$maxStreak  ",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        const Text("👑 ",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text("$totalCorrect",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
