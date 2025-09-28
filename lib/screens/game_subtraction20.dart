import 'dart:math';
import 'package:flutter/material.dart';

class GameSubtraction20Screen extends StatefulWidget {
  const GameSubtraction20Screen({super.key});

  @override
  State<GameSubtraction20Screen> createState() => _GameSubtraction20ScreenState();
}

class _GameSubtraction20ScreenState extends State<GameSubtraction20Screen> {
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
    a = _rand.nextInt(11) + 10; // 10–20
    b = _rand.nextInt(a + 1);   // đảm bảo b <= a
    answer = a - b;
    options = [answer];
    while (options.length < 3) {
      int fake = _rand.nextInt(21);
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
        content: Text(correct ? "Tốt lắm!" : "Đáp án đúng là $answer"),
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
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Phép trừ ≤20")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("$a – $b = ?", style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 20),
            Wrap(
              spacing: 16,
              children: options
                  .map(
                    (opt) => ElevatedButton(
                  onPressed: () => _check(opt),
                  child: Text("$opt", style: const TextStyle(fontSize: 24)),
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
