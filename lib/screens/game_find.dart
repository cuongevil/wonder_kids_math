import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';

import '../models/vn_letter.dart';
import '../models/mascot_mood.dart';
import '../widgets/game_base.dart';
import '../widgets/mascot_widget.dart';
import '../widgets/score_board.dart';
import '../widgets/rainbow_progress.dart';
import '../widgets/confetti_overlay.dart';
import '../services/audio_service.dart';
import '../mixins/game_level_mixin.dart';

class GameFind extends StatefulWidget {
  const GameFind({super.key});

  @override
  State<GameFind> createState() => _GameFindState();
}

class _GameFindState extends GameBaseState<GameFind>
    with SingleTickerProviderStateMixin, GameLevelMixin {
  @override
  String get gameId => "game1";

  @override
  String get title => "Tìm chữ";

  List<VnLetter> letters = [];
  VnLetter? targetLetter;
  List<VnLetter> options = [];
  VnLetter? selected;

  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    initLevelMixin();
    _loadLetters();

    _progressController =
    AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat();
  }

  @override
  void dispose() {
    disposeLevelMixin();
    _progressController.dispose();
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
        title: "✨ Xuất sắc!",
        subtitle: "Bạn đã săn chữ thành công 🎉",
        onNextRound: _nextRound,
      );
      return;
    }

    final random = Random();
    targetLetter = letters[random.nextInt(letters.length)];

    // tạo 4 option đảm bảo có target + không trùng
    final shuffled = [...letters]..shuffle();
    final setChars = <String>{targetLetter!.char};
    final List<VnLetter> temp = [targetLetter!];

    for (final l in shuffled) {
      if (setChars.length == 4) break;
      if (setChars.add(l.char)) temp.add(l);
    }
    temp.shuffle();
    options = temp;

    selected = null;
    mascotMood = MascotMood.idle;
    setState(() {});
  }

  void _checkAnswer(VnLetter chosen) async {
    final isCorrect = chosen.char == targetLetter!.char;
    await onAnswer(isCorrect);

    setState(() {
      selected = chosen;
      increaseScore(isCorrect);
    });

    if (isCorrect) {
      confettiController.play();
      AudioService.play("correct.mp3");
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        setState(() {
          round++;
          _nextRound();
        });
      });
    } else {
      AudioService.play("wrong.mp3");
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        setState(() => selected = null);
      });
    }
  }

  @override
  Widget buildGame(BuildContext context) {
    final progress = overallProgress();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orangeAccent, Colors.lightBlueAccent],
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
              const SizedBox(height: 12),
              if (targetLetter != null)
                Text("Tìm chữ: ${targetLetter!.char}",
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: options.map((l) {
                  final bool isSelected = selected == l;
                  final bool isRight = isSelected && l.char == targetLetter!.char;
                  final bool isWrong = isSelected && !isRight;

                  return GestureDetector(
                    onTap: () => _checkAnswer(l),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      width: 82,
                      height: 82,
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..scale(isSelected ? 1.08 : 1.0),
                      decoration: BoxDecoration(
                        color: isRight
                            ? Colors.greenAccent
                            : (isWrong ? Colors.redAccent : Colors.white),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(2, 2))
                        ],
                      ),
                      child: Text(
                        l.char,
                        style: const TextStyle(
                            fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }).toList(),
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
      selected = null;
    });
    _nextRound();
  }
}
