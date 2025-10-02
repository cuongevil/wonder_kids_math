import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'badge_collection_screen.dart';
import 'base_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  int totalStars = 0;
  int totalDiamonds = 0;

  late AnimationController _animController;
  late ConfettiController _confettiController;

  String? currentBadgeName;

  @override
  void initState() {
    super.initState();
    _loadProgress();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final stars = prefs.getInt("totalStars") ?? 0;
    final diamonds = prefs.getInt("totalDiamonds") ?? 0;

    final badge = _getBadge(stars)["name"];

    setState(() {
      totalStars = stars;
      totalDiamonds = diamonds;
    });

    // 🔥 Nếu huy hiệu mới (khác với lần trước) thì bật confetti
    if (currentBadgeName != null && currentBadgeName != badge) {
      _confettiController.play();
      _showNewBadgePopup(badge);
    }

    currentBadgeName = badge;
  }

  Map<String, dynamic> _getBadge(int stars) {
    if (stars >= 20) {
      return {"name": "🏆 Siêu sao học tập", "color": Colors.orange};
    }
    if (stars >= 10) {
      return {"name": "🥇 Ngôi sao vàng", "color": Colors.yellow.shade700};
    }
    if (stars >= 5) {
      return {"name": "🥈 Ngôi sao bạc", "color": Colors.grey};
    }
    if (stars >= 1) {
      return {"name": "🥉 Người khởi đầu", "color": Colors.brown};
    }
    return {"name": "🎯 Chưa có huy hiệu", "color": Colors.black45};
  }

  void _showNewBadgePopup(String badgeName) {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(40),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 12,
                  offset: const Offset(2, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "🎉 Chúc mừng!",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Bé vừa đạt được huy hiệu mới:",
                  style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 12),
                Text(
                  badgeName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );

    // Auto đóng sau 3s
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final badge = _getBadge(totalStars);

    return BaseScreen(
      title: "👩‍🎓 Thành tích của bé",
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // 👩‍🎓 Avatar
                ScaleTransition(
                  scale: Tween<double>(begin: 0.95, end: 1.05).animate(
                    CurvedAnimation(
                      parent: _animController,
                      curve: Curves.easeInOut,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.deepPurple.shade200,
                    child: const Text("👩‍🎓", style: TextStyle(fontSize: 40)),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Bé học giỏi",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple.shade700,
                  ),
                ),
                const SizedBox(height: 30),

                // ⭐ Sao + 💎 Kim cương
                _buildStatCard("⭐ Tổng sao", totalStars, Colors.amber),
                const SizedBox(height: 20),
                _buildStatCard(
                  "💎 Tổng kim cương",
                  totalDiamonds,
                  Colors.lightBlue,
                ),
                const SizedBox(height: 20),

                // 🎖️ Huy hiệu hiện tại
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [badge["color"].withOpacity(0.7), Colors.white],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: badge["color"].withOpacity(0.5),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
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

                const Spacer(),

                ElevatedButton.icon(
                  icon: const Icon(Icons.collections),
                  label: const Text("Xem bộ sưu tập huy hiệu"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BadgeCollectionScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_back),
                  label: const Text("Quay lại"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 16,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // 🎊 Confetti
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            gravity: 0.3,
            colors: const [
              Colors.red,
              Colors.blue,
              Colors.green,
              Colors.orange,
              Colors.purple,
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, int value, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(Icons.star, size: 50, color: color),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                "$title\n$value",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
