import 'dart:math';
import 'package:flutter/material.dart';

class GameMeasureTimeScreen extends StatefulWidget {
  const GameMeasureTimeScreen({super.key});

  @override
  State<GameMeasureTimeScreen> createState() => _GameMeasureTimeScreenState();
}

class _GameMeasureTimeScreenState extends State<GameMeasureTimeScreen> {
  final _rand = Random();
  late int mode; // 0 = dài-ngắn, 1 = đồng hồ
  late String question;
  late List<String> options;
  late String answer;

  @override
  void initState() {
    super.initState();
    _newQuestion();
  }

  void _newQuestion() {
    mode = _rand.nextInt(2); // random 0 hoặc 1
    if (mode == 0) {
      // So sánh dài-ngắn
      int a = _rand.nextInt(50) + 50; // 50–100
      int b = _rand.nextInt(50) + 50;
      question = "Đoạn nào dài hơn?";
      answer = a > b ? "A ($a cm)" : "B ($b cm)";
      options = ["A ($a cm)", "B ($b cm)"];
    } else {
      // Đồng hồ giờ đúng
      int h = _rand.nextInt(12) + 1;
      question = "Kim giờ chỉ mấy giờ?";
      answer = "$h giờ";
      options = [
        "$h giờ",
        "${(h % 12) + 1} giờ",
        "${(h + 3) % 12 + 1} giờ"
      ];
      options.shuffle();
    }
    setState(() {});
  }

  void _check(String opt) {
    final correct = opt == answer;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(correct ? "🎉 Đúng rồi!" : "❌ Sai mất rồi"),
        content: Text(correct ? "Giỏi quá!" : "Đáp án đúng: $answer"),
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
      appBar: AppBar(title: const Text("Đo lường & Thời gian")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(question,
                style:
                const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Wrap(
              spacing: 20,
              children: options
                  .map(
                    (opt) => ElevatedButton(
                  onPressed: () => _check(opt),
                  child: Text(opt, style: const TextStyle(fontSize: 20)),
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
