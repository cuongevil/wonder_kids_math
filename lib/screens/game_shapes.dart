import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/progress_service.dart';
import '../widgets/wow_mascot.dart';
import 'base_screen.dart';

class GameShapesScreen extends StatefulWidget {
  const GameShapesScreen({super.key});

  @override
  State<GameShapesScreen> createState() => _GameShapesScreenState();
}

class _GameShapesScreenState extends State<GameShapesScreen>
    with TickerProviderStateMixin {
  final _rand = Random();
  final AudioPlayer _player = AudioPlayer();
  late SharedPreferences _prefs;

  static const String progressKey = "game_shapes_progress";
  static const String completedKey = "game_shapes_completed";
  static const String levelKey = "shapes"; // 🔹 Key dùng cho MapScreen

  final List<Map<String, dynamic>> shapes = [
    {"name": "Hình tròn", "icon": Icons.circle},
    {"name": "Hình vuông", "icon": Icons.square},
    {"name": "Tam giác", "icon": Icons.change_history},
    {"name": "Chữ nhật", "icon": Icons.rectangle},
  ];

  late Map<String, dynamic> currentShape;
  late List<Map<String, dynamic>> options;

  int correctCount = 0;
  bool isCompleted = false;
  bool isReviewMode = false;
  bool isMascotHappy = true;
  bool isLoading = true;

  late ConfettiController _confettiController;
  late AnimationController _popupController;

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
    currentShape = shapes[_rand.nextInt(shapes.length)];
    options = [...shapes]..shuffle();
    setState(() {});
  }

  Future<void> _check(String name) async {
    final correct = name == currentShape["name"];
    if (correct) {
      isMascotHappy = true;
      _confettiController.play();
      await _play("correct1");

      if (!isReviewMode) {
        correctCount++;
        await _prefs.setInt(progressKey, correctCount);

        // ✅ Khi hoàn thành tất cả hình
        if (correctCount >= shapes.length && !isCompleted) {
          isCompleted = true;
          await _prefs.setBool(completedKey, true);

          // 🔹 Đánh dấu level hoàn thành & mở khóa kế tiếp
          await ProgressService.markLevelCompleted(levelKey);

          await Future.delayed(const Duration(milliseconds: 600));
          _showRewardDialog();
          return;
        }
      }

      _showDialog(
        title: "🎉 Chính xác!",
        content: "Đúng là ${currentShape["name"]}! 🌟",
        next: _newQuestion,
      );
    } else {
      isMascotHappy = false;
      await _play("wrong");
      _showDialog(
        title: "❌ Sai rồi",
        content: "Đáp án đúng là ${currentShape["name"]}",
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
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
                backgroundColor: Colors.tealAccent.shade400,
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

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ScaleTransition(
        scale: CurvedAnimation(
          parent: _popupController,
          curve: Curves.easeOutBack,
        ),
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "🏆 Bé siêu quá!",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "Bé đã nhận biết hết 4 hình cơ bản! 🌟",
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Colors.tealAccent),
        ),
      );
    }

    return BaseScreen(
      title: "Hình học cơ bản",
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 🎉 Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 30,
              colors: const [
                Colors.teal,
                Colors.amber,
                Colors.pink,
                Colors.purple,
              ],
            ),
          ),

          // 🐧 Mascot
          Positioned(
            bottom: 100,
            right: 24,
            child: WowMascot(isHappy: isMascotHappy),
          ),

          // 📘 Nội dung chính
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(currentShape["icon"], size: 140, color: Colors.deepPurple),
              const SizedBox(height: 40),

              // ✅ 4 nút có cùng chiều rộng, chia 2 cột
              LayoutBuilder(
                builder: (context, constraints) {
                  const spacing = 20.0;
                  const runSpacing = 16.0;
                  const columns = 2;
                  final btnWidth =
                      (constraints.maxWidth - (columns - 1) * spacing) /
                      columns;

                  return Wrap(
                    spacing: spacing,
                    runSpacing: runSpacing,
                    alignment: WrapAlignment.center,
                    children: options.map((s) {
                      return SizedBox(
                        width: btnWidth,
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            backgroundColor: Colors.tealAccent.shade400,
                            foregroundColor: Colors.white,
                            elevation: 8,
                          ),
                          onPressed: () => _check(s["name"]),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              s["name"],
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),

              const SizedBox(height: 40),
              if (!isReviewMode)
                Text(
                  "Tiến độ: $correctCount / ${shapes.length}",
                  style: const TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                  ),
                )
              else
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
