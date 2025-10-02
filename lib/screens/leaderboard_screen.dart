import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'base_screen.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  int myStars = 0;
  int myDiamonds = 0;

  List<Map<String, dynamic>> players = [
    {"name": "Bunny 🐰", "stars": 8, "diamonds": 120},
    {"name": "Kitty 🐱", "stars": 6, "diamonds": 95},
    {"name": "Panda 🐼", "stars": 4, "diamonds": 60},
    {"name": "Tiger 🐯", "stars": 3, "diamonds": 40},
  ];

  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _loadMyData();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  Future<void> _loadMyData() async {
    final prefs = await SharedPreferences.getInstance();
    myStars = prefs.getInt("totalStars") ?? 0;
    myDiamonds = prefs.getInt("totalDiamonds") ?? 0;

    players.add({
      "name": "Bé của bạn 👩‍🎓",
      "stars": myStars,
      "diamonds": myDiamonds,
      "isMe": true,
    });

    players.sort((a, b) => b["stars"].compareTo(a["stars"]));
    setState(() {});
  }

  String getBadgeIcon(int stars) {
    if (stars >= 20) return "🏆";
    if (stars >= 10) return "🥇";
    if (stars >= 5) return "🥈";
    if (stars >= 1) return "🥉";
    return "🎯";
  }

  Color getRankColor(int index) {
    switch (index) {
      case 0:
        return Colors.amber; // 🥇
      case 1:
        return Colors.grey; // 🥈
      case 2:
        return Colors.brown; // 🥉
      default:
        return Colors.deepPurple;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: "🏆 Bảng xếp hạng",
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: players.length,
        itemBuilder: (context, index) {
          final player = players[index];
          final isMe = player["isMe"] == true;

          return ScaleTransition(
            scale: CurvedAnimation(
              parent: _animController,
              curve: Interval(
                (index / players.length),
                1.0,
                curve: Curves.elasticOut,
              ),
            ),
            child: Card(
              color: isMe ? Colors.green.shade100 : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: isMe ? 6 : 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: getRankColor(index),
                  child: Text(
                    "${index + 1}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                title: Text(
                  "${player["name"]} ${getBadgeIcon(player["stars"])}",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isMe ? Colors.green.shade900 : Colors.black,
                  ),
                ),
                subtitle: Text(
                  "⭐ ${player["stars"]} | 💎 ${player["diamonds"]}",
                  style: const TextStyle(fontSize: 16),
                ),
                trailing: isMe
                    ? const Icon(Icons.person, color: Colors.green)
                    : const Icon(Icons.child_care, color: Colors.purple),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }
}
