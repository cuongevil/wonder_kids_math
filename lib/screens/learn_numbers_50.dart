import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/level.dart';
import '../services/progress_service.dart';
import '../widgets/wow_card.dart';
import 'base_screen.dart';

/// 🌟 LearnNumbers50Screen v6.0 — Fintech Confetti + Gradient Popup + Fixed Star Logic
class LearnNumbers50Screen extends StatefulWidget {
  const LearnNumbers50Screen({super.key});

  @override
  State<LearnNumbers50Screen> createState() => _LearnNumbers50ScreenState();
}

class _LearnNumbers50ScreenState extends State<LearnNumbers50Screen>
    with TickerProviderStateMixin {
  final String levelKey = "0_50";
  List<dynamic> numbers = [];
  int currentIndex = 0;
  int totalStars = 0;
  Map<String, bool> learnedIndexes = {};
  bool isFinalRewardShown = false;

  final AudioPlayer _player = AudioPlayer();
  late ConfettiController _confettiController;
  late ConfettiController _miniConfettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _miniConfettiController = ConfettiController(duration: const Duration(seconds: 1));
    _initData();
  }

  Future<void> _initData() async {
    await _loadNumbers();
    await _loadProgress();

    // ✅ Chỉ đánh dấu học khi chưa có dữ liệu
    if (numbers.isNotEmpty && learnedIndexes.isEmpty) {
      _markLearned(0, playReward: false);
    }
  }

  Future<void> _loadNumbers() async {
    final response = await rootBundle.loadString('assets/configs/numbers_50.json');
    final data = json.decode(response);
    numbers = data["numbers"];
    setState(() {});
  }

  Future<void> _loadProgress() async {
    totalStars = await ProgressService.getStars(levelKey);
    learnedIndexes = await ProgressService.getLearnedIndexes(levelKey);
    final prefs = await SharedPreferences.getInstance();
    isFinalRewardShown = prefs.getBool("isFinalRewardShown_$levelKey") ?? false;
    setState(() {});
  }

  Future<void> _saveProgress() async {
    await ProgressService.saveStars(levelKey, totalStars);
    await ProgressService.saveLearnedIndexes(levelKey, learnedIndexes);
  }

  Future<void> _setFinalRewardShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isFinalRewardShown_$levelKey", true);
    setState(() => isFinalRewardShown = true);
  }

  Future<void> _markLearned(int index, {bool playReward = true}) async {
    final key = index.toString();

    // ✅ Nếu đã học thì bỏ qua
    if (learnedIndexes.containsKey(key)) return;

    learnedIndexes[key] = true;
    totalStars = learnedIndexes.length;
    setState(() {});
    unawaited(_saveProgress());

    if (playReward) _miniConfettiController.play();

    // 🎯 Khi học xong toàn bộ
    if (learnedIndexes.length >= numbers.length && !isFinalRewardShown) {
      await _onAllLearned();
    }
  }

  Future<void> _onAllLearned() async {
    _confettiController.play();
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      await _player.play(AssetSource("audio/victory.mp3"));
    } catch (_) {}

    final levels = await ProgressService.loadLevels();
    final currentIdx = levels.indexWhere((lv) => lv.levelKey == levelKey);

    if (currentIdx != -1) {
      levels[currentIdx].state = LevelState.completed;
      if (currentIdx + 1 < levels.length &&
          levels[currentIdx + 1].state == LevelState.locked) {
        levels[currentIdx + 1].state = LevelState.playable;
      }
      await ProgressService.saveLevels(levels);
      await ProgressService.markLevelCompleted(levelKey);
    }

    await _setFinalRewardShown();
    setState(() {});
    _showFinalPopup();
  }

  void _next() {
    if (currentIndex < numbers.length - 1) {
      setState(() => currentIndex++);
      _markLearned(currentIndex);
    } else {
      _markLearned(currentIndex);
    }
  }

  void _prev() {
    if (currentIndex > 0) {
      setState(() => currentIndex--);
      _markLearned(currentIndex, playReward: false);
    }
  }

  void _random() async {
    if (numbers.isEmpty) return;
    final random = Random();
    int newIndex = currentIndex;
    while (newIndex == currentIndex && numbers.length > 1) {
      newIndex = random.nextInt(numbers.length);
    }
    try {
      await _player.play(AssetSource("audio/random.mp3"));
    } catch (_) {}
    setState(() => currentIndex = newIndex);
    _markLearned(currentIndex);
  }

  Future<void> _playAudio(String path) async {
    await _player.stop();
    try {
      await _player.play(AssetSource(path.replaceFirst('assets/', '')));
    } catch (_) {}
  }

  /// 🎊 Popup hoàn thành gradient blur kiểu TPBank Mobile
  void _showFinalPopup() {
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
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
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
                    // 🐱 Mascot Glow Pulse
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
                              color: Colors.white.withOpacity(0.5),
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
                      child: Text(
                        "Hoàn thành xuất sắc!",
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
                      "⭐ $totalStars / ${numbers.length} ⭐",
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
                          horizontal: 40,
                          vertical: 16,
                        ),
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

  @override
  Widget build(BuildContext context) {
    if (numbers.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final item = numbers[currentIndex];
    final size = MediaQuery.of(context).size;

    return BaseScreen(
      title: "🌟 Số 0–50 🌟",
      child: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(bottom: size.height * 0.25),
            child: Column(
              children: [
                _progressBar(size),
                WowCard(imagePath: item["image"], text: item["text"]),
                const SizedBox(height: 20),
                _mainButton(
                  icon: Icons.volume_up,
                  label: "Nghe số này",
                  color: Colors.orangeAccent,
                  onPressed: () => _playAudio(item["audio"]),
                ),
                const SizedBox(height: 25),
                _navigationButtons(size),
              ],
            ),
          ),
          _buildConfetti(),
        ],
      ),
    );
  }

  Widget _progressBar(Size size) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: SizedBox(
      width: size.width * 0.7,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: (totalStars / numbers.length).clamp(0, 1),
              minHeight: size.height * 0.04,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation(Color(0xFFFFC300)),
            ),
          ),
          Text(
            "⭐ $totalStars / ${numbers.length}",
            style: TextStyle(
              fontSize: size.width * 0.05,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _mainButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) =>
      ElevatedButton.icon(
        icon: Icon(icon, size: 30),
        label: Text(label, style: const TextStyle(fontSize: 20)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        ),
        onPressed: onPressed,
      );

  Widget _navigationButtons(Size size) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      if (currentIndex > 0)
        _circleButton(Icons.arrow_back, _prev, Colors.pinkAccent, size),
      _circleButton(Icons.shuffle, _random, Colors.amber, size),
      if (currentIndex < numbers.length - 1)
        _circleButton(Icons.arrow_forward, _next, Colors.lightBlue, size),
    ],
  );

  Widget _circleButton(
      IconData icon,
      VoidCallback onTap,
      Color color,
      Size size,
      ) {
    return Ink(
      decoration: ShapeDecoration(shape: const CircleBorder(), color: color),
      child: IconButton(
        icon: Icon(icon, size: size.width * 0.1, color: Colors.white),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildConfetti() {
    return Stack(
      children: [
        Align(
          alignment: Alignment.center,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            emissionFrequency: 0.05,
            numberOfParticles: 20,
            maxBlastForce: 10,
            minBlastForce: 2,
            gravity: 0.2,
            colors: const [
              Color(0xFF5E2CED),
              Color(0xFFFF8B00),
              Color(0xFFA58CFF),
            ],
            particleDrag: 0.05,
            shouldLoop: false,
            createParticlePath: _drawStar,
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            emissionFrequency: 0.08,
            numberOfParticles: 40,
            maxBlastForce: 15,
            minBlastForce: 5,
            gravity: 0.3,
            colors: const [
              Color(0xFFE4B5FF),
              Color(0xFFFFD180),
              Color(0xFFB388FF),
            ],
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: ConfettiWidget(
            confettiController: _miniConfettiController,
            blastDirectionality: BlastDirectionality.explosive,
            numberOfParticles: 10,
            maxBlastForce: 10,
            minBlastForce: 2,
            gravity: 0.4,
            colors: const [
              Color(0xFFFFC300),
              Color(0xFF7E57C2),
              Color(0xFFFF80AB),
            ],
          ),
        ),
      ],
    );
  }

  Path _drawStar(Size size) {
    double degToRad(double deg) => deg * (pi / 180.0);
    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(halfWidth + externalRadius * cos(step),
          halfWidth + externalRadius * sin(step));
      path.lineTo(halfWidth + internalRadius * cos(step + halfDegreesPerStep),
          halfWidth + internalRadius * sin(step + halfDegreesPerStep));
    }

    path.close();
    return path;
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _miniConfettiController.dispose();
    _player.dispose();
    super.dispose();
  }
}
