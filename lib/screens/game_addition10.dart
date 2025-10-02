import 'dart:math';

import 'package:flutter/material.dart';

import 'base_screen.dart'; // ✅ dùng BaseScreen

class GameAddition10Screen extends StatefulWidget {
  const GameAddition10Screen({super.key});

  @override
  State<GameAddition10Screen> createState() => _GameAddition10ScreenState();
}

class _GameAddition10ScreenState extends State<GameAddition10Screen> {
  final _rand = Random();
  late int a;
  late int b;
  late int answer;
  late List<int> options;

  @override
  void initState() {
    super.initState();
    _newQuestion();
  }

  void _newQuestion() {
    a = _rand.nextInt(6) + 1; // 1–6
    b = _rand.nextInt(6) + 1; // 1–6
    answer = a + b;
    options = [answer];
    while (options.length < 3) {
      int fake = _rand.nextInt(10) + 1;
      if (!options.contains(fake)) options.add(fake);
    }
    options.shuffle();
    setState(() {});
  }

  void _check(int value) {
    final correct = value == answer;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(correct ? "🎉 Chính xác!" : "❌ Sai rồi"),
        content: Text(correct ? "Giỏi lắm bé ơi!" : "Đáp án đúng là $answer"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (correct) {
                Navigator.pop(context, true); // báo hoàn thành
              } else {
                _newQuestion();
              }
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: "Phép cộng ≤10",
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "$a + $b = ?",
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: options
                  .map(
                    (opt) => ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        backgroundColor: Colors.deepPurpleAccent,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => _check(opt),
                      child: Text(
                        "$opt",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
