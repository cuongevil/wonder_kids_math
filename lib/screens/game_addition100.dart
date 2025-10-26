import 'dart:math';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/progress_service.dart';

/// ➕ GameAddition100Screen v9.2 — Animated Fintech Gradient + Inline Result + Glow
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
  bool isAnswered = false;
  bool isLoading = true;

  String? resultText;
  Color? resultColor;

  late ConfettiController _confettiController;
  late AnimationController _glowController;
  late AnimationController _gradientController;

  final List<String> praiseVoices = ["correct1", "correct2", "correct3"];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _glowController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _gradientController =
    AnimationController(vsync: this, duration: const Duration(seconds: 8))
      ..repeat(reverse: true);
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
    _glowController.dispose();
    _gradientController.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _play(String name) async {
    try {
      await _player.play(AssetSource('audios/$name.mp3'));
    } catch (_) {}
  }

  void _newQuestion() {
    a = _rand.nextInt(101);
    b = _rand.nextInt(101);
    answer = a + b;
    if (answer > 100) return _newQuestion();

    options = [answer];
    while (options.length < 3) {
      int fake = _rand.nextInt(101);
      if (!options.contains(fake)) options.add(fake);
    }
    options.shuffle();

    isAnswered = false;
    resultText = null;
    resultColor = null;
    setState(() {});
  }

  Future<void> _check(int value) async {
    if (isAnswered) return;
    HapticFeedback.selectionClick();
    isAnswered = true;
    final correct = value == answer;

    if (correct) {
      await _play(praiseVoices[_rand.nextInt(praiseVoices.length)]);
      _confettiController.play();
      _glowController.forward(from: 0);
      setState(() {
        resultText = "🎉 Chính xác rồi!";
        resultColor = const Color(0xFF5E2CED);
      });

      if (!isReviewMode) {
        correctCount++;
        await _prefs.setInt(progressKey, correctCount);
        if (correctCount >= 10 && !isCompleted) {
          isCompleted = true;
          await _prefs.setBool(completedKey, true);
          await Future.delayed(const Duration(milliseconds: 800));
          _showRewardPopup();
          return;
        }
      }
    } else {
      await _play("wrong");
      _glowController.forward(from: 0);
      setState(() {
        resultText = "❌ Sai rồi — Đáp án đúng là $answer";
        resultColor = Colors.redAccent;
      });
    }

    await Future.delayed(const Duration(milliseconds: 1500));
    _newQuestion();
  }

  /// 🎁 Popup hoàn thành Fintech glow
  Future<void> _showRewardPopup() async {
    await _play("victory");
    _confettiController.play();
    await ProgressService.markLevelCompleted("addition100");

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
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset("assets/images/mascot/mascot_10.png",
                        width: size.width * 0.4),
                    const SizedBox(height: 20),
                    const Text(
                      "Bé đã hoàn thành 10 phép cộng ≤ 100! 🌟",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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

  /// 🌈 Animated fintech gradient background
  Widget _animatedBackground() {
    return AnimatedBuilder(
      animation: _gradientController,
      builder: (context, child) {
        final t = _gradientController.value;
        final colors = [
          Color.lerp(const Color(0xFF5E2CED), const Color(0xFFFF8B00), t)!,
          Color.lerp(const Color(0xFFA58CFF), const Color(0xFF5E2CED), 1 - t)!,
        ];
        return ShaderMask(
          shaderCallback: (r) =>
              LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight).createShader(r),
          blendMode: BlendMode.srcATop,
          child: Container(color: Colors.white),
        );
      },
    );
  }

  /// 🌟 UI chính — TPBank Fintech style
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator(color: Colors.tealAccent)));
    }

    final size = MediaQuery.of(context).size;
    final glowValue = _glowController.value;

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
          child: const Text(
            "Phép cộng ≤ 100",
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
          _animatedBackground(),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
            child: Container(color: Colors.white.withOpacity(0.08)),
          ),
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            numberOfParticles: 25,
            gravity: 0.3,
            colors: const [
              Color(0xFF5E2CED),
              Color(0xFFFF8B00),
              Color(0xFFA58CFF),
            ],
          ),
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(top: size.height * 0.15, bottom: 80),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 60, vertical: 30),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF5E2CED), Color(0xFFFF8B00)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(glowValue * 0.6),
                        blurRadius: 30 * glowValue,
                        spreadRadius: 10 * glowValue,
                      ),
                    ],
                  ),
                  child: Text(
                    "$a + $b = ?",
                    style: const TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                AnimatedOpacity(
                  opacity: resultText == null ? 0 : 1,
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    resultText ?? "",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: resultColor,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Wrap(
                  spacing: 20,
                  runSpacing: 16,
                  children: options
                      .map(
                        (opt) => GestureDetector(
                      onTap: () => _check(opt),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 38, vertical: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF5E2CED), Color(0xFFFF8B00)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF5E2CED)
                                  .withOpacity(0.3 + glowValue * 0.3),
                              blurRadius: 12 + 8 * glowValue,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Text(
                          "$opt",
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  )
                      .toList(),
                ),
                const SizedBox(height: 50),
                if (!isReviewMode)
                  Column(
                    children: [
                      Container(
                        width: size.width * 0.6,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: AnimatedFractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          duration: const Duration(milliseconds: 400),
                          widthFactor: correctCount / 10,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFC300), Color(0xFFFF8B00)],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Tiến độ: $correctCount / 10",
                        style: const TextStyle(
                            color: Color(0xFF5E2CED),
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
          ),
        ],
      ),
    );
  }
}
