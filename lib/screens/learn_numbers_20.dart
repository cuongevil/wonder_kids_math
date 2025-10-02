import 'dart:convert';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'base_screen.dart';

class LearnNumbers20Screen extends StatefulWidget {
  const LearnNumbers20Screen({super.key});

  @override
  State<LearnNumbers20Screen> createState() => _LearnNumbers20ScreenState();
}

class _LearnNumbers20ScreenState extends State<LearnNumbers20Screen>
    with TickerProviderStateMixin {
  List<dynamic> numbers = [];
  int currentIndex = 0;
  int totalStars = 0;
  int totalDiamonds = 0;
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
      'assets/configs/numbers_20.json',
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
      title: "🌟 Số 11–20 🌟",
      child: Stack(
        alignment: Alignment.center,
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _circleButton(Icons.arrow_back, _prev, Colors.pinkAccent),
                    _circleButton(Icons.arrow_forward, _next, Colors.lightBlue),
                  ],
                ),
                const SizedBox(height: 30),

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
