import 'dart:math';
import 'dart:ui';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 💜 ProfileScreen v6.0 — Fintech Gradient Glow + Glass AppBar + Animated Badge
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

    _avatarAnim =
    AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _sparkleAnim =
    AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final oldStars = totalStars;
    final stars = prefs.getInt("totalStars") ?? 0;
    setState(() => totalStars = stars);

    if ((oldStars < 20 && stars >= 20) ||
        (oldStars < 50 && stars >= 50) ||
        (oldStars < 100 && stars >= 100) ||
        (oldStars < 200 && stars >= 200)) {
      _confettiController.play();
    }
  }

  Map<String, dynamic> _getBadge(int stars) {
    if (stars >= 200) {
      return {"name": "🏆 Ngôi sao tỏa sáng", "color": const Color(0xFFFF8B00)};
    } else if (stars >= 100) {
      return {"name": "🥇 Siêu học sinh", "color": const Color(0xFFFFD700)};
    } else if (stars >= 50) {
      return {"name": "🥈 Bé tiến bộ", "color": Colors.grey.shade400};
    } else if (stars >= 20) {
      return {"name": "🥉 Bé chăm chỉ", "color": Colors.brown.shade400};
    } else {
      return {"name": "🎯 Chưa có huy hiệu", "color": Colors.white30};
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

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: ShaderMask(
          shaderCallback: (rect) => const LinearGradient(
            colors: [Color(0xFF5E2CED), Color(0xFFFF8B00)],
          ).createShader(rect),
          child: const Text(
            "Hồ sơ của bé",
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // 🌈 Fintech Gradient background
          AnimatedContainer(
            duration: const Duration(seconds: 3),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF5E2CED), Color(0xFFFF8B00)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // 💎 Glass blur overlay
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
            child: Container(color: Colors.white.withOpacity(0.05)),
          ),

          // 🎊 Confetti FX
          Positioned.fill(
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 20,
              gravity: 0.3,
              colors: const [
                Color(0xFFFF8B00),
                Color(0xFF5E2CED),
                Colors.pinkAccent,
                Colors.cyanAccent,
              ],
            ),
          ),

          // 📜 Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              physics: const BouncingScrollPhysics(),
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
                        color: Colors.white70,
                        fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 25),
                  _buildStarCard(),
                  const SizedBox(height: 25),
                  _buildWeeklyGoal(),
                  const SizedBox(height: 25),
                  _buildBadgeWithSparkle(badge),
                  const SizedBox(height: 40),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFFFF8B00), Color(0xFF5E2CED)],
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🪄 Avatar with glow + bounce
  Widget _buildAnimatedAvatar() {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: _avatarAnim,
          builder: (_, __) {
            return Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.purpleAccent
                        .withOpacity(0.5 + 0.3 * _avatarAnim.value),
                    blurRadius: 40,
                    spreadRadius: 8,
                  ),
                ],
              ),
            );
          },
        ),
        ScaleTransition(
          scale: Tween(begin: 1.0, end: 1.1)
              .chain(CurveTween(curve: Curves.easeInOut))
              .animate(_avatarAnim),
          child: const CircleAvatar(
            radius: 60,
            backgroundColor: Colors.white,
            child: Image(
              image: AssetImage('assets/images/mascot/mascot.png'),
              width: 80,
            ),
          ),
        ),
      ],
    );
  }

  // ⭐ Tổng số sao
  Widget _buildStarCard() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: totalStars.toDouble()),
      duration: const Duration(seconds: 1),
      builder: (context, value, _) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            gradient: const LinearGradient(
              colors: [Color(0xFF5E2CED), Color(0xFFFF8B00)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star_rounded, size: 50, color: Colors.white),
              const SizedBox(width: 15),
              Text(
                "Tổng sao\n${value.toInt()}",
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ],
          ),
        );
      },
    );
  }

  // 🎯 Mục tiêu tuần
  Widget _buildWeeklyGoal() {
    int filled = totalStars % 10;
    return Column(
      children: [
        const Text("🎯 Mục tiêu tuần",
            style: TextStyle(fontSize: 18, color: Colors.white70)),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            10,
                (i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Transform.scale(
                scale: 1 + 0.1 * sin(_sparkleAnim.value * pi * 2 + i),
                child: Icon(Icons.star_rounded,
                    color: i < filled ? Colors.amber : Colors.white24, size: 24),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 🏅 Huy hiệu + hiệu ứng sparkle
  Widget _buildBadgeWithSparkle(Map<String, dynamic> badge) {
    return Stack(
      alignment: Alignment.center,
      children: [
        _buildBadgeCard(badge),
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _sparkleAnim,
            builder: (_, __) {
              return Stack(
                children: List.generate(8, (i) {
                  final double top = _rand.nextDouble() * 100;
                  final double left = _rand.nextDouble() * 250;
                  final double size = _rand.nextDouble() * 8 + 4;
                  final double opacity = 0.3 + _rand.nextDouble() * 0.5;
                  return Positioned(
                    top: top,
                    left: left,
                    child: Opacity(
                      opacity: _sparkleAnim.value * opacity,
                      child: Icon(Icons.star_rounded,
                          color: Colors.white.withOpacity(opacity),
                          size: size),
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
          colors: [badge["color"], Colors.white.withOpacity(0.3)],
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
                  color: badge["color"]),
            ),
          ),
        ],
      ),
    );
  }
}
