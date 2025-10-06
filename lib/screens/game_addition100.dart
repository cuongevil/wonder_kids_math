import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/progress_service.dart';
import '../widgets/wow_mascot.dart';
import 'base_screen.dart';

class GameAddition100Screen extends StatefulWidget {
  const GameAddition100Screen({super.key});

  @override
  State<GameAddition100Screen> createState() => _GameAddition100ScreenState();
}

class _GameAddition100ScreenState extends State<GameAddition100Screen>
    with TickerProviderStateMixin {
  final _rand = Random();
  final AudioPlayer _player = AudioPlayer();
  late SharedPreferences _prefs;

  static const String progressKey = "game_addition100_progress";
  static const String completedKey = "game_addition100_completed";

  late int a;
  late int b;
  late int answer;
  late List<int> options;

  int correctCount = 0;
  bool isCompleted = false;
  bool isReviewMode = false;
  bool isMascotHappy = true;
  bool isLoading = true;

  late ConfettiController _confettiController;
  late AnimationController _popupController;

  final List<String> praiseVoices = ["correct1", "correct2", "correct3"];
  final List<String> praiseTexts = [
    "Giỏi quá bé ơi! 🌟",
    "Tuyệt vời! 💪",
    "Siêu đỉnh luôn! 🦸",
    "Bé thông minh quá! 🧠",
    "Yeah! Chính xác rồi 🎉",
  ];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 1),
    );
    _popupController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      lowerBound: 0.7,
      upperBound: 1.0,
    );
    _initProgress();
  }

  Future<void> _initProgress() async {
    _prefs = await SharedPreferences.getInstance();
    correctCount = _prefs.getInt(progressKey) ?? 0;
    isCompleted = _prefs.getBool(completedKey) ?? false;

    if (isCompleted) isReviewMode = true;
    _newQuestion();
    setState(() => isLoading = false);
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _popupController.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _play(String name) async {
    await _player.play(AssetSource('audios/$name.mp3'));
  }

  void _newQuestion() {
    a = _rand.nextInt(101);
    b = _rand.nextInt(101);
    answer = a + b;

    if (answer > 100) {
      _newQuestion();
      return;
    }

    options = [answer];
    while (options.length < 3) {
      int fake = _rand.nextInt(101);
      if (!options.contains(fake)) options.add(fake);
    }
    options.shuffle();
    setState(() {});
  }

  Future<void> _check(int value) async {
    final correct = value == answer;

    if (correct) {
      isMascotHappy = true;
      _confettiController.play();
      await _play(praiseVoices[_rand.nextInt(praiseVoices.length)]);

      if (!isReviewMode) {
        correctCount++;
        await _prefs.setInt(progressKey, correctCount);

        if (correctCount >= 10 && !isCompleted) {
          isCompleted = true;
          await _prefs.setBool(completedKey, true);
          await Future.delayed(const Duration(milliseconds: 600));
          _showRewardDialog();
          return;
        }
      }

      _popupController.forward(from: 0.7);
      _showDialog(
        title: "🎉 Chính xác!",
        content: praiseTexts[_rand.nextInt(praiseTexts.length)],
        next: _newQuestion,
      );
    } else {
      isMascotHappy = false;
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
      builder: (_) => ScaleTransition(
        scale: CurvedAnimation(
          parent: _popupController,
          curve: Curves.elasticOut,
        ),
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(content, textAlign: TextAlign.center),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                next();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text("Tiếp tục ➡️"),
            ),
          ],
        ),
      ),
    );
  }

  void _showRewardDialog() async {
    await _play("victory");
    _confettiController.play();

    await ProgressService.markLevelCompleted("addition100");

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ScaleTransition(
        scale: CurvedAnimation(
          parent: _popupController,
          curve: Curves.easeOutBack,
        ),
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "🏆 Giỏi quá!",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "Bé đã hoàn thành 10 phép cộng ≤100! 🌟",
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
      ),
    );
  }

  Future<void> _resetProgress() async {
    await _prefs.remove(progressKey);
    await _prefs.remove(completedKey);
    setState(() {
      correctCount = 0;
      isCompleted = false;
      isReviewMode = false;
    });
    Navigator.pop(context);
    _newQuestion();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Colors.lightBlueAccent),
        ),
      );
    }

    final width = MediaQuery.of(context).size.width;

    return BaseScreen(
      title: "Phép cộng ≤100",
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 🌈 Nền gradient xanh nhạt
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xffb9f0ff), Color(0xffecd6ff)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 30,
              colors: const [
                Colors.lightBlueAccent,
                Colors.amber,
                Colors.pinkAccent,
                Colors.purpleAccent,
              ],
            ),
          ),
          Positioned(
            bottom: 100,
            right: 24,
            child: WowMascot(isHappy: isMascotHappy),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "$a + $b = ?",
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: Colors.deepPurple,
                  shadows: [Shadow(offset: Offset(2, 2), color: Colors.white)],
                ),
              ),
              const SizedBox(height: 30),
              Wrap(
                spacing: 20,
                runSpacing: 16,
                children: options
                    .map(
                      (opt) => ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlueAccent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 18,
                          ),
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
                    )
                    .toList(),
              ),
              const SizedBox(height: 40),
              if (!isReviewMode) ...[
                Container(
                  width: width * 0.6,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: AnimatedFractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    duration: const Duration(milliseconds: 400),
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
                Text(
                  "Tiến độ: $correctCount / 10",
                  style: const TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ] else
                const Text(
                  "Chế độ ôn luyện 🌈",
                  style: TextStyle(
                    color: Colors.pinkAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
