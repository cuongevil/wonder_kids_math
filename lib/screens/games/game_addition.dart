import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/math_question.dart';
import '../../widgets/score_board.dart';
import '../../widgets/rainbow_progress.dart';
import '../../widgets/mascot_widget.dart';
import '../../models/mascot_mood.dart';
import '../../widgets/confetti_overlay.dart';
import '../../widgets/level_complete_dialog.dart';

class GameAddition extends StatefulWidget {
  const GameAddition({super.key});
  @override State<GameAddition> createState() => _GameAdditionState();
}

class _GameAdditionState extends State<GameAddition> {
  late MathQuestion question;
  int totalCorrect = 0; int streak = 0; MascotMood mascotMood = MascotMood.idle;
  bool playConfetti = false; int level = 1;

  @override void initState() { super.initState(); _generateQuestion(); }

  void _generateQuestion() {
    final rand = Random();
    int a = rand.nextInt(10) + 1;
    int b = rand.nextInt(10) + 1;
    int answer = a + b;
    List<int> options = [answer];
    while (options.length < 4) { int wrong = rand.nextInt(20) + 1; if (!options.contains(wrong)) options.add(wrong); }
    options.shuffle();
    question = MathQuestion(question: "$a + $b = ?", answer: answer, options: options);
  }

  void _checkAnswer(int value) {
    final correct = value == question.answer;
    if (correct) {
      totalCorrect++; streak++; mascotMood = MascotMood.happy; playConfetti = true;
      if (totalCorrect % 10 == 0) {
        Future.delayed(Duration.zero, () {
          showDialog(context: context, builder: (_)=> LevelCompleteDialog(
            level: level, onNext: () { setState(() { level++; streak = 0; }); }
          ));
        });
      }
    } else { streak = 0; mascotMood = MascotMood.sad; playConfetti = false; }

    showDialog(context: context, builder: (_)=> AlertDialog(
      title: Text(correct ? "Đúng rồi 🎉" : "Sai rồi 😢"),
      actions: [TextButton(onPressed: () { Navigator.pop(context); _generateQuestion(); }, child: const Text("Câu tiếp theo"))],
    ));
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Game Cộng")),
      body: Stack(children:[
        Column(mainAxisAlignment: MainAxisAlignment.center, children:[
          ScoreBoard(totalCorrect: totalCorrect, streak: streak),
          RainbowProgress(progress: totalCorrect / 10),
          MascotWidget(mood: mascotMood),
          const SizedBox(height: 20),
          Text(question.question, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Wrap(spacing: 16, children: question.options.map((o)=> ElevatedButton(
            onPressed: ()=> _checkAnswer(o), child: Text("$o", style: const TextStyle(fontSize: 24))
          )).toList()),
        ]),
        ConfettiOverlay(play: playConfetti),
      ]),
    );
  }
}
