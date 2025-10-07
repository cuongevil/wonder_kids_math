import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'base_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  int totalStars = 0;
  late AnimationController _avatarAnim;
  late AnimationController _sparkleAnim;
  late ConfettiController _confettiController;
  final Random _rand = Random();

  @override
  void initState() {
    super.initState();
    _loadProgress();

    _avatarAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _sparkleAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final oldStars = totalStars;
    final stars = prefs.getInt("totalStars") ?? 0;
    setState(() => totalStars = stars);

    // 🎉 Nếu bé vừa qua mốc huy hiệu => tung hoa + popup
    if ((oldStars < 20 && stars >= 20) ||
        (oldStars < 50 && stars >= 50) ||
        (oldStars < 100 && stars >= 100) ||
        (oldStars < 200 && stars >= 200)) {
      _confettiController.play();
    }
  }

  Map<String, dynamic> _getBadge(int stars) {
    if (stars >= 200) {
      return {"name": "🏆 Ngôi sao tỏa sáng", "color": Colors.orange};
    } else if (stars >= 100) {
      return {"name": "🥇 Siêu học sinh", "color": Colors.yellow.shade700};
    } else if (stars >= 50) {
      return {"name": "🥈 Bé tiến bộ", "color": Colors.grey};
    } else if (stars >= 20) {
      return {"name": "🥉 Bé chăm chỉ", "color": Colors.brown};
    } else {
      return {"name": "🎯 Chưa có huy hiệu", "color": Colors.black45};
    }
  }

  @override
  void dispose() {
    _avatarAnim.dispose();
    _sparkleAnim.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final badge = _getBadge(totalStars);

    // 🩷 Lời khen tự động
    String praise;
    if (totalStars >= 200) {
      praise = "🌟 Bé thật xuất sắc, một ngôi sao tỏa sáng!";
    } else if (totalStars >= 100) {
      praise = "💫 Bé đang ở đỉnh cao phong độ!";
    } else if (totalStars >= 50) {
      praise = "✨ Bé tiến bộ rõ rệt mỗi ngày!";
    } else if (totalStars >= 20) {
      praise = "🌱 Bé chăm chỉ thật đáng khen!";
    } else {
      praise = "🌼 Cùng bắt đầu hành trình học tập nhé! 🎈";
    }

    return BaseScreen(
      title: "🌟 Thành tích của bé",
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            height: constraints.maxHeight,
            width: constraints.maxWidth,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 🌈 Nền pastel
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFFDEE9), Color(0xFFB5FFFC)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),

                // 📜 Nội dung
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildAnimatedAvatar(),
                        const SizedBox(height: 16),
                        Text(
                          praise,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 25),
                        _buildStarCard(),
                        const SizedBox(height: 25),
                        _buildWeeklyGoal(),
                        const SizedBox(height: 30),
                        _buildBadgeWithSparkle(badge),
                        const SizedBox(height: 40),
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Colors.pinkAccent, Colors.orangeAccent],
                          ).createShader(bounds),
                          child: const Text(
                            "“Mỗi ngôi sao là một giấc mơ của bé ✨”",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),

                // 🎊 Confetti overlay
                Positioned.fill(
                  child: ConfettiWidget(
                    confettiController: _confettiController,
                    blastDirectionality: BlastDirectionality.explosive,
                    gravity: 0.3,
                    colors: const [
                      Colors.pinkAccent,
                      Colors.blueAccent,
                      Colors.amber,
                      Colors.greenAccent,
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedAvatar() {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedContainer(
          duration: const Duration(seconds: 2),
          width: 130,
          height: 130,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.pinkAccent.withOpacity(
                  0.4 + 0.2 * _avatarAnim.value,
                ),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
        ),
        ScaleTransition(
          scale: Tween(
            begin: 1.0,
            end: 1.1,
          ).chain(CurveTween(curve: Curves.elasticOut)).animate(_avatarAnim),
          child: Container(
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: const CircleAvatar(
              radius: 55,
              backgroundColor: Colors.white,
              child: Image(
                image: AssetImage('assets/images/mascot/mascot.png'),
                width: 80,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStarCard() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: totalStars.toDouble()),
      duration: const Duration(seconds: 1),
      builder: (context, value, _) {
        return Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          color: Colors.yellow[100],
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, size: 50, color: Colors.amber),
                const SizedBox(width: 15),
                Text(
                  "Tổng sao\n${value.toInt()}",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeeklyGoal() {
    int filled = totalStars % 10;
    return Column(
      children: [
        const Text(
          "🎯 Mục tiêu tuần",
          style: TextStyle(fontSize: 18, color: Colors.black87),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            10,
            (i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Transform.scale(
                scale: 1 + 0.1 * sin(_sparkleAnim.value * pi * 2 + i),
                child: Icon(
                  Icons.star_rounded,
                  color: i < filled ? Colors.amber : Colors.grey[300],
                  size: 24,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeWithSparkle(Map<String, dynamic> badge) {
    return Stack(
      alignment: Alignment.center,
      children: [
        _buildBadgeCard(badge),
        // ✅ FIX: Bọc lớp hiệu ứng bằng Positioned.fill để Stack con có constraints
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _sparkleAnim,
            builder: (context, _) {
              return Stack(
                children: List.generate(8, (i) {
                  final double top = _rand.nextDouble() * 100;
                  final double left = _rand.nextDouble() * 250;
                  final double size = _rand.nextDouble() * 8 + 4;
                  final double opacity = 0.5 + _rand.nextDouble() * 0.5;
                  return Positioned(
                    top: top,
                    left: left,
                    child: Opacity(
                      opacity: (_sparkleAnim.value * opacity),
                      child: Icon(
                        Icons.star_rounded,
                        color: Colors.white.withOpacity(opacity),
                        size: size,
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeCard(Map<String, dynamic> badge) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [badge["color"], Colors.white],
          center: Alignment.topLeft,
          radius: 1.5,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: badge["color"].withOpacity(0.6),
            blurRadius: 20,
            spreadRadius: 4,
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emoji_events, size: 70, color: badge["color"]),
          const SizedBox(width: 16),
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
    );
  }

  Widget _buildGradientButton({
    required String label,
    required IconData icon,
    required List<Color> colors,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: colors.last.withOpacity(0.4),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ElevatedButton.icon(
        icon: Icon(icon, color: Colors.white),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 14),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
