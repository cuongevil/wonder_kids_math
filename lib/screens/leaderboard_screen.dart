import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'base_screen.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with TickerProviderStateMixin {
  int myStars = 0;
  late ConfettiController _confettiController;

  // 🧸 Danh sách sinh động
  List<Map<String, dynamic>> players = [
    {"name": "Bunny 🐰", "stars": 250},
    {"name": "Kitty 🐱", "stars": 200},
    {"name": "Panda 🐼", "stars": 180},
    {"name": "Tiger 🐯", "stars": 150},
    {"name": "Fox 🦊", "stars": 140},
    {"name": "Bear 🧸", "stars": 120},
    {"name": "Penguin 🐧", "stars": 100},
    {"name": "Lion 🦁", "stars": 90},
    {"name": "Elephant 🐘", "stars": 8},
    {"name": "Duckie 🐥", "stars": 7},
  ];

  @override
  void initState() {
    super.initState();
    _loadMyData();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> _loadMyData() async {
    final prefs = await SharedPreferences.getInstance();
    myStars = prefs.getInt("totalStars") ?? 0;

    players.add({"name": "Bé của bạn 👩‍🎓", "stars": myStars, "isMe": true});

    players.sort((a, b) => b["stars"].compareTo(a["stars"]));
    setState(() {});

    // 🎉 Nếu bé top 1 => tung hoa
    if (players.isNotEmpty && players.first["isMe"] == true) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _confettiController.play();
      });
    }
  }

  Color getRankColor(int index) {
    switch (index) {
      case 0:
        return Colors.amber;
      case 1:
        return Colors.grey;
      case 2:
        return Colors.brown;
      default:
        return Colors.deepPurpleAccent;
    }
  }

  String getFeedback(int index, bool isMe) {
    if (isMe && index == 0) return "🏆 Bé là nhà vô địch của tuần này!";
    if (isMe && index > 0 && index < 5) return "🌟 Gần lên Top rồi đó!";
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
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: "🏆 Bảng xếp hạng",
      child: SizedBox.expand(
        // ✅ Fix lỗi RenderBox
        child: Stack(
          children: [
            // 🎊 Confetti (chỉ hiện khi top 1)
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                numberOfParticles: 25,
                gravity: 0.4,
                colors: const [
                  Colors.pinkAccent,
                  Colors.amber,
                  Colors.lightBlueAccent,
                  Colors.purpleAccent,
                ],
              ),
            ),

            // 📋 Danh sách bảng xếp hạng
            ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: players.length + 1,
              itemBuilder: (context, index) {
                if (index == players.length) {
                  return const Padding(
                    padding: EdgeInsets.all(12),
                    child: Center(
                      child: Text(
                        "🌈 Cố gắng học thêm để leo hạng nha bé!",
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    ),
                  );
                }

                final player = players[index];
                final isMe = player["isMe"] == true;
                final rankColor = getRankColor(index);

                final bgGradient = LinearGradient(
                  colors: isMe
                      ? [Colors.greenAccent.shade100, Colors.white]
                      : [rankColor.withOpacity(0.25), Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                );

                return AnimatedScale(
                  duration: Duration(milliseconds: 600 + index * 100),
                  scale: 1.0,
                  curve: Curves.elasticOut,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      gradient: bgGradient,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: rankColor.withOpacity(0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: rankColor,
                        radius: 22,
                        child: Text(
                          "${index + 1}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      title: Text(
                        "${player["name"]}",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isMe ? Colors.green.shade900 : Colors.black,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "⭐ ${player["stars"]}",
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            getFeedback(index, isMe),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                      trailing: Icon(
                        isMe ? Icons.emoji_events : Icons.child_care,
                        color: isMe ? Colors.green : Colors.purpleAccent,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
