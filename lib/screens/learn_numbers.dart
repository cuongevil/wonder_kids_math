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
  int totalStars = 0; // ⭐ tổng tích lũy
  int totalDiamonds = 0; // 💎 tích lũy khi nghe đọc
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
      duration: const Duration(milliseconds: 500),
    );
    _buttonScale = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _buttonAnimController, curve: Curves.elasticOut),
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
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      totalStars = prefs.getInt("totalStars") ?? 0;
      totalDiamonds = prefs.getInt("totalDiamonds") ?? 0;
    });
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("totalStars", totalStars);
    await prefs.setInt("totalDiamonds", totalDiamonds);
  }

  void _next() {
    if (currentIndex < numbers.length - 1) {
      setState(() => currentIndex++);
    }
  }

  void _prev() {
    if (currentIndex > 0) {
      setState(() => currentIndex--);
    }
  }

  Future<void> _playAudio(String path) async {
    await _player.stop();
    await _player.play(AssetSource(path.replaceFirst('assets/', '')));
    setState(() {
      totalDiamonds += 1;
    });
    _saveProgress();
  }

  void _showRewardPopup() {
    final random = Random();
    final icon = rewardIcons[random.nextInt(rewardIcons.length)];

    setState(() {
      totalStars += 1;
    });
    _saveProgress();

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
              ScaleTransition(
                scale: CurvedAnimation(
                  parent: _buttonAnimController,
                  curve: Curves.elasticOut,
                ),
                child: Column(
                  children: [
                    Icon(icon, size: 100, color: Colors.yellow),
                    const SizedBox(height: 16),
                    Text(
                      "Tuyệt vời! Bạn được +1 ⭐\nTổng: ⭐ $totalStars | 💎 $totalDiamonds",
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

    final item = numbers[currentIndex];

    return BaseScreen(
      title: "🌟 Số 0–10 🌟",
      child: Stack(
        alignment: Alignment.center,
        children: [
          const AnimatedBackground(),

          /// 👉 Nội dung chính có scroll
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 📖 Flashcard
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (child, anim) => SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1, 0),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                  child: Container(
                    key: ValueKey(currentIndex),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item["value"].toString(),
                          style: TextStyle(
                            fontSize: 100,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                            shadows: [
                              Shadow(
                                blurRadius: 20,
                                color: Colors.deepPurpleAccent.withOpacity(0.6),
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ScaleTransition(
                          scale: _mascotScale,
                          child: Image.asset(
                            item["image"],
                            width: 160,
                            height: 160,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          item["text"],
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // 🔊 Nghe đọc
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 14,
                    ),
                  ),
                  icon: const Icon(Icons.volume_up, size: 28),
                  label: const Text("Nghe đọc", style: TextStyle(fontSize: 22)),
                  onPressed: () => _playAudio(item["audio"]),
                ),

                const SizedBox(height: 30),

                // ⬅️➡️ Điều hướng
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _circleButton(Icons.arrow_back, _prev, Colors.pinkAccent),
                    _circleButton(Icons.arrow_forward, _next, Colors.lightBlue),
                  ],
                ),

                const SizedBox(height: 30),

                // 🎉 Hoàn thành
                ScaleTransition(
                  scale: _buttonScale,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: currentIndex == numbers.length - 1
                          ? Colors.green
                          : Colors.grey,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 18,
                      ),
                    ),
                    icon: const Icon(Icons.check_circle, size: 28),
                    label: const Text(
                      "Hoàn thành",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: currentIndex == numbers.length - 1
                        ? () {
                            _buttonAnimController.forward(from: 0);
                            _confettiController.play();
                            _showRewardPopup();
                          }
                        : null,
                  ),
                ),
              ],
            ),
          ),

          // 🎊 Confetti
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

  Widget _circleButton(IconData icon, VoidCallback onTap, Color color) {
    return Ink(
      decoration: ShapeDecoration(shape: const CircleBorder(), color: color),
      child: IconButton(
        icon: Icon(icon, size: 36, color: Colors.white),
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
              left:
                  MediaQuery.of(context).size.width *
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
              bottom:
                  MediaQuery.of(context).size.height *
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
          final left = _random.nextDouble() * MediaQuery.of(context).size.width;
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
