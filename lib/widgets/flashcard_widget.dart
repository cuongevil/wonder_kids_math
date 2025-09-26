import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flip_card/flip_card.dart';
import 'package:audioplayers/audioplayers.dart';

import '../models/vn_letter.dart';
import '../services/audio_service.dart';
import 'celebration_overlay.dart';
import 'animated_background.dart';
import 'animated_gradient_background.dart';

class FlashcardWidget extends StatefulWidget {
  final List<VnLetter> letters;
  const FlashcardWidget({super.key, required this.letters});

  @override
  State<FlashcardWidget> createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends State<FlashcardWidget> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  final AudioPlayer _sfxPlayer = AudioPlayer();

  String? _animatingChar;
  String? _animatingImage;
  int _flipCount = 0;
  int _currentIndex = 0;

  void _playAudio(String? path) {
    if (path != null) {
      AudioService.play(path);
    }
  }

  Future<void> _playSfx(String asset) async {
    try {
      await _sfxPlayer.play(AssetSource(asset));
    } catch (_) {}
  }

  void _triggerFrontAnimation(String char) async {
    setState(() => _animatingChar = char);
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() => _animatingChar = null);
  }

  void _triggerImageAnimation(String char) async {
    setState(() => _animatingImage = char);
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _animatingImage = null);
  }

  void _increaseFlipCount() {
    setState(() {
      _flipCount++;
      if (_flipCount % 5 == 0) {
        CelebrationOverlay.show(context);
        _playSfx("assets/audio/pop.mp3");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final letters = widget.letters;
    final double progress =
    letters.isNotEmpty ? (_currentIndex + 1) / letters.length : 0.0;

    return AnimatedBackground(
      currentLetter: letters.isNotEmpty ? letters[_currentIndex].char : "A",
      child: letters.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: letters.length,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              itemBuilder: (context, index) {
                final letter = letters[index];
                return AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    double value = 0.0;
                    if (_pageController.position.haveDimensions) {
                      value = _pageController.page! - index;
                    }

                    final scale =
                    (1 - (value.abs() * 0.3)).clamp(0.8, 1.0);
                    final tilt = value * 0.25;
                    final isFocused = value.abs() < 0.1;

                    return Center(
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.0015)
                          ..rotateY(tilt),
                        child: Transform.scale(
                          scale: Curves.easeOut.transform(scale),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 800),
                            curve: Curves.easeInOut,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(40),
                              boxShadow: [
                                BoxShadow(
                                  color: isFocused
                                      ? Colors.pinkAccent.withOpacity(0.6)
                                      : Colors.pinkAccent
                                      .withOpacity(0.25),
                                  blurRadius: isFocused ? 28 : 18,
                                  spreadRadius: isFocused ? 6 : 3,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: child,
                          ),
                        ),
                      ),
                    );
                  },
                  child: FlipCard(
                    direction: FlipDirection.HORIZONTAL,
                    front: _buildFrontCard(letter),
                    back: _buildBackCard(letter),
                    onFlipDone: (isFront) {
                      if (!isFront) {
                        _triggerImageAnimation(letter.char);
                        _increaseFlipCount();
                        _playSfx("assets/audio/pop.mp3");
                      } else {
                        _triggerFrontAnimation(letter.char);
                      }
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                _RainbowProgressBar(progress: progress),
                const SizedBox(height: 8),
                Text(
                  "Đã học ${_currentIndex + 1}/${letters.length} thẻ",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFrontCard(VnLetter letter) {
    final isAnimating = _animatingChar == letter.char;
    return Card(
      elevation: 14,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      child: AnimatedGradientBackground(
        colors: const [
          Color(0xFFFFDEE9),
          Color(0xFFB5FFFC),
          Color(0xFFFFF6B7),
          Color(0xFFE1F5FE),
        ],
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white, width: 4),
        child: Center(
          child: AnimatedScale(
            scale: isAnimating ? 1.25 : 1.0,
            duration: const Duration(milliseconds: 350),
            curve: Curves.elasticOut,
            child: Stack(
              alignment: Alignment.center,
              children: [
                _AnimatedGradientText(text: letter.char, fontSize: 160),
                if (isAnimating)
                  ...List.generate(
                    6,
                        (i) =>
                        _Sparkle(angle: i * pi / 3, color: Colors.pinkAccent),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackCard(VnLetter letter) {
    final isAnimating = _animatingImage == letter.char;
    return Card(
      elevation: 14,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      child: AnimatedGradientBackground(
        colors: const [
          Color(0xFFE0C3FC),
          Color(0xFF8EC5FC),
          Color(0xFFD4FC79),
          Color(0xFFFFF6B7),
        ],
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white, width: 4),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (letter.imagePath != null)
                Hero(
                  tag: letter.char,
                  child: AnimatedScale(
                    scale: isAnimating ? 1.2 : 1.0,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.elasticOut,
                    child: AnimatedRotation(
                      turns: isAnimating ? 0.03 : 0.0,
                      duration: const Duration(milliseconds: 400),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.asset(
                          letter.imagePath!,
                          height: 200,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  _playAudio(letter.audioPath);
                  HapticFeedback.lightImpact();
                  _playSfx("assets/audio/pop.mp3");
                },
                icon: const Icon(Icons.volume_up, size: 28),
                label: const Text("Nghe lại", style: TextStyle(fontSize: 22)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  foregroundColor: Colors.white,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: const StadiumBorder(),
                  elevation: 6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 🌈 Gradient text động
class _AnimatedGradientText extends StatefulWidget {
  final String text;
  final double fontSize;
  const _AnimatedGradientText({required this.text, this.fontSize = 120});
  @override
  State<_AnimatedGradientText> createState() => _AnimatedGradientTextState();
}

class _AnimatedGradientTextState extends State<_AnimatedGradientText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller =
    AnimationController(vsync: this, duration: const Duration(seconds: 6))
      ..repeat();
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: const [
                Colors.pink,
                Colors.orange,
                Colors.yellow,
                Colors.green,
                Colors.blue,
                Colors.purple,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              transform: GradientRotation(_controller.value * 2 * pi),
            ).createShader(bounds);
          },
          child: Text(
            widget.text,
            style: TextStyle(
              fontSize: widget.fontSize,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              shadows: [
                const Shadow(
                    color: Colors.black26, offset: Offset(2, 2), blurRadius: 6),
                Shadow(
                    color: Colors.pinkAccent.withOpacity(0.6), blurRadius: 12),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// ✨ Sparkle hiệu ứng khi flip
class _Sparkle extends StatelessWidget {
  final double angle;
  final Color color;
  const _Sparkle({required this.angle, required this.color});
  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(80 * cos(angle), 80 * sin(angle)),
      child: Icon(Icons.star, color: color.withOpacity(0.8), size: 24),
    );
  }
}

/// 🌈⚡ Progress bar animated
class _RainbowProgressBar extends StatefulWidget {
  final double progress;
  const _RainbowProgressBar({required this.progress});
  @override
  State<_RainbowProgressBar> createState() => _RainbowProgressBarState();
}

class _RainbowProgressBarState extends State<_RainbowProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller =
    AnimationController(vsync: this, duration: const Duration(seconds: 4))
      ..repeat();
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          height: 14,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth * widget.progress;
                  return ShaderMask(
                    shaderCallback: (bounds) {
                      return LinearGradient(
                        colors: const [
                          Colors.red,
                          Colors.orange,
                          Colors.yellow,
                          Colors.green,
                          Colors.blue,
                          Colors.purple,
                        ],
                        begin: Alignment(-1 + 2 * _controller.value, 0),
                        end: Alignment(1 + 2 * _controller.value, 0),
                        tileMode: TileMode.mirror,
                      ).createShader(bounds);
                    },
                    child: Container(
                      width: width,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
