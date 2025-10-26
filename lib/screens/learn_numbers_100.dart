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

/// 🌟 LearnNumbers100Screen v7.3 — Gradient Shimmer CTA + TPBank Blur Popup
class LearnNumbers100Screen extends StatefulWidget {
  const LearnNumbers100Screen({super.key});

  @override
  State<LearnNumbers100Screen> createState() => _LearnNumbers100ScreenState();
}

class _LearnNumbers100ScreenState extends State<LearnNumbers100Screen>
    with TickerProviderStateMixin {
  final String levelKey = "0_100";
  List<dynamic> numbers = [];
  int currentIndex = 0;
  int totalStars = 0;
  Map<String, bool> learnedIndexes = {};
  bool isFinalRewardShown = false;

  final AudioPlayer _player = AudioPlayer();
  late ConfettiController _confettiController;
  late ConfettiController _miniConfettiController;
  late AnimationController _shimmerController;
  late AnimationController _tapScaleController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _miniConfettiController = ConfettiController(duration: const Duration(seconds: 1));
    _shimmerController =
    AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _tapScaleController = AnimationController(
      vsync: this,
      lowerBound: 0.95,
      upperBound: 1.0,
      duration: const Duration(milliseconds: 150),
    )..value = 1.0;
    _initData();
  }

  Future<void> _initData() async {
    await _loadNumbers();
    await _loadProgress();
    if (numbers.isNotEmpty && learnedIndexes.isEmpty) {
      _markLearned(0, playReward: false);
    }
  }

  Future<void> _loadNumbers() async {
    final response = await rootBundle.loadString('assets/configs/numbers_100.json');
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
    if (learnedIndexes.containsKey(key)) return;
    learnedIndexes[key] = true;
    totalStars = learnedIndexes.length;
    setState(() {});
    unawaited(_saveProgress());
    if (playReward) _miniConfettiController.play();
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
    _showFinalPopup();
  }

  void _next() {
    if (currentIndex < numbers.length - 1) {
      _onTapFeedback();
      setState(() => currentIndex++);
      _markLearned(currentIndex);
    }
  }

  void _prev() {
    if (currentIndex > 0) {
      _onTapFeedback();
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
    _onTapFeedback();
    setState(() => currentIndex = newIndex);
    _markLearned(currentIndex);
  }

  void _onTapFeedback() {
    HapticFeedback.selectionClick();
    _tapScaleController.reverse().then((_) => _tapScaleController.forward());
  }

  Future<void> _playAudio(String path) async {
    await _player.stop();
    _onTapFeedback();
    try {
      await _player.play(AssetSource(path.replaceFirst('assets/', '')));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (numbers.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final item = numbers[currentIndex];
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
          child: const Text(
            "Học số 0–100",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(top: 100, bottom: size.height * 0.25),
        child: Column(
          children: [
            _progressBar(size),
            const SizedBox(height: 20),
            _buildShimmerCard(item, size),
            const SizedBox(height: 30),
            _animatedCTA(size, item),
            const SizedBox(height: 25),
            _navigationButtons(size),
            _buildConfetti(),
          ],
        ),
      ),
    );
  }

  /// Card chữ auto-scale
  Widget _buildShimmerCard(dynamic item, Size size) {
    final shimmerVal = _shimmerController.value;
    final offset = (shimmerVal * 2 - 1);
    final text = item["text"] ?? "";
    final isLongText = text.length > 6;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [Color(0xFF7B4FFF), Color(0xFFFF8B00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Image.asset(item["image"], width: size.width * 0.55),
            const SizedBox(height: 16),
            ShaderMask(
              shaderCallback: (r) => LinearGradient(
                begin: Alignment(-1.0 + offset, 0),
                end: Alignment(1.0 + offset, 0),
                colors: [
                  Colors.white.withOpacity(0.3),
                  Colors.white.withOpacity(0.8),
                  Colors.white.withOpacity(0.3),
                ],
              ).createShader(r),
              blendMode: BlendMode.srcATop,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    height: 1.1,
                    fontSize: isLongText ? size.width * 0.12 : size.width * 0.18,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// CTA shimmer gradient
  Widget _animatedCTA(Size size, dynamic item) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, _) {
        final shimmerValue = _shimmerController.value;
        final offset = (shimmerValue * 2 - 1);
        return GestureDetector(
          onTap: () => _playAudio(item["audio"]),
          onTapDown: (_) => _onTapFeedback(),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 30),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: const LinearGradient(
                colors: [Color(0xFF5E2CED), Color(0xFFFF8B00)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF8B00).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                ShaderMask(
                  shaderCallback: (r) => LinearGradient(
                    begin: Alignment(-1.0 + offset, 0),
                    end: Alignment(1.0 + offset, 0),
                    colors: [
                      Colors.white.withOpacity(0.0),
                      Colors.white.withOpacity(0.5),
                      Colors.white.withOpacity(0.0),
                    ],
                    stops: const [0.2, 0.5, 0.8],
                  ).createShader(r),
                  blendMode: BlendMode.srcATop,
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.volume_up, color: Colors.white, size: 28),
                    SizedBox(width: 10),
                    Text(
                      "Nghe số này",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _progressBar(Size size) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: SizedBox(
      width: size.width * 0.7,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: LinearProgressIndicator(
          value: (totalStars / numbers.length).clamp(0, 1),
          minHeight: size.height * 0.04,
          backgroundColor: Colors.white.withOpacity(0.2),
          valueColor:
          const AlwaysStoppedAnimation<Color>(Color(0xFFFFC300)),
        ),
      ),
    ),
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

  Widget _buildConfetti() => Stack(
    children: [
      Align(
        alignment: Alignment.center,
        child: ConfettiWidget(
          confettiController: _confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          emissionFrequency: 0.05,
          numberOfParticles: 20,
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
          colors: const [
            Color(0xFFFFC300),
            Color(0xFF7E57C2),
            Color(0xFFFF80AB),
          ],
        ),
      ),
    ],
  );

  void _showFinalPopup() {
    final size = MediaQuery.of(context).size;
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) => Container(),
      transitionBuilder: (_, anim, __, ___) {
        final scale =
        Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(
          parent: anim,
          curve: Curves.easeOutBack,
        ));
        return Transform.scale(
          scale: scale.value,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Dialog(
              backgroundColor: Colors.white.withOpacity(0.05),
              shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
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
                    Image.asset("assets/images/mascot/mascot_10.png",
                        width: size.width * 0.4),
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
                            horizontal: 40, vertical: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF5E2CED), Color(0xFFFF8B00)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF8B00).withOpacity(0.3),
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

  @override
  void dispose() {
    _confettiController.dispose();
    _miniConfettiController.dispose();
    _shimmerController.dispose();
    _tapScaleController.dispose();
    _player.dispose();
    super.dispose();
  }
}
