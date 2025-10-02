import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'base_screen.dart'; // ✅ sử dụng BaseScreen

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
      // ➕➖ Cộng trừ
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
      // 🔢 So sánh
      int a = _rand.nextInt(20);
      int b = _rand.nextInt(20);
      String op = a == b ? "=" : (a < b ? "<" : ">");
      answer = op;
      question = "$a ? $b";
      options = ["<", "=", ">"];
    } else {
      // 🔺 Hình học
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
        title: const Text("🎉 Boss Clear!", style: TextStyle(fontSize: 24)),
        content: Text(
          "Bạn trả lời đúng $score / $total câu.",
          style: const TextStyle(fontSize: 20),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, true); // báo hoàn thành level
            },
            child: const Text("OK", style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: "Boss cuối 🏰🐉",
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ⏰ Thời gian
            Text(
              "⏰ $timeLeft giây",
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 20),

            // ❓ Câu hỏi
            Text(
              question,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: Colors.deepPurple,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // 🟢 Các lựa chọn
            Wrap(
              spacing: 20,
              runSpacing: 16,
              children: options
                  .map(
                    (opt) => ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        backgroundColor: Colors.orangeAccent,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => _check(opt),
                      child: Text(
                        opt,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 40),

            // 📊 Điểm số
            Text(
              "Điểm: $score / $total",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
