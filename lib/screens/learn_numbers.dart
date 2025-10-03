import 'dart:convert';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'base_screen.dart';

class LearnNumbersScreen extends StatefulWidget {
  const LearnNumbersScreen({super.key});

  @override
  State<LearnNumbersScreen> createState() => _LearnNumbersScreenState();
}

class _LearnNumbersScreenState extends State<LearnNumbersScreen>
    with TickerProviderStateMixin {
  List<dynamic> numbers = [];
  int currentIndex = 0;
  int totalStars = 0;

  /// lưu index các số đã học để tránh cộng sao 2 lần
  Set<int> learnedIndexes = {};

  final AudioPlayer _player = AudioPlayer();

  late AnimationController _mascotController;
  late Animation<double> _mascotScale;
  late ConfettiController _confettiController;
  late AnimationController _buttonAnimController;
  late Animation<double> _buttonScale;

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

    _mascotController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _mascotScale = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _mascotController, curve: Curves.easeInOut),
    );

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    _buttonAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _buttonScale = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _buttonAnimController, curve: Curves.easeInOut),
    );

    _buttonAnimController.repeat(reverse: true);
  }

  Future<void> _loadNumbers() async {
    final String response =
    await rootBundle.loadString('assets/configs/numbers.json');
    final data = await json.decode(response);

    setState(() {
      numbers = data["numbers"];
    });
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      totalStars = prefs.getInt("totalStars") ?? 0;
      if (prefs.containsKey("learnedIndexes")) {
        learnedIndexes =
        Set<int>.from(jsonDecode(prefs.getString("learnedIndexes")!));
      }
    });
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("totalStars", totalStars);
    await prefs.setString(
        "learnedIndexes", jsonEncode(learnedIndexes.toList()));
  }

  /// đánh dấu 1 số là đã học
  void _markLearned(int index) {
    if (!learnedIndexes.contains(index)) {
      setState(() {
        learnedIndexes.add(index);
        totalStars += 1;
      });
      _saveProgress();
    }
  }

  void _next() {
    if (currentIndex < numbers.length - 1) {
      setState(() {
        currentIndex++;
      });
      _markLearned(currentIndex);
    }
  }

  void _prev() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
      });
      _markLearned(currentIndex);
    }
  }

  Future<void> _playAudio(String path) async {
    await _player.stop();
    await _player.play(AssetSource(path.replaceFirst('assets/', '')));
  }

  void _showRewardPopup() {
    final random = Random();
    final icon = rewardIcons[random.nextInt(rewardIcons.length)];

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
                "Tuyệt vời! Bạn đã học xong\n⭐ $totalStars / ${numbers.length}",
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

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pop(context);
      Navigator.pop(context, true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (numbers.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // đánh dấu số hiện tại là đã học
    _markLearned(currentIndex);

    final item = numbers[currentIndex];
    final size = MediaQuery.of(context).size;
    final cardWidth = size.width * 0.85;
    final cardPadding = size.width * 0.06;
    final imageSize = size.width * 0.45;
    final numberFont = size.width * 0.16;
    final textFont = size.width * 0.075;

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
                            value: numbers.isEmpty
                                ? 0
                                : (totalStars / numbers.length).clamp(0, 1),
                            minHeight: size.height * 0.04,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation(
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

                // Flashcard
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.2),
                        end: Offset.zero,
                      ).animate(anim),
                      child: child,
                    ),
                  ),
                  child: SizedBox(
                    key: ValueKey(currentIndex),
                    width: cardWidth,
                    height: size.height * 0.55,
                    child: Container(
                      padding: EdgeInsets.all(cardPadding),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            item["value"].toString(),
                            style: TextStyle(
                              fontSize: numberFont,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                          SizedBox(height: size.height * 0.015),
                          ScaleTransition(
                            scale: _mascotScale,
                            child: Image.asset(
                              item["image"],
                              width: imageSize,
                              height: imageSize,
                            ),
                          ),
                          SizedBox(height: size.height * 0.015),
                          Text(
                            item["text"],
                            style: TextStyle(
                              fontSize: textFont,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: size.height * 0.04),

                // Nghe đọc
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
                  label: Text("Nghe đọc",
                      style: TextStyle(fontSize: size.width * 0.055)),
                  onPressed: () => _playAudio(item["audio"]),
                ),

                SizedBox(height: size.height * 0.04),

                // Điều hướng
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (currentIndex > 0)
                      _circleButton(
                          Icons.arrow_back, _prev, Colors.pinkAccent, size),
                    if (currentIndex < numbers.length - 1)
                      _circleButton(
                          Icons.arrow_forward, _next, Colors.lightBlue, size),
                  ],
                ),
              ],
            ),
          ),

          // Nút Hoàn thành fixed
          if (currentIndex == numbers.length - 1)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: size.height * 0.03),
                child: ScaleTransition(
                  scale: _buttonScale,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: const StadiumBorder(),
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.1,
                        vertical: size.height * 0.02,
                      ),
                    ),
                    icon: Icon(Icons.check_circle, size: size.width * 0.07),
                    label: Text(
                      "Hoàn thành",
                      style: TextStyle(
                        fontSize: size.width * 0.06,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      _confettiController.play();
                      _showRewardPopup();
                    },
                  ),
                ),
              ),
            ),

          // Confetti
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
        ],
      ),
    );
  }

  Widget _circleButton(
      IconData icon, VoidCallback onTap, Color color, Size size) {
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
    _mascotController.dispose();
    _confettiController.dispose();
    _buttonAnimController.dispose();
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
              child: Icon(Icons.cloud,
                  size: 120, color: Colors.white.withOpacity(0.8)),
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
              child: Icon(Icons.celebration,
                  size: 60, color: Colors.pink.withOpacity(0.8)),
            );
          },
        ),
        ...List.generate(6, (i) {
          final left = _random.nextDouble() *
              MediaQuery.of(context).size.width;
          final top = _random.nextDouble() *
              MediaQuery.of(context).size.height *
              0.5;
          return AnimatedBuilder(
            animation: _starController,
            builder: (_, __) {
              return Positioned(
                left: left,
                top: top,
                child: Opacity(
                  opacity: _starController.value,
                  child: Icon(Icons.star,
                      size: 18, color: Colors.yellow.withOpacity(0.8)),
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
