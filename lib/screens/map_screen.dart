import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import '../models/level.dart';
import '../services/progress_service.dart';
import '../widgets/level_node.dart';
import '../widgets/map_background.dart';
import '../widgets/app_scaffold.dart';
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

    _scrollController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _bounceController.stop();
    _confettiController.stop();
    _confettiController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  /// 🔹 Khởi tạo dữ liệu level
  Future<void> _init() async {
    final saved = await ProgressService.loadLevels();
    if (saved.isNotEmpty) {
      levels = saved;
    } else {
      levels = _defaultLevels();
      await ProgressService.saveLevels(levels);
    }

    // 🔹 tìm index playable đầu tiên
    final firstPlayableIndex = levels.indexWhere((e) => e.state == LevelState.playable);

    if (mounted) {
      setState(() {});
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients && firstPlayableIndex != -1) {
          const spacing = 240.0;
          final screenH = MediaQuery.of(context).size.height;
          final topPadding = kToolbarHeight + MediaQuery.of(context).padding.top + 16;

          final targetOffset =
              firstPlayableIndex * spacing - screenH / 2 + spacing / 2 + topPadding;

          _scrollController.jumpTo(
            targetOffset.clamp(0, _scrollController.position.maxScrollExtent),
          );
        }
      });
    }
  }

  /// 🔹 Danh sách level mặc định
  List<Level> _defaultLevels() {
    return [
      Level(index: 0, title: 'Bắt đầu', type: LevelType.start, state: LevelState.playable),
      Level(index: 1, title: 'Số 0–10', type: LevelType.topic, state: LevelState.locked, route: '/learn_numbers'),
      Level(index: 2, title: 'Số 11–20', type: LevelType.topic, state: LevelState.locked, route: '/learn_numbers_20'),
      Level(index: 3, title: 'Cộng ≤10', type: LevelType.topic, state: LevelState.locked, route: '/game_addition10'),
      Level(index: 4, title: 'Trừ ≤10', type: LevelType.topic, state: LevelState.locked, route: '/game_subtraction10'),
      Level(index: 5, title: 'So Sánh', type: LevelType.topic, state: LevelState.locked, route: '/game_compare'),
      Level(index: 6, title: 'Cộng ≤20', type: LevelType.topic, state: LevelState.locked, route: '/game_addition20'),
      Level(index: 7, title: 'Trừ ≤20', type: LevelType.topic, state: LevelState.locked, route: '/game_subtraction20'),
      Level(index: 8, title: 'Hình Học', type: LevelType.topic, state: LevelState.locked, route: '/game_shapes'),
      Level(index: 9, title: 'Đo Lường', type: LevelType.topic, state: LevelState.locked, route: '/game_measure_time'),
      Level(index: 10, title: 'Tổng hợp', type: LevelType.boss, state: LevelState.locked, route: '/game_final_boss'),
      Level(index: 11, title: 'Kết thúc', type: LevelType.end, state: LevelState.locked),
    ];
  }

  /// 🔹 Mở 1 level
  void _openLevel(Level lv) async {
    if (lv.state == LevelState.locked) return;
    final result = await Navigator.pushNamed(
      context,
      lv.route ?? LevelDetail.routeName,
      arguments: lv.index,
    );
    if (result == true && lv.state != LevelState.completed) {
      _markCompleted(lv.index);
    }
  }

  /// 🔹 Đánh dấu level hoàn thành
  Future<void> _markCompleted(int idx) async {
    final i = levels.indexWhere((e) => e.index == idx);
    if (i != -1) {
      levels[i].state = LevelState.completed;
      if (i + 1 < levels.length && levels[i + 1].state == LevelState.locked) {
        levels[i + 1].state = LevelState.playable;
      }
      mascotPosition = i;

      if (mounted) {
        _confettiController.play();
        setState(() {});
      }

      await ProgressService.saveLevels(levels);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (levels.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    const double spacing = 240;
    const double nodeSize = 100;
    const double maxScale = 1.1;

    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;
    final totalHeight = levels.length * spacing + 240;

    const extraGlow = 40.0;
    final maxNodeSize = nodeSize * maxScale + extraGlow;
    final safeAmplitude = (screenW - maxNodeSize) / 2 * 0.3;

    const double minMargin = 8.0;
    const double bias = -40.0;

    final double topPadding = kToolbarHeight + MediaQuery.of(context).padding.top + 16;

    return AppScaffold(
      title: "Học toán",
      levels: levels,
      onLevelsChanged: (updated) {
        setState(() {
          levels = updated;
        });
      },
      body: Stack(
        children: [
          Positioned.fill(
            child: MapBackground(
              scrollController: _scrollController,
              currentLevel: mascotPosition,
            ),
          ),
          SingleChildScrollView(
            controller: _scrollController,
            child: SizedBox(
              width: screenW,
              height: totalHeight,
              child: Stack(
                children: [
                  for (var i = 0; i < levels.length; i++)
                    Builder(
                      builder: (context) {
                        final levelTop = i * spacing + topPadding;
                        final centerY = _scrollController.hasClients
                            ? _scrollController.offset + screenH / 2
                            : screenH / 2;
                        final distance = (levelTop - centerY).abs();

                        final scale = (1.1 - (distance / screenH)).clamp(0.8, 1.1);
                        final opacity = (1.2 - (distance / (screenH * 0.7))).clamp(0.4, 1.0);
                        final isCenter = distance < 50;

                        Widget node = LevelNode(
                          level: levels[i],
                          onTap: () => _openLevel(levels[i]),
                          isCenter: isCenter,
                          isNight: DateTime.now().hour >= 18 || DateTime.now().hour < 6,
                        );

                        if (isCenter) {
                          node = ScaleTransition(
                            scale: _bounceController,
                            child: node,
                          );
                        }

                        double rawLeft =
                            (screenW - nodeSize) / 2 + sin(i * 0.8) * safeAmplitude + bias;
                        double left = rawLeft.clamp(minMargin, screenW - nodeSize - minMargin);

                        return Positioned(
                          top: levelTop,
                          left: left,
                          child: Transform.scale(
                            scale: scale,
                            child: Opacity(opacity: opacity, child: node),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
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
