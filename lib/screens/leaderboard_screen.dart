import 'dart:ui';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../themes/app_theme.dart';

/// 🏆 LeaderboardScreen v5.0 — Fintech Gradient + Glow + Confetti + Smooth Animation
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with TickerProviderStateMixin {
  int myStars = 0;
  late ConfettiController _confettiController;

  List<Map<String, dynamic>> players = [
    {"name": "Bunny 🐰", "stars": 250},
    {"name": "Kitty 🐱", "stars": 200},
    {"name": "Panda 🐼", "stars": 180},
    {"name": "Tiger 🐯", "stars": 150},
    {"name": "Fox 🦊", "stars": 140},
    {"name": "Bear 🧸", "stars": 120},
    {"name": "Penguin 🐧", "stars": 100},
    {"name": "Lion 🦁", "stars": 90},
    {"name": "Elephant 🐘", "stars": 80},
    {"name": "Duckie 🐥", "stars": 70},
  ];

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _loadMyData();
  }

  Future<void> _loadMyData() async {
    final prefs = await SharedPreferences.getInstance();
    myStars = prefs.getInt("totalStars") ?? 0;

    players.add({"name": "Bé của bạn 👩‍🎓", "stars": myStars, "isMe": true});
    players.sort((a, b) => b["stars"].compareTo(a["stars"]));
    setState(() {});

    if (players.isNotEmpty && players.first["isMe"] == true) {
      Future.delayed(const Duration(milliseconds: 600), () {
        _confettiController.play();
      });
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Color getRankColor(int index) {
    switch (index) {
      case 0:
        return Colors.amberAccent;
      case 1:
        return Colors.grey.shade300;
      case 2:
        return Colors.brown.shade300;
      default:
        return Colors.deepPurpleAccent.shade100;
    }
  }

  String getFeedback(int index, bool isMe) {
    if (isMe && index == 0) return "🏆 Bé là nhà vô địch của tuần này!";
    if (isMe && index < 5) return "🌟 Gần lên Top rồi đó!";
    if (isMe) return "💪 Cố gắng thêm chút nữa nhé!";
    switch (index) {
      case 0:
        return "🌟 Vô địch cực đỉnh!";
      case 1:
        return "🥈 Quá xuất sắc!";
      case 2:
        return "🥉 Rất chăm ngoan!";
      default:
        return "💖 Cố gắng hết mình nhé!";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: ShaderMask(
          shaderCallback: (rect) => const LinearGradient(
            colors: [Color(0xFF5E2CED), Color(0xFFFF8B00)],
          ).createShader(rect),
          child: const Text(
            "Bảng xếp hạng",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // 🌈 Gradient Fintech Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF5E2CED), Color(0xFFFF8B00)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // 💎 Glass blur overlay
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
            child: Container(color: Colors.white.withOpacity(0.05)),
          ),
          // 🎉 Confetti (top 1)
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              emissionFrequency: 0.05,
              numberOfParticles: 25,
              gravity: 0.3,
              colors: const [
                Color(0xFFFF8B00),
                Color(0xFF5E2CED),
                Colors.pinkAccent,
                Colors.cyanAccent,
              ],
            ),
          ),
          // 🧾 Danh sách bảng xếp hạng
          SafeArea(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: players.length,
              itemBuilder: (context, index) {
                final player = players[index];
                final isMe = player["isMe"] == true;
                final rankColor = getRankColor(index);

                return AnimatedSlide(
                  offset: Offset(0, 0.1 * (index / 5)),
                  duration: Duration(milliseconds: 500 + index * 100),
                  curve: Curves.easeOutBack,
                  child: AnimatedOpacity(
                    opacity: 1,
                    duration: Duration(milliseconds: 400 + index * 80),
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: isMe
                              ? [const Color(0xFF5E2CED), const Color(0xFFFF8B00)]
                              : [
                            rankColor.withOpacity(0.25),
                            Colors.white.withOpacity(0.2)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isMe
                                ? Colors.purpleAccent.withOpacity(0.4)
                                : rankColor.withOpacity(0.2),
                            blurRadius: 12,
                            spreadRadius: 1,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 26,
                          backgroundColor: rankColor,
                          child: Text(
                            "${index + 1}",
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                        ),
                        title: Text(
                          player["name"],
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isMe ? Colors.white : Colors.white70,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "⭐ ${player["stars"]}",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              getFeedback(index, isMe),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white60,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                        trailing: Icon(
                          isMe ? Icons.emoji_events_rounded : Icons.star_border,
                          color: isMe ? Colors.yellowAccent : Colors.white54,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
