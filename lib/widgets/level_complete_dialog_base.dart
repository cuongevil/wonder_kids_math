import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class LevelCompleteDialogBase extends StatelessWidget {
  final String title;        // ví dụ: "🎉 Hoàn thành!"
  final String subtitle;     // ví dụ: "Bạn đã vượt qua trò chơi!"
  final int maxRound;
  final int streak;
  final int maxStreak;
  final int totalCorrect;
  final ConfettiController confettiController;
  final VoidCallback onNextLevel;

  const LevelCompleteDialogBase({
    super.key,
    required this.title,
    required this.subtitle,
    required this.maxRound,
    required this.streak,
    required this.maxStreak,
    required this.totalCorrect,
    required this.confettiController,
    required this.onNextLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [Colors.pink.shade100, Colors.blue.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, color: Colors.black87),
                ),
                const SizedBox(height: 16),
                Text("Số vòng: $maxRound"),
                Text("Chuỗi đúng hiện tại: $streak"),
                Text("Chuỗi dài nhất: $maxStreak"),
                Text("Tổng số đúng: $totalCorrect"),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onNextLevel();
                  },
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text("Tiếp tục level mới"),
                ),
              ],
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: false,
                  emissionFrequency: 0.05,
                  numberOfParticles: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
