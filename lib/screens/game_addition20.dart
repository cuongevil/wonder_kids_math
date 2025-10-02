import 'dart:math';

import 'package:flutter/material.dart';

import 'base_screen.dart'; // ✅ dùng BaseScreen

class GameAddition20Screen extends StatefulWidget {
  const GameAddition20Screen({super.key});

  @override
  State<GameAddition20Screen> createState() => _GameAddition20ScreenState();
}

class _GameAddition20ScreenState extends State<GameAddition20Screen> {
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
    a = _rand.nextInt(11) + 5; // 5–15
    b = _rand.nextInt(11) + 5; // 5–15
    answer = a + b;

    options = [answer];
    while (options.length < 3) {
      int fake = _rand.nextInt(21) + 5; // 5–25
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
      title: "Phép cộng ≤20",
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "$a + $b = ?",
              style: const TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 30),
            Wrap(
              spacing: 18,
              runSpacing: 14,
              children: options
                  .map(
                    (opt) => ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 18,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        backgroundColor: Colors.lightBlueAccent,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => _check(opt),
                      child: Text(
                        "$opt",
                        style: const TextStyle(
                          fontSize: 26,
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
