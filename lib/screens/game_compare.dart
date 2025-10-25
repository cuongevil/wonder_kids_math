import 'dart:math';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/wow_mascot.dart';
import '../services/progress_service.dart';
import '../models/level.dart';
import 'base_screen.dart';

/// 🧮 GameCompareScreen v6.0 — Fintech Confetti + Gradient Popup + Victory Glow
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
  bool isReviewMode = false;
  bool isMascotHappy = true;
  bool isLoading = true;

  late ConfettiController _confettiController;
  late ConfettiController _miniConfettiController;
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
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _miniConfettiController = ConfettiController(duration: const Duration(seconds: 1));
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
    isReviewMode = isCompleted;
    _newQuestion();
    setState(() => isLoading = false);
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _miniConfettiController.dispose();
    _popupController.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _play(String name) async {
    try {
      await _player.play(AssetSource('audios/$name.mp3'));
    } catch (_) {}
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
      _miniConfettiController.play();
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
          await _showRewardPopup();
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
        scale: CurvedAnimation(parent: _popupController, curve: Curves.elasticOut),
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold)),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text("Tiếp tục ➡️"),
            ),
          ],
        ),
      ),
    );
  }

  /// 🌈 Popup hoàn thành Fintech gradient blur
  Future<void> _showRewardPopup() async {
    await _play("victory");
    _confettiController.play();

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

    final size = MediaQuery.of(context).size;
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) => Container(),
      transitionBuilder: (_, anim, __, ___) {
        final scale =
        Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutBack));

        return Transform.scale(
          scale: scale.value,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Dialog(
              backgroundColor: Colors.white.withOpacity(0.05),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              insetPadding: const EdgeInsets.all(24),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5E2CED), Color(0xFFFF8B00)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 🐱 Mascot glow
                    AnimatedScale(
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutBack,
                      scale: scale.value,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.6),
                              blurRadius: 25,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: Image.asset(
                          "assets/images/mascot/mascot_10.png",
                          width: size.width * 0.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ShaderMask(
                      shaderCallback: (r) => const LinearGradient(
                        colors: [Colors.white, Color(0xFFFFE082)],
                      ).createShader(r),
                      child: const Text(
                        "Bé đã hoàn thành 10 câu so sánh! 🌟",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pop(context, true);
                      },
                      child: Container(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF5E2CED), Color(0xFFFF8B00)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF5E2CED).withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Text(
                          "Quay lại bản đồ",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
          body: Center(
              child: CircularProgressIndicator(color: Colors.tealAccent)));
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
                colors: [Color(0xFFE9E4FF), Color(0xFFF9E0B0)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // 🌈 Confetti fintech 3 tầng
          Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              emissionFrequency: 0.05,
              numberOfParticles: 25,
              maxBlastForce: 10,
              gravity: 0.3,
              colors: const [
                Color(0xFF5E2CED),
                Color(0xFFFF8B00),
                Color(0xFFA58CFF),
              ],
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              confettiController: _miniConfettiController,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 10,
              maxBlastForce: 6,
              gravity: 0.4,
              colors: const [
                Color(0xFFFFC300),
                Color(0xFF7E57C2),
                Color(0xFFFF80AB),
              ],
            ),
          ),

          // 🐱 Mascot
          Positioned(bottom: 100, right: 24, child: WowMascot.only(isHappy: isMascotHappy, scale: 0.8)),

          // ⚡ UI chính
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "$a ? $b",
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
                children: ["<", "=", ">"]
                    .map((op) => ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.tealAccent.shade400,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
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
                ))
                    .toList(),
              ),
              const SizedBox(height: 40),
              if (!isReviewMode)
                Column(
                  children: [
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
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                )
              else
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
