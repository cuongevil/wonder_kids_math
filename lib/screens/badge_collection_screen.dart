import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BadgeCollectionScreen extends StatefulWidget {
  const BadgeCollectionScreen({super.key});

  @override
  State<BadgeCollectionScreen> createState() => _BadgeCollectionScreenState();
}

class _BadgeCollectionScreenState extends State<BadgeCollectionScreen> {
  int totalStars = 0;

  final List<Map<String, dynamic>> badges = [
    {"icon": "🥉", "name": "Người khởi đầu", "requireStars": 1},
    {"icon": "🥈", "name": "Ngôi sao bạc", "requireStars": 5},
    {"icon": "🥇", "name": "Ngôi sao vàng", "requireStars": 10},
    {"icon": "🏆", "name": "Siêu sao học tập", "requireStars": 20},
  ];

  @override
  void initState() {
    super.initState();
    _loadStars();
  }

  Future<void> _loadStars() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      totalStars = prefs.getInt("totalStars") ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      appBar: AppBar(
        title: const Text("🎖️ Bộ sưu tập huy hiệu"),
        centerTitle: true,
        backgroundColor: Colors.purple.shade200,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: badges.length,
        itemBuilder: (context, index) {
          final badge = badges[index];
          final unlocked = totalStars >= badge["requireStars"];

          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            color: unlocked ? Colors.white : Colors.grey.shade300,
            elevation: unlocked ? 5 : 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(badge["icon"],
                    style: TextStyle(fontSize: 50, color: unlocked ? Colors.black : Colors.black26)),
                const SizedBox(height: 10),
                Text(
                  badge["name"],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: unlocked ? Colors.deepPurple : Colors.black38,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  "Cần ${badge["requireStars"]} ⭐",
                  style: TextStyle(
                    fontSize: 14,
                    color: unlocked ? Colors.black54 : Colors.black26,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
