import 'dart:math';
import 'package:flutter/material.dart';

class GameCompareScreen extends StatefulWidget {
  const GameCompareScreen({super.key});

  @override
  State<GameCompareScreen> createState() => _GameCompareScreenState();
}

class _GameCompareScreenState extends State<GameCompareScreen> {
  final _rand = Random();
  late int a;
  late int b;

  @override
  void initState() {
    super.initState();
    _newQuestion();
  }

  void _newQuestion() {
    a = _rand.nextInt(20) + 1;
    b = _rand.nextInt(20) + 1;
    setState(() {});
  }

  void _check(String op) {
    final correctOp = a == b
        ? "="
        : (a < b ? "<" : ">");
    final correct = op == correctOp;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(correct ? "🎉 Đúng rồi!" : "❌ Sai rồi"),
        content: Text("Đáp án đúng: $a $correctOp $b"),
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
      appBar: AppBar(title: const Text("So sánh số")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("$a ? $b", style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 20),
            Wrap(
              spacing: 20,
              children: ["<", "=", ">"]
                  .map(
                    (op) => ElevatedButton(
                  onPressed: () => _check(op),
                  child: Text(op, style: const TextStyle(fontSize: 32)),
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
