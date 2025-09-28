import 'dart:math';
import 'package:flutter/material.dart';

class GameShapesScreen extends StatefulWidget {
  const GameShapesScreen({super.key});

  @override
  State<GameShapesScreen> createState() => _GameShapesScreenState();
}

class _GameShapesScreenState extends State<GameShapesScreen> {
  final _rand = Random();

  final List<Map<String, dynamic>> shapes = [
    {"name": "Hình tròn", "icon": Icons.circle},
    {"name": "Hình vuông", "icon": Icons.square},
    {"name": "Tam giác", "icon": Icons.change_history},
    {"name": "Chữ nhật", "icon": Icons.rectangle},
  ];

  late Map<String, dynamic> currentShape;
  late List<Map<String, dynamic>> options;

  @override
  void initState() {
    super.initState();
    _newQuestion();
  }

  void _newQuestion() {
    currentShape = shapes[_rand.nextInt(shapes.length)];
    options = [...shapes]..shuffle();
    setState(() {});
  }

  void _check(String name) {
    final correct = name == currentShape["name"];
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(correct ? "🎉 Giỏi quá!" : "❌ Sai mất rồi"),
        content: Text(correct
            ? "Đúng là ${currentShape["name"]}!"
            : "Đáp án đúng: ${currentShape["name"]}"),
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
      appBar: AppBar(title: const Text("Hình học cơ bản")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              currentShape["icon"],
              size: 120,
              color: Colors.deepPurple,
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 16,
              children: options
                  .map(
                    (s) => ElevatedButton(
                  onPressed: () => _check(s["name"]),
                  child: Text(s["name"], style: const TextStyle(fontSize: 20)),
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
