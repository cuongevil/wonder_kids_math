import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/wow_mascot.dart';
import 'base_screen.dart';

class BadgeCollectionScreen extends StatefulWidget {
  const BadgeCollectionScreen({super.key});

  @override
  State<BadgeCollectionScreen> createState() => _BadgeCollectionScreenState();
}

class _BadgeCollectionScreenState extends State<BadgeCollectionScreen>
    with TickerProviderStateMixin {
  int totalStars = 0;
  final List<Map<String, dynamic>> badges = [
    {"icon": "🥉", "name": "Bé chăm chỉ", "requireStars": 20},
    {"icon": "🥈", "name": "Bé tiến bộ", "requireStars": 50},
    {"icon": "🥇", "name": "Siêu học sinh", "requireStars": 100},
    {"icon": "🏆", "name": "Ngôi sao tỏa sáng", "requireStars": 200},
  ];

  late AnimationController _glowController;
  late AnimationController _popupAnimController;
  late ConfettiController _confettiController;
  Set<String> _unlockedBadges = {};

  @override
  void initState() {
    super.initState();
    _loadStars();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _popupAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
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
    _popupAnimController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _showUnlockedPopup(String badgeName) async {
    _popupAnimController.forward(from: 0);
    _confettiController.play();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Stack(
        alignment: Alignment.center,
        children: [
          // 🎊 Confetti bay
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            emissionFrequency: 0.04,
            numberOfParticles: 25,
            gravity: 0.4,
            colors: const [
              Colors.pinkAccent,
              Colors.amber,
              Colors.lightBlueAccent,
              Colors.purpleAccent,
            ],
          ),

          // 🎁 Popup chúc mừng
          ScaleTransition(
            scale: CurvedAnimation(
              parent: _popupAnimController,
              curve: Curves.elasticOut,
            ),
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD1DC), Color(0xFFAED9FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pink.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "🎉 Chúc mừng bé!",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                        shadows: [
                          Shadow(
                            color: Colors.white,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Bé đã mở khóa huy hiệu\n⭐ $badgeName ⭐",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    WowMascot(
                      isHappy: true,
                      message: "Tuyệt vời quá! Bé giỏi lắm 💕",
                      scale: 0.8,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Tiếp tục hành trình 🌈",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onBadgeTap(Map<String, dynamic> badge, bool unlocked) {
    if (unlocked) return;
    final starsNeeded = badge["requireStars"] - totalStars;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("🔒 Chưa mở khóa"),
        content: Text(
          "Cố lên nhé! Bé cần thêm $starsNeeded ⭐ nữa để đạt huy hiệu \"${badge["name"]}\"!",
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tiếp tục học 💪"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nextBadge = badges.firstWhere(
      (b) => totalStars < b["requireStars"],
      orElse: () => badges.last,
    );

    // 🔍 Kiểm tra huy hiệu mới
    for (var badge in badges) {
      final unlocked = totalStars >= badge["requireStars"];
      if (unlocked && !_unlockedBadges.contains(badge["name"])) {
        _unlockedBadges.add(badge["name"]);
        Future.delayed(const Duration(milliseconds: 400), () {
          _showUnlockedPopup(badge["name"]);
        });
      }
    }

    return BaseScreen(
      title: "🎖️ Bộ sưu tập huy hiệu",
      child: Column(
        children: [
          // ⭐ Tổng số sao
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              children: [
                Text(
                  "⭐ Tổng số sao: $totalStars / ${badges.last["requireStars"]}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (totalStars / badges.last["requireStars"]).clamp(
                      0,
                      1,
                    ),
                    minHeight: 10,
                    backgroundColor: Colors.grey.shade300,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  totalStars < nextBadge["requireStars"]
                      ? "🎯 Còn ${nextBadge["requireStars"] - totalStars} sao để đạt \"${nextBadge["name"]}\"!"
                      : "🌟 Bé đã có tất cả huy hiệu rồi!",
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),
          ),

          // 🏅 Grid huy hiệu
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1,
              ),
              itemCount: badges.length,
              itemBuilder: (context, index) {
                final badge = badges[index];
                final unlocked = totalStars >= badge["requireStars"];

                return GestureDetector(
                  onTap: () => _onBadgeTap(badge, unlocked),
                  child: AnimatedBuilder(
                    animation: _glowController,
                    builder: (context, child) {
                      final glow = unlocked
                          ? 0.4 + 0.3 * _glowController.value
                          : 0.0;

                      return AnimatedScale(
                        scale: unlocked
                            ? (1.0 + 0.03 * _glowController.value)
                            : 1.0,
                        duration: const Duration(milliseconds: 600),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: unlocked
                                ? [
                                    BoxShadow(
                                      color: Colors.yellow.withOpacity(glow),
                                      blurRadius: 30,
                                      spreadRadius: 8,
                                    ),
                                  ]
                                : [],
                          ),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            color: unlocked
                                ? Colors.white
                                : Colors.grey.shade300,
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
                                        fontSize: 44,
                                        color: unlocked
                                            ? Colors.black
                                            : Colors.black26,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      badge["name"],
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: unlocked
                                            ? Colors.deepPurple
                                            : Colors.black38,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      "Cần ${badge["requireStars"]} ⭐",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: unlocked
                                            ? Colors.black54
                                            : Colors.black26,
                                      ),
                                    ),
                                  ],
                                ),
                                if (!unlocked)
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Icon(
                                      Icons.lock_rounded,
                                      size: 40,
                                      color: Colors.black45,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
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
