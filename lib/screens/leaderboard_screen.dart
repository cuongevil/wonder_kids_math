import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  int myStars = 0;
  int myDiamonds = 0;

  List<Map<String, dynamic>> players = [
    {"name": "Bunny 🐰", "stars": 8, "diamonds": 120},
    {"name": "Kitty 🐱", "stars": 6, "diamonds": 95},
    {"name": "Panda 🐼", "stars": 4, "diamonds": 60},
    {"name": "Tiger 🐯", "stars": 3, "diamonds": 40},
  ];

  @override
  void initState() {
    super.initState();
    _loadMyData();
  }

  Future<void> _loadMyData() async {
    final prefs = await SharedPreferences.getInstance();
    myStars = prefs.getInt("totalStars") ?? 0;
    myDiamonds = prefs.getInt("totalDiamonds") ?? 0;

    players.add({
      "name": "Bé của bạn 👩‍🎓",
      "stars": myStars,
      "diamonds": myDiamonds,
      "isMe": true
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      appBar: AppBar(
        title: const Text("🏆 Bảng xếp hạng"),
        centerTitle: true,
        backgroundColor: Colors.purple.shade200,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: players.length,
        itemBuilder: (context, index) {
          final player = players[index];
          final isMe = player["isMe"] == true;

          return Card(
            color: isMe ? Colors.green.shade100 : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isMe ? Colors.green : Colors.deepPurple,
                child: Text("${index + 1}",
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
          );
        },
      ),
    );
  }
}
