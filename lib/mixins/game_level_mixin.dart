import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

import '../models/mascot_mood.dart';
import '../widgets/level_complete_dialog_base.dart';

mixin GameLevelMixin<T extends StatefulWidget> on State<T> {
  int round = 0;
  int maxRound = 5;
  int level = 1;

  int streak = 0;
  int maxStreak = 0;
  int totalCorrect = 0;

  MascotMood mascotMood = MascotMood.idle;

  late ConfettiController confettiController;

  void initLevelMixin() {
    confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  void disposeLevelMixin() {
    confettiController.dispose();
  }

  void increaseScore(bool isCorrect) {
    if (isCorrect) {
      streak++;
      totalCorrect++;
      if (streak > maxStreak) maxStreak = streak;
      mascotMood = MascotMood.happy;
    } else {
      streak = 0;
      mascotMood = MascotMood.sad;
    }
  }

  double overallProgress() {
    if (maxRound <= 0) return 0;
    return (round / maxRound).clamp(0.0, 1.0);
  }

  void showLevelComplete({
    required String title,
    required String subtitle,
    required VoidCallback onNextRound,
  }) {
    setState(() => mascotMood = MascotMood.celebrate);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => LevelCompleteDialogBase(
        title: title,
        subtitle: subtitle,
        maxRound: maxRound,
        streak: streak,
        maxStreak: maxStreak,
        totalCorrect: totalCorrect,
        confettiController: confettiController,
        onNextLevel: () => goNextLevel(onNextRound),
      ),
    );
  }

  void goNextLevel(VoidCallback onNextRound) {
    setState(() {
      level++;
      round = 0;
      streak = 0;
      maxStreak = 0;
      totalCorrect = 0;
      mascotMood = MascotMood.idle;
    });

    Future.delayed(const Duration(milliseconds: 200), onNextRound);
  }
}
