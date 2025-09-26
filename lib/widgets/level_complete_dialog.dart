import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../models/mascot_mood.dart';
import 'mascot_widget.dart';
import 'confetti_overlay.dart';

class LevelCompleteDialog extends StatelessWidget {
  final int maxRound;
  final int streak;
  final int maxStreak;
  final int totalCorrect;
  final VoidCallback onNextLevel;
  final ConfettiController confettiController;

  const LevelCompleteDialog({
    super.key,
    required this.maxRound,
    required this.streak,
    required this.maxStreak,
    required this.totalCorrect,
    required this.onNextLevel,
    required this.confettiController,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      backgroundColor: Colors.transparent,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.pink.shade100, Colors.yellow.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.pink.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const MascotWidget(mood: MascotMood.celebrate),
                const SizedBox(height: 12),
                Text("🎉 Giỏi lắm bé ơi! 🎉",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.pink.shade700)),
                const SizedBox(height: 12),
                Text(
                  "Hoàn thành $maxRound vòng!\n"
                      "⭐ Chuỗi hiện tại: $streak\n"
                      "🔥 Chuỗi dài nhất: $maxStreak\n"
                      "👑 Tổng số đúng: $totalCorrect",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    onNextLevel();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text("Chơi Level mới",
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),
          ConfettiOverlay(controller: confettiController),
        ],
      ),
    );
  }
}
