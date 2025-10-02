import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'base_screen.dart'; // ✅ dùng BaseScreen

class BadgeCollectionScreen extends StatefulWidget {
  const BadgeCollectionScreen({super.key});

  @override
  State<BadgeCollectionScreen> createState() => _BadgeCollectionScreenState();
}

class _BadgeCollectionScreenState extends State<BadgeCollectionScreen>
    with SingleTickerProviderStateMixin {
  int totalStars = 0;

  final List<Map<String, dynamic>> badges = [
    {"icon": "🥉", "name": "Người khởi đầu", "requireStars": 1},
    {"icon": "🥈", "name": "Ngôi sao bạc", "requireStars": 5},
    {"icon": "🥇", "name": "Ngôi sao vàng", "requireStars": 10},
    {"icon": "🏆", "name": "Siêu sao học tập", "requireStars": 20},
  ];

  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _loadStars();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  Future<void> _loadStars() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      totalStars = prefs.getInt("totalStars") ?? 0;
    });
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: "🎖️ Bộ sưu tập huy hiệu",
      child: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: badges.length,
        itemBuilder: (context, index) {
          final badge = badges[index];
          final unlocked = totalStars >= badge["requireStars"];

          return AnimatedBuilder(
            animation: _glowController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: unlocked
                      ? [
                          BoxShadow(
                            color: Colors.yellow.withOpacity(
                              0.3 + 0.3 * _glowController.value,
                            ),
                            blurRadius: 20,
                            spreadRadius: 3,
                          ),
                        ]
                      : [],
                ),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: unlocked ? Colors.white : Colors.grey.shade300,
                  elevation: unlocked ? 6 : 1,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            badge["icon"],
                            style: TextStyle(
                              fontSize: 50,
                              color: unlocked ? Colors.black : Colors.black26,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            badge["name"],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: unlocked
                                  ? Colors.deepPurple
                                  : Colors.black38,
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

                      // 🔒 Overlay khóa
                      if (!unlocked)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.lock,
                            size: 40,
                            color: Colors.black45,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
