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

class LearnNumbers50Screen extends StatefulWidget {
  const LearnNumbers50Screen({super.key});

  @override
  State<LearnNumbers50Screen> createState() => _LearnNumbers50ScreenState();
}

class _LearnNumbers50ScreenState extends State<LearnNumbers50Screen>
    with TickerProviderStateMixin {
  final String levelKey = "0_10"; // 🔹 định danh level này
  List<dynamic> numbers = [];
  int currentIndex = 0;
  int totalStars = 0;
  Set<int> learnedIndexes = {};
  bool isFinalRewardShown = false;

  final AudioPlayer _player = AudioPlayer();
  late ConfettiController _confettiController; // 🎉 confetti lớn
  late ConfettiController _miniConfettiController; // 🎊 confetti nhỏ

  final List<IconData> rewardIcons = [
    Icons.star,
    Icons.emoji_events,
    Icons.card_giftcard,
    Icons.favorite,
  ];

  @override
  void initState() {
    super.initState();
    _loadNumbers();
    _loadProgress();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _miniConfettiController = ConfettiController(
      duration: const Duration(seconds: 1),
    );
  }

  Future<void> _loadNumbers() async {
    final String response = await rootBundle.loadString(
      'assets/configs/numbers.json',
    );
    final data = await json.decode(response);

    setState(() {
      numbers = data["numbers"];
    });
  }

  Future<void> _loadProgress() async {
    totalStars = await ProgressService.getStars(levelKey);
    learnedIndexes = await ProgressService.getLearnedIndexes(levelKey);

    // lấy flag final reward
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
    setState(() {
      isFinalRewardShown = true;
    });
  }

  // ✅ Reset flag để chơi lại
  Future<void> _resetFinalRewardFlag() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isFinalRewardShown_$levelKey", false);
    setState(() {
      isFinalRewardShown = false;
    });
  }

  void _markLearned(int index) async {
    if (!learnedIndexes.contains(index)) {
      setState(() {
        learnedIndexes.add(index);
        totalStars += 1;
      });
      await _saveProgress();

      // 🎊 bắn confetti nhỏ khi học xong 1 số
      if (mounted) {
        _miniConfettiController.play();
      }

      // 🎯 Khi học xong tất cả và chưa hiện popup trước đó
      if (totalStars == numbers.length && !isFinalRewardShown) {
        if (mounted) {
          _confettiController.play();
        }

        // 🔹 Mở khóa level tiếp theo TRƯỚC
        final levels = await ProgressService.loadLevels();
        final currentIdx = levels.indexWhere(
              (lv) => lv.levelKey == levelKey || lv.route == "/learn_numbers",
        );
        if (currentIdx != -1) {
          levels[currentIdx].state = LevelState.completed;
          if (currentIdx + 1 < levels.length &&
              levels[currentIdx + 1].state == LevelState.locked) {
            levels[currentIdx + 1].state = LevelState.playable;
          }
          await ProgressService.saveLevels(levels);
        }

        // 🔹 Cập nhật flag và show popup
        await _setFinalRewardShown();
        _showRewardPopup(isFinal: true);
      }
    }
  }

  void _next() {
    if (currentIndex < numbers.length - 1) {
      setState(() {
        currentIndex++;
      });
      _markLearned(currentIndex);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        WowCard.triggerAnimation(context);
      });
    }
  }

  void _prev() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
      });
      _markLearned(currentIndex);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        WowCard.triggerAnimation(context);
      });
    }
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
                    "🎉 Chúc mừng bé đã học xong!\n⭐ $totalStars / ${numbers.length} ⭐",
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
                  "Bé thật tuyệt vời! Hãy khoe ngay với bố mẹ nhé 👏👏",
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

      Future.delayed(const Duration(seconds: 4), () {
        if (mounted && Navigator.canPop(context)) Navigator.pop(context);
      });
      return;
    }

    // Popup thường
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
                    Shadow(
                      blurRadius: 10,
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
      title: "🌟 Số 0–10 🌟",
      child: Stack(
        children: [
          const AnimatedBackground(),
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(bottom: size.height * 0.25),
            child: Column(
              children: [
                // ⭐ progress bar
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
                            valueColor: const AlwaysStoppedAnimation(
                              Colors.amber,
                            ),
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

                // 📌 WowCard
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
                  label: Text(
                    "Nghe",
                    style: TextStyle(fontSize: size.width * 0.055),
                  ),
                  onPressed: () => _playAudio(item["audio"]),
                ),

                SizedBox(height: size.height * 0.04),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (currentIndex > 0)
                      _circleButton(
                        Icons.arrow_back,
                        _prev,
                        Colors.pinkAccent,
                        size,
                      ),
                    if (currentIndex < numbers.length - 1)
                      _circleButton(
                        Icons.arrow_forward,
                        _next,
                        Colors.lightBlue,
                        size,
                      ),
                  ],
                ),
              ],
            ),
          ),

          // 🎉 Confetti lớn khi hoàn thành
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Colors.red,
              Colors.blue,
              Colors.green,
              Colors.orange,
              Colors.purple,
            ],
            gravity: 0.3,
          ),

          // 🎊 Confetti nhỏ khi học từng số
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

  @override
  void dispose() {
    _confettiController.dispose();
    _miniConfettiController.dispose();
    super.dispose();
  }
}

//
// 🌥️ Animated Background
//
class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _cloudController;
  late AnimationController _balloonController;
  late AnimationController _starController;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _cloudController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
    _balloonController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
    _starController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _cloudController,
          builder: (_, __) {
            return Positioned(
              top: 80,
              left: MediaQuery.of(context).size.width *
                  (_cloudController.value * 2 - 1),
              child: Icon(
                Icons.cloud,
                size: 120,
                color: Colors.white.withOpacity(0.8),
              ),
            );
          },
        ),
        AnimatedBuilder(
          animation: _balloonController,
          builder: (_, __) {
            return Positioned(
              bottom: MediaQuery.of(context).size.height *
                  (1 - _balloonController.value),
              left: MediaQuery.of(context).size.width * 0.7,
              child: Icon(
                Icons.celebration,
                size: 60,
                color: Colors.pink.withOpacity(0.8),
              ),
            );
          },
        ),
        ...List.generate(6, (i) {
          final left =
              _random.nextDouble() * MediaQuery.of(context).size.width;
          final top =
              _random.nextDouble() * MediaQuery.of(context).size.height * 0.5;
          return AnimatedBuilder(
            animation: _starController,
            builder: (_, __) {
              return Positioned(
                left: left,
                top: top,
                child: Opacity(
                  opacity: _starController.value,
                  child: Icon(
                    Icons.star,
                    size: 18,
                    color: Colors.yellow.withOpacity(0.8),
                  ),
                ),
              );
            },
          );
        }),
      ],
    );
  }

  @override
  void dispose() {
    _cloudController.dispose();
    _balloonController.dispose();
    _starController.dispose();
    super.dispose();
  }
}
