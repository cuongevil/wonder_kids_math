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
    final badge = _getBadge(stars)["name"];
    final lastBadge = prefs.getString("lastBadge");

    setState(() {
      totalStars = stars;
      currentBadgeName = badge;
    });

    // 🎉 Nếu huy hiệu mới => confetti
    if (lastBadge != badge) {
      _confettiController.play();
      _showNewBadgePopup(badge);
      prefs.setString("lastBadge", badge);
    }
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

  /// 🌟 Cấp độ danh hiệu
  String _getLevel(int stars) {
    if (stars >= 50) return "🌟 Siêu thiên tài";
    if (stars >= 30) return "🚀 Học sinh xuất sắc";
    if (stars >= 15) return "🎯 Nhà vô địch nhỏ";
    if (stars >= 5) return "🎈 Bé chăm ngoan";
    return "🌱 Người mới bắt đầu";
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
    final level = _getLevel(totalStars);

    return BaseScreen(
      title: "👩‍🎓 Thành tích",
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 🌈 Nền gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // 👩‍🎓 Avatar động
                RotationTransition(
                  turns: Tween(
                    begin: -0.05,
                    end: 0.05,
                  ).animate(_animController),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white.withOpacity(0.8),
                    child: const Text("👩‍🎓", style: TextStyle(fontSize: 40)),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Bé học giỏi",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  level,
                  style: const TextStyle(fontSize: 18, color: Colors.white70),
                ),
                const SizedBox(height: 25),

                // ⭐ Tổng sao
                _buildStatCard("⭐ Tổng sao", totalStars, Colors.amber),
                const SizedBox(height: 25),

                // 🎯 Mục tiêu tuần
                Text(
                  "🎯 Mục tiêu tuần",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (totalStars % 10) / 10,
                  minHeight: 10,
                  backgroundColor: Colors.white30,
                  color: Colors.greenAccent,
                  borderRadius: BorderRadius.circular(10),
                ),
                const SizedBox(height: 30),

                // 🏅 Huy hiệu hiện tại
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

                // 🌟 Quote động
                Text(
                  "“Mỗi ngôi sao là một bước tiến đến giấc mơ của bé ✨”",
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // 🏅 Nút xem bộ sưu tập
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

                // ⬅️ Quay lại
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
