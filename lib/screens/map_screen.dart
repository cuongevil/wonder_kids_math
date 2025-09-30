import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import '../models/level.dart';
import '../services/progress_service.dart';
import '../widgets/level_node.dart';
import '../widgets/map_background.dart';
import 'level_detail.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  List<Level> levels = [];
  late ConfettiController _confettiController;
  late ScrollController _scrollController;
  late AnimationController _bounceController;

  int mascotPosition = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
      lowerBound: 0.95,
      upperBound: 1.05,
    )..repeat(reverse: true);

    _init();

    // 👉 rebuild khi scroll để update scale/opacity/bounce
    _scrollController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _confettiController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    final saved = await ProgressService.loadLevels();
    if (saved != null) {
      levels = saved;
    } else {
      levels = _defaultLevels();
      await ProgressService.saveLevels(levels);
    }
    setState(() {});
  }

  List<Level> _defaultLevels() {
    return [
      Level(index: 0, title: 'Start 🚀', type: LevelType.start, state: LevelState.playable),
      Level(index: 1, title: '1. Làng Số 0–10 🍎', type: LevelType.topic, state: LevelState.playable),
      Level(index: 2, title: '2. Rừng Số 11–20 🌲', type: LevelType.topic, state: LevelState.locked),
      Level(index: 3, title: '3. Cầu Cộng ≤10 🌉', type: LevelType.topic, state: LevelState.locked),
      Level(index: 4, title: '4. Hang Trừ ≤10 ⛰️', type: LevelType.topic, state: LevelState.locked),
      Level(index: 5, title: '5. Đồng Bằng So Sánh ⚖️', type: LevelType.topic, state: LevelState.locked),
      Level(index: 6, title: '6. Sông Cộng ≤20 🌊', type: LevelType.topic, state: LevelState.locked),
      Level(index: 7, title: '7. Sa Mạc Trừ ≤20 🏜️', type: LevelType.topic, state: LevelState.locked),
      Level(index: 8, title: '8. Thành Phố Hình Học 🏙️', type: LevelType.topic, state: LevelState.locked),
      Level(index: 9, title: '9. Thung Lũng Đo Lường ⏰', type: LevelType.topic, state: LevelState.locked),
      Level(index: 10, title: '10. Lâu Đài Boss Cuối 🏰🐉', type: LevelType.boss, state: LevelState.locked),
      Level(index: 11, title: 'End 🌟', type: LevelType.end, state: LevelState.locked),
    ];
  }

  void _openLevel(Level lv) async {
    if (lv.state != LevelState.playable) return;
    final result = await Navigator.pushNamed(
      context,
      lv.route ?? LevelDetail.routeName,
      arguments: lv.index,
    );
    if (result == true) _markCompleted(lv.index);
  }

  Future<void> _markCompleted(int idx) async {
    final i = levels.indexWhere((e) => e.index == idx);
    if (i != -1) {
      levels[i].state = LevelState.completed;
      if (i + 1 < levels.length && levels[i + 1].state == LevelState.locked) {
        levels[i + 1].state = LevelState.playable;
      }
      mascotPosition = i;
      _confettiController.play();
      await ProgressService.saveLevels(levels);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (levels.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    const double amplitude = 100;
    const double spacing = 180;
    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;
    final totalHeight = levels.length * spacing + 220;

    final double topPadding = kToolbarHeight + MediaQuery.of(context).padding.top + 16;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        title: Row(
          children: [
            const SizedBox(width: 8),
            const Text(
              "Học toán",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [Shadow(color: Colors.black26, blurRadius: 4)],
              ),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF81D4FA), Color(0xFFF48FB1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // 🌄 Background
          Positioned.fill(
            child: MapBackground(
              scrollController: _scrollController,
              currentLevel: mascotPosition,
            ),
          ),

          // 📜 Scroll map
          SingleChildScrollView(
            controller: _scrollController,
            child: SizedBox(
              width: screenW,
              height: totalHeight,
              child: Stack(
                children: [
                  for (var i = 0; i < levels.length; i++)
                    Builder(builder: (context) {
                      final levelTop = i * spacing + topPadding;
                      final centerY = _scrollController.hasClients
                          ? _scrollController.offset + screenH / 2
                          : screenH / 2;
                      final distance = (levelTop - centerY).abs();

                      // scale và opacity theo khoảng cách
                      final scale = (1.1 - (distance / screenH)).clamp(0.8, 1.1);
                      final opacity = (1.2 - (distance / (screenH * 0.7))).clamp(0.4, 1.0);

                      // bounce nếu gần tâm
                      final isCenter = distance < 50;

                      Widget node = LevelNode(
                        level: levels[i],
                        onTap: () => _openLevel(levels[i]),
                      );

                      if (isCenter) {
                        node = ScaleTransition(
                          scale: _bounceController,
                          child: node,
                        );
                      }

                      return Positioned(
                        top: levelTop,
                        left: screenW / 2 + sin(i * 0.8) * amplitude - 45,
                        child: Transform.scale(
                          scale: scale,
                          child: Opacity(
                            opacity: opacity,
                            child: node,
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),

          // 🎉 Confetti ăn mừng
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              colors: const [Colors.pink, Colors.blue, Colors.yellow, Colors.green],
            ),
          ),
        ],
      ),
    );
  }
}
