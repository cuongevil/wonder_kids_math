import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/wow_mascot.dart';
import '../services/progress_service.dart';
import '../models/level.dart';
import 'base_screen.dart';

class GameCompareScreen extends StatefulWidget {
  const GameCompareScreen({super.key});

  @override
  State<GameCompareScreen> createState() => _GameCompareScreenState();
}

class _GameCompareScreenState extends State<GameCompareScreen>
    with TickerProviderStateMixin {
  final _rand = Random();
  final AudioPlayer _player = AudioPlayer();
  late SharedPreferences _prefs;

  static const String progressKey = "game_compare_progress";
  static const String completedKey = "game_compare_completed";

  late int a;
  late int b;

  int correctCount = 0;
  bool isCompleted = false;
  bool isReviewMode = false; // ✅ chế độ ôn luyện
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
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 1));
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

    if (isCompleted) {
      isReviewMode = true;
    }

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
    a = _rand.nextInt(10) + 1;
    b = _rand.nextInt(10) + 1;
    setState(() {});
  }

  Future<void> _check(String op) async {
    final correctOp = a == b ? "=" : (a < b ? "<" : ">");
    final correct = op == correctOp;

    if (correct) {
      isMascotHappy = true;
      _confettiController.play();

      final voice = praiseVoices[_rand.nextInt(praiseVoices.length)];
      await _play(voice);

      if (!isReviewMode) {
        correctCount++;
        await _prefs.setInt(progressKey, correctCount);

        if (correctCount >= 10 && !isCompleted) {
          isCompleted = true;
          await _prefs.setBool(completedKey, true);

          await Future.delayed(const Duration(milliseconds: 600));
          await _showRewardDialog();
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
        content: "Đáp án đúng là: $a $correctOp $b",
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
        scale:
        CurvedAnimation(parent: _popupController, curve: Curves.elasticOut),
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                backgroundColor: Colors.tealAccent.shade400,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text("Tiếp tục ➡️"),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _showRewardDialog() async {
    await _play("victory");
    _confettiController.play();

    // ✅ Cập nhật trạng thái level
    final levels = await ProgressService.ensureDefaultLevels(() => []);
    final index = levels.indexWhere((e) => e.levelKey == "compare");
    if (index != -1) {
      levels[index].state = LevelState.completed;
      if (index + 1 < levels.length &&
          levels[index + 1].state == LevelState.locked) {
        levels[index + 1].state = LevelState.playable;
      }
      await ProgressService.saveLevels(levels);
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ScaleTransition(
        scale:
        CurvedAnimation(parent: _popupController, curve: Curves.easeOutBack),
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            "🏆 Giỏi quá!",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "Bé đã hoàn thành 10 câu so sánh! 🌟",
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context, true); // Báo về MapScreen
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Colors.tealAccent),
        ),
      );
    }

    final width = MediaQuery.of(context).size.width;

    return BaseScreen(
      title: "So sánh số",
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xffd9f3ff), Color(0xffe0c3fc)],
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
                Colors.pink,
                Colors.yellow,
                Colors.purple,
                Colors.lightBlue,
              ],
            ),
          ),
          Positioned(
            bottom: 100,
            right: 24,
            child: WowMascot.only(isHappy: isMascotHappy, scale: 0.8)
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "$a ? $b",
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
              Wrap(
                spacing: 20,
                runSpacing: 16,
                children: ["<", "=", ">"]
                    .map(
                      (op) => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.tealAccent.shade400,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 8,
                    ),
                    onPressed: () => _check(op),
                    child: Text(
                      op,
                      style: const TextStyle(
                        fontSize: 32,
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
                    color: Colors.teal,
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
