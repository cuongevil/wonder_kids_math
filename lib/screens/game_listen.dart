// lib/screens/game_listen.dart
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/vn_letter.dart';
import '../models/mascot_mood.dart';
import '../widgets/game_base.dart';
import '../widgets/mascot_widget.dart';
import '../widgets/score_board.dart';
import '../widgets/rainbow_progress.dart';
import '../widgets/confetti_overlay.dart';
import '../services/audio_service.dart';
import '../mixins/game_level_mixin.dart';

class GameListen extends StatefulWidget {
  const GameListen({super.key});

  @override
  State<GameListen> createState() => _GameListenState();
}

class _GameListenState extends GameBaseState<GameListen>
    with TickerProviderStateMixin, GameLevelMixin {
  @override
  String get gameId => "game4";

  @override
  String get title => "Nghe và Chọn";

  List<VnLetter> letters = [];
  VnLetter? targetLetter;
  List<VnLetter> options = [];

  late final AnimationController _progressController;
  late final AnimationController _shakeCtrl;
  String? _shakeChar;

  @override
  void initState() {
    super.initState();
    initLevelMixin();
    _loadLetters();

    _progressController =
    AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat();

    _shakeCtrl =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
  }

  @override
  void dispose() {
    _progressController.dispose();
    _shakeCtrl.dispose();
    disposeLevelMixin();
    super.dispose();
  }

  Future<void> _loadLetters() async {
    final String response =
    await rootBundle.loadString('assets/config/letters.json');
    final List<dynamic> data = json.decode(response);

    setState(() {
      letters = data.map((e) => VnLetter.fromJson(e)).toList();
      _nextRound();
    });
  }

  void _nextRound() {
    if (round >= maxRound) {
      showLevelComplete(
        title: "✨ Tuyệt vời!",
        subtitle: "Cùng bước sang màn tiếp theo nhé 👏",
        onNextRound: _nextRound,
      );
      return;
    }

    if (letters.isEmpty) return;

    final rnd = Random();
    final optionCount = (level * 2 + 2).clamp(4, 8);

    targetLetter = letters[rnd.nextInt(letters.length)];
    final pool = [...letters]..removeWhere((l) => l.char == targetLetter!.char);
    pool.shuffle();

    final distractors = pool.take(optionCount - 1).toList();
    options = ([targetLetter!, ...distractors]..shuffle());

    mascotMood = MascotMood.idle;
    _shakeChar = null;

    if (targetLetter!.audioPath != null) {
      AudioService.play(targetLetter!.audioPath!);
    }

    setState(() {});
  }

  Future<void> _replayAudio() async {
    if (targetLetter?.audioPath != null) {
      await AudioService.play(targetLetter!.audioPath!);
    }
  }

  void _checkAnswer(VnLetter chosen) async {
    final isCorrect = chosen.char == targetLetter!.char;
    await onAnswer(isCorrect);

    setState(() {
      increaseScore(isCorrect);
      mascotMood = isCorrect ? MascotMood.happy : MascotMood.sad;
    });

    if (isCorrect) {
      confettiController.play();
      AudioService.play("correct.mp3");

      await Future.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;

      setState(() {
        round++;
        mascotMood = MascotMood.celebrate;
      });

      _nextRound();
    } else {
      AudioService.play("wrong.mp3");
      setState(() => _shakeChar = chosen.char);
      _shakeCtrl.forward(from: 0).whenComplete(() {
        if (!mounted) return;
        setState(() {
          _shakeChar = null;
          mascotMood = MascotMood.idle;
        });
      });
    }
  }

  double _progress() => overallProgress();

  @override
  Widget buildGame(BuildContext context) {
    if (targetLetter == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final progress = _progress();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.pink.shade50, Colors.blue.shade50],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              RainbowProgress(progress: progress, controller: _progressController),
              ScoreBoard(
                streak: streak,
                maxStreak: maxStreak,
                totalCorrect: totalCorrect,
              ),
              const SizedBox(height: 8),
              const Text(
                "Nghe âm thanh và chọn chữ đúng",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),

              _SpeakerButton(onTap: _replayAudio),
              const SizedBox(height: 24),

              Expanded(
                child: Center(
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: options.map((l) {
                      final isShaking = _shakeChar == l.char;
                      return _AnswerTile(
                        letter: l,
                        isShaking: isShaking,
                        shakeCtrl: _shakeCtrl,
                        onTap: () => _checkAnswer(l),
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 120),
            ],
          ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(child: MascotWidget(mood: mascotMood)),
          ),
          ConfettiOverlay(controller: confettiController),
        ],
      ),
    );
  }

  @override
  void onReset() {
    setState(() {
      round = 0;
      level = 1;
      streak = 0;
      maxStreak = 0;
      totalCorrect = 0;
      mascotMood = MascotMood.idle;
      targetLetter = null;
      options.clear();
      _shakeChar = null;
    });
    _loadLetters();
  }
}

