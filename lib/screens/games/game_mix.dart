import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/math_question.dart';
import '../../widgets/score_board.dart';
import '../../widgets/rainbow_progress.dart';
import '../../widgets/mascot_widget.dart';
import '../../models/mascot_mood.dart';
import '../../widgets/confetti_overlay.dart';
import '../../widgets/level_complete_dialog.dart';

class GameMix extends StatefulWidget {
  const GameMix({super.key});
  @override State<GameMix> createState() => _GameMixState();
}

class _GameMixState extends State<GameMix> {
  late MathQuestion question;
  int totalCorrect = 0; int streak = 0; MascotMood mascotMood = MascotMood.idle;
  bool playConfetti = false; int level = 1;

  @override void initState() { super.initState(); _generateQuestion(); }

  void _generateQuestion() {
    final rand = Random();
    final ops = ["+", "-", "×", "÷"];
    String op = ops[rand.nextInt(4)];
    int a, b, answer;
    switch (op) {
      case "+":
        a = rand.nextInt(10) + 1; b = rand.nextInt(10) + 1; answer = a + b; break;
      case "-":
        a = rand.nextInt(10) + 1; b = rand.nextInt(10) + 1; if (b > a) { int t = a; a = b; b = t; } answer = a - b; break;
      case "×":
        a = rand.nextInt(10) + 1; b = rand.nextInt(10) + 1; answer = a * b; break;
      case "÷":
        b = rand.nextInt(9) + 1; a = b * (rand.nextInt(10) + 1); answer = a ~/ b; break;
      default:
        a = 1; b = 1; answer = 2;
    }
    List<int> options = [answer];
    while (options.length < 4) { int wrong = rand.nextInt(100) + 1; if (!options.contains(wrong)) options.add(wrong); }
    options.shuffle();
    question = MathQuestion(question: "$a $op $b = ?", answer: answer, options: options);
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
      appBar: AppBar(title: const Text("Game Tổng hợp")),
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
