import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import '../widgets/wow_mascot.dart'; // 🐧 mascot động nhỏ
import 'base_screen.dart';

class GameAddition10Screen extends StatefulWidget {
  const GameAddition10Screen({super.key});

  @override
  State<GameAddition10Screen> createState() => _GameAddition10ScreenState();
}

class _GameAddition10ScreenState extends State<GameAddition10Screen>
    with TickerProviderStateMixin {
  final _rand = Random();
  final AudioPlayer _player = AudioPlayer();

  late int a;
  late int b;
  late int answer;
  late List<int> options;

  int correctCount = 0;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 1));
    _newQuestion();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _play(String name) async {
    await _player.play(AssetSource('audios/$name.mp3'));
  }

  void _newQuestion() {
    a = _rand.nextInt(6) + 1;
    b = _rand.nextInt(6) + 1;
    answer = a + b;

    // tránh câu lặp lại hoặc vượt 10
    if (answer > 10) {
      _newQuestion();
      return;
    }

    options = [answer];
    while (options.length < 3) {
      int fake = _rand.nextInt(10) + 1;
      if (!options.contains(fake)) options.add(fake);
    }
    options.shuffle();
    setState(() {});
  }

  Future<void> _check(int value) async {
    final correct = value == answer;

    if (correct) {
      await _play('correct');
      _confettiController.play();
      correctCount++;

      // nếu đúng 10 câu thì thưởng lớn
      if (correctCount >= 10) {
        _showRewardDialog();
      } else {
        _showDialog(
          title: "🎉 Chính xác!",
          content: "Giỏi quá bé ơi! 🌟",
          next: _newQuestion,
        );
      }
    } else {
      await _play('wrong');
      _showDialog(
        title: "❌ Sai rồi",
        content: "Đáp án đúng là $answer",
        next: _newQuestion,
      );
    }
  }

  void _showDialog({
    required String title,
    required String content,
    required VoidCallback next,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, textAlign: TextAlign.center),
        content: Text(content, textAlign: TextAlign.center),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              next();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pinkAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text("Tiếp tục ➡️"),
          )
        ],
      ),
    );
  }

  void _showRewardDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("🏆 Siêu Nhí Toán Học!",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        content: const Text(
          "Bé đã trả lời đúng 10 phép cộng! 🎁\nNhận ngay 3 ngôi sao ✨",
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
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
    final width = MediaQuery.of(context).size.width;

    return BaseScreen(
      title: "Phép cộng ≤10",
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 🌈 Nền gradient mềm mại
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xfffbd1ff), Color(0xffc8d9ff)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // 🎊 Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 25,
              colors: const [
                Colors.pink,
                Colors.yellow,
                Colors.purple,
                Colors.lightBlue,
              ],
            ),
          ),

          // 🐧 Mascot dễ thương
          const Positioned(
            bottom: 100,
            right: 24,
            child: WowMascot(),
          ),

          // 📘 Nội dung chính
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "$a + $b = ?",
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: Colors.deepPurple,
                  shadows: [
                    Shadow(offset: Offset(2, 2), color: Colors.white),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // 🍬 Nút lựa chọn
              Wrap(
                spacing: 20,
                runSpacing: 16,
                children: options
                    .map(
                      (opt) => AnimatedScale(
                    scale: 1,
                    duration: const Duration(milliseconds: 200),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 8,
                      ),
                      onPressed: () => _check(opt),
                      child: Text(
                        "$opt",
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                )
                    .toList(),
              ),
              const SizedBox(height: 40),

              // 🌟 Thanh tiến trình mini
              Container(
                width: width * 0.6,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: correctCount / 10,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text("Tiến độ: $correctCount / 10",
                  style: const TextStyle(
                      color: Colors.deepPurple, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
