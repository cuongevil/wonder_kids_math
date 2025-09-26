import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../models/vn_letter.dart';
import '../services/tts_service.dart';

class LetterScreen extends StatefulWidget {
  final List<VnLetter> letters;
  final int currentIndex;

  const LetterScreen({
    super.key,
    required this.letters,
    required this.currentIndex,
  });

  @override
  State<LetterScreen> createState() => _LetterScreenState();
}

class _LetterScreenState extends State<LetterScreen>
    with TickerProviderStateMixin {
  final _tts = TtsService();
  final _player = AudioPlayer();

  late VnLetter currentLetter;
  late AnimationController _imgBounceController;
  late AnimationController _particleController;

  final List<_Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    currentLetter = widget.letters[widget.currentIndex];

    _imgBounceController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tts.dispose();
    _player.dispose();
    _imgBounceController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  Future<void> _speakLetter() async {
    await _tts.speak('Chữ ${currentLetter.char}');
    _spawnParticles();
    _particleController.forward(from: 0);
  }

  Future<void> _playAudioIfAny() async {
    final path = currentLetter.audioPath;
    if (path == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(
            "Không có âm thanh cho chữ này")),
      );
      return;
    }
    await _player.stop();
    await _player.play(AssetSource(path));
    _spawnParticles();
    _particleController.forward(from: 0);
  }

  void _spawnParticles() {
    _particles.clear();
    const icons = [Icons.star, Icons.favorite, Icons.music_note];
    for (int i = 0; i < 8; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final distance = 40 + _random.nextDouble() * 40;
      _particles.add(
        _Particle(
          dx: cos(angle) * distance,
          dy: sin(angle) * distance,
          size: 14 + _random.nextDouble() * 10,
          rotation: _random.nextDouble() * 2 * pi,
          icon: icons[_random.nextInt(icons.length)],
          color: Colors.primaries[_random.nextInt(Colors.primaries.length)]
              .shade300,
        ),
      );
    }
  }

  void _goToLetter(int newIndex) {
    if (newIndex < 0 || newIndex >= widget.letters.length) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => LetterScreen(
          letters: widget.letters,
          currentIndex: newIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = currentLetter;

    return Scaffold(
      appBar: AppBar(
        title: Text("Chữ ${l.char}"),
        centerTitle: true,
        backgroundColor: Colors.pinkAccent.shade100,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB3E5FC), Color(0xFFF8BBD0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              children: [
                const SizedBox(height: 20),

                // Ảnh minh họa có bounce
                if (l.imagePath != null)
                  ScaleTransition(
                    scale: Tween<double>(begin: 1.0, end: 1.05).animate(
                      CurvedAnimation(
                        parent: _imgBounceController,
                        curve: Curves.easeInOut,
                      ),
                    ),
                    child: Image.asset(
                      l.imagePath!,
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.4,
                      fit: BoxFit.contain,
                    ),
                  ),

                const SizedBox(height: 50),

                // 2 nút chính
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildCircleButton(
                      icon: Icons.volume_up,
                      colors: [Colors.pinkAccent, Colors.pink],
                      onTap: _speakLetter,
                    ),
                    const SizedBox(width: 40),
                    _buildCircleButton(
                      icon: Icons.music_note,
                      colors: [Colors.blueAccent, Colors.lightBlue],
                      onTap: _playAudioIfAny,
                    ),
                  ],
                ),

                const Spacer(),

                // Nút điều hướng trước/sau
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (widget.currentIndex > 0)
                      Padding(
                        padding: const EdgeInsets.only(left: 16, bottom: 16),
                        child: _buildCircleButton(
                          icon: Icons.arrow_back,
                          colors: [Colors.orange, Colors.deepOrange],
                          onTap: () => _goToLetter(widget.currentIndex - 1),
                        ),
                      ),
                    if (widget.currentIndex < widget.letters.length - 1)
                      Padding(
                        padding: const EdgeInsets.only(right: 16, bottom: 16),
                        child: _buildCircleButton(
                          icon: Icons.arrow_forward,
                          colors: [Colors.green, Colors.lightGreen],
                          onTap: () => _goToLetter(widget.currentIndex + 1),
                        ),
                      ),
                  ],
                ),
              ],
            ),

            // Particle effect
            ..._particles.map((p) {
              final progress = _particleController.value;
              final dx = p.dx * progress;
              final dy = p.dy * progress;
              final opacity = (1 - progress).clamp(0.0, 1.0);
              return Positioned.fill(
                child: Transform.translate(
                  offset: Offset(dx, dy),
                  child: Transform.rotate(
                    angle: p.rotation,
                    child: Opacity(
                      opacity: opacity,
                      child: Icon(
                        p.icon,
                        size: p.size,
                        color: p.color,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  /// Nút gradient pastel
  Widget _buildCircleButton({
    required IconData icon,
    required List<Color> colors,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.first.withOpacity(0.5),
              blurRadius: 12,
              offset: const Offset(2, 6),
            )
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 36),
      ),
    );
  }
}

class _Particle {
  final double dx;
  final double dy;
  final double size;
  final double rotation;
  final IconData icon;
  final Color color;

  _Particle({
    required this.dx,
    required this.dy,
    required this.size,
    required this.rotation,
    required this.icon,
    required this.color,
  });
}
