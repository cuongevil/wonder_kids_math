import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'badge_collection_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int totalStars = 0;
  int totalDiamonds = 0;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      totalStars = prefs.getInt("totalStars") ?? 0;
      totalDiamonds = prefs.getInt("totalDiamonds") ?? 0;
    });
  }

  Map<String, dynamic> _getBadge() {
    if (totalStars >= 20) return {"name": "🏆 Siêu sao học tập", "color": Colors.orange};
    if (totalStars >= 10) return {"name": "🥇 Ngôi sao vàng", "color": Colors.yellow.shade700};
    if (totalStars >= 5) return {"name": "🥈 Ngôi sao bạc", "color": Colors.grey};
    if (totalStars >= 1) return {"name": "🥉 Người khởi đầu", "color": Colors.brown};
    return {"name": "🎯 Chưa có huy hiệu", "color": Colors.black45};
  }

  @override
  Widget build(BuildContext context) {
    final badge = _getBadge();

    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      appBar: AppBar(
        title: const Text("👩‍🎓 Thành tích của bé"),
        centerTitle: true,
        backgroundColor: Colors.purple.shade200,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildStatCard("⭐ Tổng sao", totalStars, Colors.amber),
            const SizedBox(height: 20),
            _buildStatCard("💎 Tổng kim cương", totalDiamonds, Colors.lightBlue),
            const SizedBox(height: 20),

            // 🎖️ Huy hiệu hiện tại
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(Icons.emoji_events, size: 60, color: badge["color"]),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Text(
                        badge["name"],
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: badge["color"],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            ElevatedButton.icon(
              icon: const Icon(Icons.collections),
              label: const Text("Xem bộ sưu tập huy hiệu"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BadgeCollectionScreen()),
                );
              },
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              icon: const Icon(Icons.arrow_back),
              label: const Text("Quay lại"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, int value, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(Icons.star, size: 50, color: color),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                "$title\n$value",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
