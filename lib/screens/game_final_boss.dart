import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import '../services/progress_service.dart';
import '../widgets/wow_mascot.dart';
import 'base_screen.dart';

class GameFinalBossScreen extends StatefulWidget {
  const GameFinalBossScreen({super.key});

  @override
  State<GameFinalBossScreen> createState() => _GameFinalBossScreenState();
}

class _GameFinalBossScreenState extends State<GameFinalBossScreen>
    with TickerProviderStateMixin {
  final _rand = Random();
  final AudioPlayer _player = AudioPlayer();
  late ConfettiController _confettiController;

  int score = 0;
  int total = 0;
  late Timer timer;
  int timeLeft = 60;

  String question = "";
  late List<String> options;
  late String answer;

  bool isMascotHappy = true;
  bool isGameOver = false;

  // 🎨 Hình học
  String? currentShape;

  static const String levelKey = "final_boss"; // 🔹 định danh level Boss

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    _newQuestion();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        timeLeft--;
        if (timeLeft <= 0) _endGame();
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    _player.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _play(String name) async {
    await _player.play(AssetSource('audios/$name.mp3'));
  }

  void _newQuestion() {
    currentShape = null;
    int type = _rand.nextInt(3);
    if (type == 0) {
      // ➕➖ Cộng trừ
      int a = _rand.nextInt(10) + 1;
      int b = _rand.nextInt(10) + 1;
      bool isAdd = _rand.nextBool();

      if (!isAdd && a < b) {
        // 🔹 đảm bảo không âm
        int tmp = a;
        a = b;
        b = tmp;
      }

      answer = isAdd ? "${a + b}" : "${a - b}";
      question = isAdd ? "$a + $b = ?" : "$a - $b = ?";
      options = [answer];
      while (options.length < 3) {
        int fake = _rand.nextInt(20);
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
      currentShape = shapes[_rand.nextInt(shapes.length)];
      answer = currentShape!;
      question = "Đây là hình gì?";
      options = [...shapes]..shuffle();
    }
    setState(() {});
  }

  void _check(String opt) async {
    total++;
    if (opt == answer) {
      score++;
      isMascotHappy = true;
      await _play("correct1");
    } else {
      isMascotHappy = false;
      await _play("wrong");
    }
    _newQuestion();
  }

  Future<void> _endGame() async {
    if (isGameOver) return;
    isGameOver = true;
    timer.cancel();
    _confettiController.play();
    await _play("victory");

    // ✅ Đánh dấu level Boss hoàn thành
    await ProgressService.markLevelCompleted(levelKey);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "🎉 Hoàn thành!",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Bé trả lời đúng $score / $total câu.\nThời gian đã hết! ⏰",
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orangeAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text("Hoàn thành 🌟"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: "Tổng hợp",
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 40,
              colors: const [
                Colors.orange,
                Colors.amber,
                Colors.pink,
                Colors.purple,
                Colors.lightBlueAccent,
              ],
            ),
          ),

          // 🧸 Mascot
          Positioned(
            bottom: 100,
            right: 24,
            child: WowMascot.only(isHappy: isMascotHappy, scale: 0.8)
          ),

          // 📚 Nội dung
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ⏰ Thời gian
              Text(
                "⏰ $timeLeft giây",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
              const SizedBox(height: 20),

              // ❓ Câu hỏi
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  question,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 🎨 Hình học minh họa
              if (currentShape != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CustomPaint(
                    size: const Size(140, 140),
                    painter: _ShapePainter(currentShape!),
                  ),
                ),

              const SizedBox(height: 20),

              // 🟢 Các lựa chọn
              Wrap(
                spacing: 20,
                runSpacing: 16,
                children: options
                    .map(
                      (opt) => ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 18,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          backgroundColor: Colors.orangeAccent,
                          foregroundColor: Colors.white,
                          elevation: 6,
                        ),
                        onPressed: () => _check(opt),
                        child: Text(
                          opt,
                          style: const TextStyle(
                            fontSize: 24,
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
                  color: Colors.deepPurple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 🎨 Painter hiển thị hình tròn / vuông / tam giác
class _ShapePainter extends CustomPainter {
  final String shape;

  _ShapePainter(this.shape);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.orangeAccent
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final double r = size.width / 2.5;

    switch (shape) {
      case "Hình tròn":
        canvas.drawCircle(center, r, paint);
        break;

      case "Hình vuông":
        final rect = Rect.fromCenter(
          center: center,
          width: r * 2,
          height: r * 2,
        );
        canvas.drawRect(rect, paint);
        break;

      case "Tam giác":
        final path = Path();
        path.moveTo(center.dx, center.dy - r);
        path.lineTo(center.dx - r, center.dy + r);
        path.lineTo(center.dx + r, center.dy + r);
        path.close();
        canvas.drawPath(path, paint);
        break;
    }

    // Viền tím để nổi bật
    final border = Paint()
      ..color = Colors.deepPurple
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    if (shape == "Hình tròn") {
      canvas.drawCircle(center, r, border);
    } else if (shape == "Hình vuông") {
      final rect = Rect.fromCenter(center: center, width: r * 2, height: r * 2);
      canvas.drawRect(rect, border);
    } else {
      final path = Path();
      path.moveTo(center.dx, center.dy - r);
      path.lineTo(center.dx - r, center.dy + r);
      path.lineTo(center.dx + r, center.dy + r);
      path.close();
      canvas.drawPath(path, border);
    }
  }

  @override
  bool shouldRepaint(covariant _ShapePainter oldDelegate) =>
      oldDelegate.shape != shape;
}
