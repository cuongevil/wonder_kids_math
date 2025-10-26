import 'dart:math';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/progress_service.dart';
import '../models/level.dart';

/// 🧮 GameCompareScreen v11.4 — Fixed Progress Reset + Next Level Unlock
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
  bool isLoading = true;
  bool isAnswered = false;

  String? resultText;
  Color? resultColor;

  // FX / UI
  late ConfettiController _confettiController;
  late ConfettiController _miniConfettiController;
  late AnimationController _shimmerController;
  late AnimationController _tapScaleController;
  late AnimationController _bgController;

  String? _pressedOp;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _miniConfettiController =
        ConfettiController(duration: const Duration(seconds: 1));

    _shimmerController =
    AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);

    _tapScaleController = AnimationController(
      vsync: this,
      lowerBound: 0.95,
      upperBound: 1.0,
      duration: const Duration(milliseconds: 150),
    )..value = 1.0;

    _bgController =
    AnimationController(vsync: this, duration: const Duration(seconds: 8))
      ..repeat(reverse: true);

    _initProgress();
  }

  Future<void> _initProgress() async {
    _prefs = await SharedPreferences.getInstance();
    correctCount = _prefs.getInt(progressKey) ?? 0;
    isCompleted = _prefs.getBool(completedKey) ?? false;

    // ✅ Reset nếu đã hoàn thành để chơi mới
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
    _tapScaleController.dispose();
    _bgController.dispose();
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
    isAnswered = false;
    resultText = null;
    resultColor = null;
    setState(() {});
  }

  Future<void> _check(String op) async {
    if (isAnswered) return;
    HapticFeedback.selectionClick();
    isAnswered = true;

    final correctOp = a == b ? "=" : (a < b ? "<" : ">");
    final correct = op == correctOp;

    if (correct) {
      await _play("correct1");
      _miniConfettiController.play();
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
          await Future.delayed(const Duration(milliseconds: 600));
          _onCompleted();
          return;
        }
      }
    } else {
      await _play("wrong");
      setState(() {
        resultText = "❌ Sai rồi — đáp án đúng là: $a $correctOp $b";
        resultColor = Colors.redAccent;
      });
    }

    await Future.delayed(const Duration(milliseconds: 1200));
    _newQuestion();
  }

  Future<void> _onCompleted() async {
    _confettiController.play();
    await _play("victory");

    // 🔓 Mở khóa level kế tiếp
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

    // ✅ Reset lại progress cho lần chơi sau
    await _prefs.setInt(progressKey, 0);
    await _prefs.setBool(completedKey, false);

    _showFinalPopup();
  }

  void _showFinalPopup() {
    final size = MediaQuery.of(context).size;
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
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
                borderRadius: BorderRadius.circular(30),
              ),
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
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.95, end: 1.05),
                      duration: const Duration(milliseconds: 900),
                      curve: Curves.easeInOut,
                      builder: (context, val, child) =>
                          Transform.scale(scale: val, child: child),
                      child: Image.asset(
                        "assets/images/mascot/mascot_10.png",
                        width: size.width * 0.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ShaderMask(
                      shaderCallback: (r) => const LinearGradient(
                        colors: [Colors.white, Color(0xFFFFE082)],
                      ).createShader(r),
                      blendMode: BlendMode.srcATop,
                      child: Text(
                        "Hoàn thành xuất sắc! 🌟",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: size.width * 0.08,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Câu đúng: $correctCount / 10",
                      style: TextStyle(
                        fontSize: size.width * 0.06,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.bold,
                      ),
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
                              const Color(0xFFFF8B00).withOpacity(0.3),
                              blurRadius: 15,
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
            height: size.height * 0.04,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: (size.width * 0.8) * (correctCount / 10).clamp(0.0, 1.0),
            height: size.height * 0.04,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: const LinearGradient(
                colors: [Color(0xFF5E2CED), Color(0xFFFF8B00)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF8B00).withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
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
              height: size.height * 0.04,
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
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
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
          child: CircularProgressIndicator(color: Colors.tealAccent),
        ),
      );
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
            "So sánh số",
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
              return AnimatedShaderMask(colors: colors, child: Container(color: Colors.white));
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
            colors: const [Color(0xFF5E2CED), Color(0xFFFF8B00), Color(0xFFA58CFF)],
          ),
          ConfettiWidget(
            confettiController: _miniConfettiController,
            blastDirectionality: BlastDirectionality.explosive,
            emissionFrequency: 0.1,
            numberOfParticles: 10,
            colors: const [Color(0xFFFFC300), Color(0xFFA58CFF), Color(0xFFFF8B00)],
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
                      Shadow(offset: Offset(0, 1), blurRadius: 4, color: Colors.black26),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                ScaleTransition(
                  scale: _tapScaleController,
                  child: AnimatedContainer(
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
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: AnimatedBuilder(
                      animation: _shimmerController,
                      builder: (_, __) {
                        final shimmerPos = (_shimmerController.value * 2 - 1);
                        return ShaderMask(
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
                            "$a ? $b",
                            style: const TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
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
                  children: ["<", "=", ">"].map((op) {
                    final isPressed = _pressedOp == op;
                    return GestureDetector(
                      onTapDown: (_) => setState(() => _pressedOp = op),
                      onTapCancel: () => setState(() => _pressedOp = null),
                      onTapUp: (_) => setState(() => _pressedOp = null),
                      onTap: () => _check(op),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding:
                        const EdgeInsets.symmetric(horizontal: 38, vertical: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF5E2CED), Color(0xFFFF8B00)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isPressed
                                  ? Colors.white.withOpacity(0.7)
                                  : Colors.black.withOpacity(0.3),
                              blurRadius: isPressed ? 20 : 12,
                              spreadRadius: isPressed ? 1 : 0,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Text(
                          op,
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
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
}

/// 🌈 Gradient động phủ lên child
class AnimatedShaderMask extends StatelessWidget {
  final List<Color> colors;
  final Widget child;
  const AnimatedShaderMask({super.key, required this.colors, required this.child});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: colors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      blendMode: BlendMode.srcATop,
      child: child,
    );
  }
}