/// Nút loa với sóng âm + nhảy khi click (không đẩy layout)
class _SpeakerButton extends StatefulWidget {
  final VoidCallback onTap;
  const _SpeakerButton({required this.onTap});

  @override
  State<_SpeakerButton> createState() => _SpeakerButtonState();
}

class _SpeakerButtonState extends State<_SpeakerButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late AnimationController _scaleCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _scaleCtrl.dispose();
    super.dispose();
  }

  void _play() {
    widget.onTap(); // phát âm
    _scaleCtrl.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _play,
      child: SizedBox(
        width: 100,
        height: 100,
        child: Stack(
          alignment: Alignment.center,
          children: [
            _PulseRing(controller: _pulseCtrl, delay: 0.0),
            _PulseRing(controller: _pulseCtrl, delay: 0.33),
            _PulseRing(controller: _pulseCtrl, delay: 0.66),
            AnimatedBuilder(
              animation: _scaleCtrl,
              builder: (context, child) {
                // scale 1.0 -> 1.15 khi click
                final scale = 1.0 + 0.15 * (1 - _scaleCtrl.value);
                return Transform.scale(scale: scale, child: child);
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Colors.pinkAccent, Colors.orangeAccent],
                  ),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
                  ],
                ),
                child: const Icon(Icons.volume_up, size: 48, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sóng âm lan tỏa
class _PulseRing extends StatelessWidget {
  final AnimationController controller;
  final double delay;

  const _PulseRing({required this.controller, required this.delay});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final t = ((controller.value + delay) % 1.0);
        final size = 80 + 60 * t;
        final opacity = (1 - t).clamp(0.0, 1.0);

        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.pinkAccent.withOpacity(0.1 * opacity),
            border: Border.all(
              color: Colors.pinkAccent.withOpacity(0.3 * opacity),
              width: 2,
            ),
          ),
        );
      },
    );
  }
}

/// Ô đáp án có shake khi sai
class _AnswerTile extends StatelessWidget {
  final VnLetter letter;
  final bool isShaking;
  final AnimationController shakeCtrl;
  final VoidCallback onTap;

  const _AnswerTile({
    required this.letter,
    required this.isShaking,
    required this.shakeCtrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final shakeAnim = Tween<double>(begin: -8, end: 8)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(shakeCtrl);

    final tile = Container(
      width: 88,
      height: 88,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade100, Colors.blue.shade200],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(2, 2)),
        ],
      ),
      child: Text(
        letter.char,
        style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w800),
      ),
    );

    return GestureDetector(
      onTap: onTap,
      child: isShaking
          ? AnimatedBuilder(
        animation: shakeAnim,
        builder: (_, child) => Transform.translate(
          offset: Offset(shakeAnim.value, 0),
          child: child,
        ),
        child: tile,
      )
          : tile,
    );
  }
}
