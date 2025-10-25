import 'dart:math';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/progress_service.dart';
import '../widgets/wow_mascot.dart';
import 'base_screen.dart';

/// 🔺 GameShapesScreen v6.0 — Fintech Glow Gradient + Confetti 3 tầng
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
  static const String levelKey = "shapes"; // 🔹 Dùng cho MapScreen

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
  late ConfettiController _miniConfettiController;
  late AnimationController _popupController;

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
    currentShape = shapes[_rand.nextInt(shapes.length)];
    options = [...shapes]..shuffle();
    setState(() {});
  }

  Future<void> _check(String name) async {
    final correct = name == currentShape["name"];
    if (correct) {
      isMascotHappy = true;
      _miniConfettiController.play();
      await _play("correct1");

      if (!isReviewMode) {
        correctCount++;
        await _prefs.setInt(progressKey, correctCount);

        if (correctCount >= shapes.length && !isCompleted) {
          isCompleted = true;
          await _prefs.setBool(completedKey, true);
          await ProgressService.markLevelCompleted(levelKey);
          await Future.delayed(const Duration(milliseconds: 500));
          await _showRewardPopup();
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

  /// 🎊 Popup hoàn thành gradient Fintech lung linh
  Future<void> _showRewardPopup() async {
    await _play("victory");
    _confettiController.play();

    final size = MediaQuery.of(context).size;
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) => Container(),
      transitionBuilder: (_, anim, __, ___) {
        final scale = Tween<double>(begin: 0.8, end: 1.0)
            .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutBack));

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
                        "Bé đã nhận biết hết 4 hình cơ bản! 🌟",
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
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
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

    return BaseScreen(
      title: "Hình học cơ bản",
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFC8FFF4), Color(0xFFEED6FF)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // 🎊 Confetti 3 tầng Fintech
          Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              emissionFrequency: 0.05,
              numberOfParticles: 25,
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
              gravity: 0.4,
              colors: const [
                Color(0xFFFFC300),
                Color(0xFF7E57C2),
                Color(0xFFFF80AB),
              ],
            ),
          ),

          Positioned(bottom: 100, right: 24, child: WowMascot.only(isHappy: isMascotHappy, scale: 0.8)),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(currentShape["icon"], size: 140, color: Colors.deepPurple),
              const SizedBox(height: 40),

              // ✅ 4 nút chia 2 cột
              LayoutBuilder(
                builder: (context, constraints) {
                  const spacing = 20.0;
                  const runSpacing = 16.0;
                  const columns = 2;
                  final btnWidth = (constraints.maxWidth - (columns - 1) * spacing) / columns;

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
