import 'dart:math';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/progress_service.dart';

/// ➕ GameAddition10Screen v7.0 — Fintech Gradient UI (No Mascot, No BottomBar)
class GameAddition10Screen extends StatefulWidget {
  const GameAddition10Screen({super.key});

  @override
  State<GameAddition10Screen> createState() => _GameAddition10ScreenState();
}

class _GameAddition10ScreenState extends State<GameAddition10Screen>
    with TickerProviderStateMixin {
  final _rand = Random();
  final AudioPlayer _player = AudioPlayer();
  late SharedPreferences _prefs;

  static const String progressKey = "game_addition10_progress";
  static const String completedKey = "game_addition10_completed";

  late int a;
  late int b;
  late int answer;
  late List<int> options;

  int correctCount = 0;
  bool isCompleted = false;
  bool isReviewMode = false;
  bool isLoading = true;
  bool isAnswered = false;

  String? resultText;
  Color? resultColor;

  late ConfettiController _confettiController;
  late ConfettiController _miniConfettiController;
  late AnimationController _shimmerController;
  late AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _miniConfettiController = ConfettiController(duration: const Duration(seconds: 1));
    _shimmerController =
    AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _bgController =
    AnimationController(vsync: this, duration: const Duration(seconds: 8))
      ..repeat(reverse: true);

    _initProgress();
  }

  Future<void> _initProgress() async {
    _prefs = await SharedPreferences.getInstance();
    correctCount = _prefs.getInt(progressKey) ?? 0;
    isCompleted = _prefs.getBool(completedKey) ?? false;

    if (isCompleted) {
      correctCount = 0;
      isCompleted = false;
      isReviewMode = false;
      await _prefs.setInt(progressKey, 0);
      await _prefs.setBool(completedKey, false);
    }

    _newQuestion();
    setState(() => isLoading = false);
  }

  @override
  void dispose() {
    _player.dispose();
    _confettiController.dispose();
    _miniConfettiController.dispose();
    _shimmerController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  Future<void> _play(String name) async {
    try {
      await _player.play(AssetSource('audios/$name.mp3'));
    } catch (_) {}
  }

  void _newQuestion() {
    a = _rand.nextInt(11);
    b = _rand.nextInt(11);
    answer = a + b;
    if (answer > 10) {
      _newQuestion();
      return;
    }

    options = [answer];
    while (options.length < 3) {
      final fake = _rand.nextInt(11);
      if (!options.contains(fake)) options.add(fake);
    }
    options.shuffle();

    resultText = null;
    resultColor = null;
    isAnswered = false;
    setState(() {});
  }

  Future<void> _check(int value) async {
    if (isAnswered) return;
    isAnswered = true;
    final correct = value == answer;

    if (correct) {
      await _play("correct1");
      _miniConfettiController.play();
      resultText = "🎉 Chính xác rồi!";
      resultColor = const Color(0xFF5E2CED);

      if (!isReviewMode) {
        correctCount++;
        await _prefs.setInt(progressKey, correctCount);

        if (correctCount >= 10 && !isCompleted) {
          isCompleted = true;
          await _prefs.setBool(completedKey, true);
          await Future.delayed(const Duration(milliseconds: 600));
          await _onCompleted();
          return;
        }
      }
    } else {
      await _play("wrong");
      resultText = "❌ Sai rồi — đáp án đúng là $answer";
      resultColor = Colors.redAccent;
    }

    setState(() {});
    await Future.delayed(const Duration(milliseconds: 1200));
    _newQuestion();
  }

  Future<void> _onCompleted() async {
    _confettiController.play();
    await _play("victory");

    await ProgressService.markLevelCompleted("addition10");
    await _prefs.setInt(progressKey, 0);
    await _prefs.setBool(completedKey, false);

    _showRewardPopup();
  }

  void _showRewardPopup() {
    final size = MediaQuery.of(context).size;
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (_, anim, __, ___) {
        final scale = Tween<double>(begin: 0.8, end: 1.0)
            .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutBack));
        return Transform.scale(
          scale: scale.value,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Dialog(
              backgroundColor: Colors.white.withOpacity(0.05),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
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
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset("assets/images/mascot/mascot_10.png",
                        width: size.width * 0.4),
                    const SizedBox(height: 20),
                    ShaderMask(
                      shaderCallback: (r) => const LinearGradient(
                        colors: [Colors.white, Color(0xFFFFE082)],
                      ).createShader(r),
                      blendMode: BlendMode.srcATop,
                      child: const Text(
                        "Hoàn thành xuất sắc! 🌟",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Câu đúng: 10 / 10",
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pop(context, true);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF5E2CED), Color(0xFFFF8B00)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                              const Color(0xFFFF8B00).withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Text(
                          "Quay lại bản đồ",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressBar(Size size) {
    final shimmerVal = _shimmerController.value;
    final offset = (shimmerVal * 2 - 1);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size.width * 0.8,
            height: size.height * 0.035,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            width: (size.width * 0.8) * (correctCount / 10).clamp(0.0, 1.0),
            height: size.height * 0.035,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: const LinearGradient(
                colors: [Color(0xFF5E2CED), Color(0xFFFF8B00)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF8B00).withOpacity(0.4),
                  blurRadius: 12,
                ),
              ],
            ),
          ),
          ShaderMask(
            shaderCallback: (r) => LinearGradient(
              begin: Alignment(-1.0 + offset, 0),
              end: Alignment(1.0 + offset, 0),
              colors: [
                Colors.white.withOpacity(0.0),
                Colors.white.withOpacity(0.8),
                Colors.white.withOpacity(0.0),
              ],
              stops: const [0.2, 0.5, 0.8],
            ).createShader(r),
            blendMode: BlendMode.srcATop,
            child: Container(
              width: size.width * 0.8,
              height: size.height * 0.035,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Positioned.fill(
            child: Center(
              child: Text(
                "${(correctCount / 10 * 100).toStringAsFixed(0)}%",
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
          body: Center(
              child: CircularProgressIndicator(color: Colors.tealAccent)));
    }

    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white.withOpacity(0.05),
        centerTitle: true,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(color: Colors.white.withOpacity(0.05)),
          ),
        ),
        title: ShaderMask(
          shaderCallback: (r) => const LinearGradient(
            colors: [Color(0xFF5E2CED), Color(0xFFFF8B00)],
          ).createShader(r),
          blendMode: BlendMode.srcATop,
          child: const Text(
            "Phép cộng ≤10",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _bgController,
            builder: (_, __) {
              final t = _bgController.value;
              final colors = [
                Color.lerp(const Color(0xFF5E2CED),
                    const Color(0xFFFF8B00), t)!,
                Color.lerp(const Color(0xFFA58CFF),
                    const Color(0xFF5E2CED), 1 - t)!,
              ];
              return ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                blendMode: BlendMode.srcATop,
                child: Container(color: Colors.white),
              );
            },
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
            child: Container(color: Colors.white.withOpacity(0.08)),
          ),
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            numberOfParticles: 25,
            colors: const [
              Color(0xFF5E2CED),
              Color(0xFFFF8B00),
              Color(0xFFA58CFF),
            ],
          ),
          ConfettiWidget(
            confettiController: _miniConfettiController,
            blastDirectionality: BlastDirectionality.explosive,
            emissionFrequency: 0.1,
            numberOfParticles: 10,
            colors: const [
              Color(0xFFFFC300),
              Color(0xFFA58CFF),
              Color(0xFFFF8B00),
            ],
          ),
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(top: size.height * 0.12, bottom: 80),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildProgressBar(size),
                const SizedBox(height: 10),
                Text(
                  "Câu đúng: $correctCount / 10",
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 4,
                            color: Colors.black26)
                      ]),
                ),
                const SizedBox(height: 40),
                _buildQuestionCard(size),
                const SizedBox(height: 20),
                if (resultText != null)
                  AnimatedOpacity(
                    opacity: 1,
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      resultText!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: resultColor),
                    ),
                  ),
                const SizedBox(height: 40),
                Wrap(
                  spacing: 20,
                  runSpacing: 16,
                  children: options.map((opt) {
                    return ElevatedButton(
                      onPressed: () => _check(opt),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5E2CED),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 38, vertical: 20),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24)),
                        elevation: 8,
                      ),
                      child: Text(
                        "$opt",
                        style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(Size size) {
    final shimmerPos = (_shimmerController.value * 2 - 1);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 30),
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
              offset: const Offset(0, 6))
        ],
      ),
      child: ShaderMask(
        shaderCallback: (r) => LinearGradient(
          begin: Alignment(-1.0 + shimmerPos, 0),
          end: Alignment(1.0 + shimmerPos, 0),
          colors: [
            Colors.white.withOpacity(0.3),
            Colors.white.withOpacity(0.9),
            Colors.white.withOpacity(0.3),
          ],
          stops: const [0.2, 0.5, 0.8],
        ).createShader(r),
        blendMode: BlendMode.srcATop,
        child: Text(
          "$a + $b = ?",
          style: const TextStyle(
              fontSize: 50,
              fontWeight: FontWeight.w900,
              color: Colors.white),
        ),
      ),
    );
  }
}
