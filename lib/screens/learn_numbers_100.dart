import 'dart:convert';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/level.dart';
import '../services/progress_service.dart';
import '../widgets/wow_card.dart';
import 'base_screen.dart';

class LearnNumbers100Screen extends StatefulWidget {
  const LearnNumbers100Screen({super.key});

  @override
  State<LearnNumbers100Screen> createState() => _LearnNumbers100ScreenState();
}

class _LearnNumbers100ScreenState extends State<LearnNumbers100Screen>
    with TickerProviderStateMixin {
  final String levelKey = "0_100"; // 🔹 định danh level này
  List<dynamic> numbers = [];
  int currentIndex = 0;
  int totalStars = 0;
  Set<int> learnedIndexes = {};
  bool isFinalRewardShown = false;

  final AudioPlayer _player = AudioPlayer();
  late ConfettiController _confettiController;
  late ConfettiController _miniConfettiController;

  final List<IconData> rewardIcons = [
    Icons.star,
    Icons.emoji_events,
    Icons.card_giftcard,
    Icons.favorite,
  ];

  @override
  void initState() {
    super.initState();
    _initData();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _miniConfettiController = ConfettiController(duration: const Duration(seconds: 1));
  }

  Future<void> _initData() async {
    await _loadNumbers();
    await _loadProgress();

    // ✅ Khi mở lần đầu, đánh dấu học luôn số đầu tiên
    if (numbers.isNotEmpty && learnedIndexes.isEmpty) {
      _markLearned(0);
    }
  }

  Future<void> _loadNumbers() async {
    final String response = await rootBundle.loadString('assets/configs/numbers_100.json');
    final data = await json.decode(response);
    setState(() {
      numbers = data["numbers"];
    });
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

  void _markLearned(int index) async {
    if (!learnedIndexes.contains(index)) {
      setState(() {
        learnedIndexes.add(index);
        totalStars += 1;
      });
      await _saveProgress();
      if (mounted) _miniConfettiController.play();

      // 🎯 Khi học xong tất cả
      if (totalStars == numbers.length && !isFinalRewardShown) {
        if (mounted) _confettiController.play();

        final levels = await ProgressService.loadLevels();
        final currentIdx = levels.indexWhere(
              (lv) => lv.levelKey == levelKey || lv.route == "/learn_numbers_100",
        );
        if (currentIdx != -1) {
          levels[currentIdx].state = LevelState.completed;
          if (currentIdx + 1 < levels.length &&
              levels[currentIdx + 1].state == LevelState.locked) {
            levels[currentIdx + 1].state = LevelState.playable;
          }
          await ProgressService.saveLevels(levels);
        }

        await _setFinalRewardShown();
        _showRewardPopup(isFinal: true);
      }
    }
  }

  void _next() {
    if (currentIndex < numbers.length - 1) {
      setState(() => currentIndex++);
      _markLearned(currentIndex);
      WidgetsBinding.instance.addPostFrameCallback(
            (_) => WowCard.triggerAnimation(context),
      );
    }
  }

  void _prev() {
    if (currentIndex > 0) {
      setState(() => currentIndex--);
      _markLearned(currentIndex);
      WidgetsBinding.instance.addPostFrameCallback(
            (_) => WowCard.triggerAnimation(context),
      );
    }
  }

  // 🎲 Random học ngẫu nhiên
  void _random() async {
    if (numbers.isEmpty) return;

    final random = Random();
    int newIndex = currentIndex;
    while (newIndex == currentIndex && numbers.length > 1) {
      newIndex = random.nextInt(numbers.length);
    }

    // âm thanh click vui nhộn (nếu có)
    try {
      await _player.play(AssetSource("audio/random.mp3"));
    } catch (_) {}

    setState(() => currentIndex = newIndex);
    _markLearned(currentIndex);
    WidgetsBinding.instance.addPostFrameCallback(
          (_) => WowCard.triggerAnimation(context),
    );
  }

  Future<void> _playAudio(String path) async {
    await _player.stop();
    await _player.play(AssetSource(path.replaceFirst('assets/', '')));
  }

  Future<void> _showRewardPopup({bool isFinal = false}) async {
    final random = Random();
    final icon = rewardIcons[random.nextInt(rewardIcons.length)];
    final size = MediaQuery.of(context).size;

    if (isFinal) {
      try {
        await _player.play(AssetSource("audio/victory.mp3"));
      } catch (_) {}
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  "assets/images/mascot/mascot_10.png",
                  width: size.width * 0.5,
                  height: size.width * 0.5,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 16),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Colors.orange, Colors.pink, Colors.purple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: Text(
                    "🎉 Bé đã học xong 100 số!\n⭐ $totalStars / ${numbers.length} ⭐",
                    style: TextStyle(
                      fontSize: size.width * 0.08,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Siêu giỏi luôn! Hãy bắt đầu học cộng trừ nhé 👏👏",
                  style: TextStyle(
                    fontSize: size.width * 0.05,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 8,
                        color: Colors.black45,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      );
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted && Navigator.canPop(context)) Navigator.pop(context);
      });
      return;
    }

    // 🎁 Popup thường
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 100, color: Colors.yellow),
              const SizedBox(height: 16),
              Text(
                "Tuyệt vời! Bạn đã học ⭐ $totalStars / ${numbers.length}",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(blurRadius: 10, color: Colors.black45, offset: Offset(2, 2)),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && Navigator.canPop(context)) Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (numbers.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final item = numbers[currentIndex];
    final size = MediaQuery.of(context).size;

    return BaseScreen(
      title: "🌟 Số 0–100 🌟",
      child: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(bottom: size.height * 0.25),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: size.height * 0.015),
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
                            valueColor: const AlwaysStoppedAnimation(Colors.amber),
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
                ),
                WowCard(imagePath: item["image"], text: item["text"]),
                SizedBox(height: size.height * 0.04),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.08,
                      vertical: size.height * 0.018,
                    ),
                  ),
                  icon: Icon(Icons.volume_up, size: size.width * 0.07),
                  label: Text("Nghe", style: TextStyle(fontSize: size.width * 0.055)),
                  onPressed: () => _playAudio(item["audio"]),
                ),
                SizedBox(height: size.height * 0.04),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (currentIndex > 0)
                      _circleButton(Icons.arrow_back, _prev, Colors.pinkAccent, size),
                    _circleButton(Icons.shuffle, _random, Colors.amber, size),
                    if (currentIndex < numbers.length - 1)
                      _circleButton(Icons.arrow_forward, _next, Colors.lightBlue, size),
                  ],
                ),
              ],
            ),
          ),
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            colors: const [
              Colors.red,
              Colors.blue,
              Colors.green,
              Colors.orange,
              Colors.purple,
            ],
            gravity: 0.3,
          ),
          Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              confettiController: _miniConfettiController,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 10,
              emissionFrequency: 0.5,
              maxBlastForce: 10,
              minBlastForce: 2,
              colors: const [Colors.yellow, Colors.lightBlue, Colors.pink],
              gravity: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onTap, Color color, Size size) {
    return Ink(
      decoration: ShapeDecoration(shape: const CircleBorder(), color: color),
      child: IconButton(
        icon: Icon(icon, size: size.width * 0.1, color: Colors.white),
        onPressed: onTap,
      ),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _miniConfettiController.dispose();
    super.dispose();
  }
}
