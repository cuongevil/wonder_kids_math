import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class GameFinalBossScreen extends StatefulWidget {
  const GameFinalBossScreen({super.key});

  @override
  State<GameFinalBossScreen> createState() => _GameFinalBossScreenState();
}

class _GameFinalBossScreenState extends State<GameFinalBossScreen> {
  final _rand = Random();
  int score = 0;
  int total = 0;
  late Timer timer;
  int timeLeft = 60;
  String question = "";
  late List<String> options;
  late String answer;

  @override
  void initState() {
    super.initState();
    _newQuestion();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        timeLeft--;
        if (timeLeft <= 0) {
          _endGame();
        }
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void _newQuestion() {
    int type = _rand.nextInt(3);
    if (type == 0) {
      // Cộng trừ
      int a = _rand.nextInt(10) + 1;
      int b = _rand.nextInt(10) + 1;
      bool isAdd = _rand.nextBool();
      answer = isAdd ? "${a + b}" : "${a - b}";
      question = isAdd ? "$a + $b = ?" : "$a - $b = ?";
      options = [answer];
      while (options.length < 3) {
        int fake = _rand.nextInt(20) - 5;
        if (!options.contains("$fake")) options.add("$fake");
      }
      options.shuffle();
    } else if (type == 1) {
      // So sánh
      int a = _rand.nextInt(20);
      int b = _rand.nextInt(20);
      String op = a == b ? "=" : (a < b ? "<" : ">");
      answer = op;
      question = "$a ? $b";
      options = ["<", "=", ">"];
    } else {
      // Hình học
      List<String> shapes = ["Hình tròn", "Hình vuông", "Tam giác"];
      answer = shapes[_rand.nextInt(shapes.length)];
      question = "Đây là hình gì?";
      options = [...shapes]..shuffle();
    }
    setState(() {});
  }

  void _check(String opt) {
    total++;
    if (opt == answer) score++;
    _newQuestion();
  }

  void _endGame() {
    timer.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("🎉 Boss Clear!"),
        content: Text("Bạn trả lời đúng $score / $total câu."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, true); // báo hoàn thành level
            },
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Boss cuối 🏰🐉")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("⏰ $timeLeft giây",
                style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.red)),
            const SizedBox(height: 20),
            Text(question,
                style:
                const TextStyle(fontSize: 28, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            Wrap(
              spacing: 20,
              children: options
                  .map(
                    (opt) => ElevatedButton(
                  onPressed: () => _check(opt),
                  child: Text(opt, style: const TextStyle(fontSize: 22)),
                ),
              )
                  .toList(),
            ),
            const SizedBox(height: 30),
            Text("Điểm: $score / $total",
                style: const TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}
