import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import '../models/level.dart';
import '../services/progress_service.dart';
import '../utils/route_observer.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/level_node.dart';
import '../widgets/map_background.dart';
import 'level_detail.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with TickerProviderStateMixin, RouteAware {
  List<Level> levels = [];
  late ConfettiController _confettiController;
  late ScrollController _scrollController;
  late AnimationController _bounceController;

  int mascotPosition = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
      lowerBound: 0.95,
      upperBound: 1.05,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _bounceController.repeat(reverse: true);
    });

    _init();

    _scrollController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    appRouteObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    _bounceController.stop();
    _confettiController.stop();
    _scrollController.dispose();
    _bounceController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  /// ✅ Khi quay lại từ màn hình khác
  @override
  void didPopNext() {
    _refreshLevels();
  }

  /// Khởi tạo dữ liệu ban đầu
  Future<void> _init() async {
    levels = await ProgressService.ensureDefaultLevels(_defaultLevels);

    for (var lv in levels) {
      if (lv.levelKey != null) {
        lv.stars = await ProgressService.getStars(lv.levelKey!);
        lv.total = await _getTotalForLevel(lv.levelKey!);
      }
    }

    // Tìm level playable đầu tiên để focus
    final firstPlayableIndex = levels.indexWhere(
      (e) => e.state == LevelState.playable,
    );

    if (mounted) {
      setState(() {});
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients && firstPlayableIndex != -1) {
          const spacing = 240.0;
          final screenH = MediaQuery.of(context).size.height;
          final topPadding =
              kToolbarHeight + MediaQuery.of(context).padding.top + 16;
          final targetOffset =
              firstPlayableIndex * spacing -
              screenH / 2 +
              spacing / 2 +
              topPadding;
          _scrollController.jumpTo(
            targetOffset.clamp(0, _scrollController.position.maxScrollExtent),
          );
        }
      });
    }
  }

  /// ✅ Làm mới level khi quay lại map
  Future<void> _refreshLevels() async {
    levels = await ProgressService.ensureDefaultLevels(_defaultLevels);
    for (var lv in levels) {
      if (lv.levelKey != null) {
        lv.stars = await ProgressService.getStars(lv.levelKey!);
        lv.total = await _getTotalForLevel(lv.levelKey!);
      }
    }
    if (mounted) setState(() {});
  }

  /// Tổng số bài trong từng level
  Future<int> _getTotalForLevel(String key) async {
    switch (key) {
      case "0_10":
        return 11;
      case "0_20":
        return 21;
      case "0_50":
        return 51;
      case "0_100":
        return 101;
      case "compare":
        return 10;
      case "addition10":
        return 10;
      case "subtraction10":
        return 10;
      case "addition20":
        return 10;
      case "subtraction20":
        return 10;
      case "addition50":
        return 10;
      case "subtraction50":
        return 10;
      case "addition100":
        return 10;
      case "subtraction100":
        return 10;
      case "shapes":
        return 12;
      case "measure":
        return 10;
      case "final_boss":
        return 20;
      default:
        return 0;
    }
  }

  /// Danh sách level mặc định
  List<Level> _defaultLevels() {
    return [
      Level(
        index: 0,
        title: 'Bắt đầu',
        type: LevelType.start,
        state: LevelState.playable,
      ),
      Level(
        index: 1,
        title: 'Số 0–10',
        type: LevelType.topic,
        route: '/learn_numbers',
        levelKey: "0_10",
      ),
      Level(
        index: 2,
        title: 'Số 0–20',
        type: LevelType.topic,
        route: '/learn_numbers_20',
        levelKey: "0_20",
      ),
      Level(
        index: 3,
        title: 'Số 0–50',
        type: LevelType.topic,
        route: '/learn_numbers_50',
        levelKey: "0_50",
      ),
      Level(
        index: 4,
        title: 'Số 0–100',
        type: LevelType.topic,
        route: '/learn_numbers_100',
        levelKey: "0_100",
      ),
      Level(
        index: 5,
        title: 'So Sánh',
        type: LevelType.topic,
        route: '/game_compare',
        levelKey: "compare",
      ),
      Level(
        index: 6,
        title: 'Cộng ≤10',
        type: LevelType.topic,
        route: '/game_addition10',
        levelKey: "addition10",
      ),
      Level(
        index: 7,
        title: 'Trừ ≤10',
        type: LevelType.topic,
        route: '/game_subtraction10',
        levelKey: "subtraction10",
      ),
      Level(
        index: 8,
        title: 'Cộng ≤20',
        type: LevelType.topic,
        route: '/game_addition20',
        levelKey: "addition20",
      ),
      Level(
        index: 9,
        title: 'Trừ ≤20',
        type: LevelType.topic,
        route: '/game_subtraction20',
        levelKey: "subtraction20",
      ),
      Level(
        index: 10,
        title: 'Cộng ≤50',
        type: LevelType.topic,
        route: '/game_addition50',
        levelKey: "addition50",
      ),
      Level(
        index: 11,
        title: 'Trừ ≤50',
        type: LevelType.topic,
        route: '/game_subtraction50',
        levelKey: "subtraction50",
      ),
      Level(
        index: 12,
        title: 'Cộng ≤100',
        type: LevelType.topic,
        route: '/game_addition100',
        levelKey: "addition100",
      ),
      Level(
        index: 13,
        title: 'Trừ ≤100',
        type: LevelType.topic,
        route: '/game_subtraction100',
        levelKey: "subtraction100",
      ),
      Level(
        index: 14,
        title: 'Hình Học',
        type: LevelType.topic,
        route: '/game_shapes',
        levelKey: "shapes",
      ),
      Level(
        index: 15,
        title: 'Đo Lường',
        type: LevelType.topic,
        route: '/game_measure_time',
        levelKey: "measure",
      ),
      Level(
        index: 16,
        title: 'Tổng hợp',
        type: LevelType.boss,
        route: '/game_final_boss',
        levelKey: "final_boss",
      ),
      Level(index: 17, title: 'Kết thúc', type: LevelType.end),
    ];
  }

  /// Mở 1 level
  void _openLevel(Level lv) async {
    if (lv.state == LevelState.locked) return;
    await Navigator.pushNamed(
      context,
      lv.route ?? LevelDetail.routeName,
      arguments: lv.index,
    );
    // 🔹 Khi quay lại, load lại danh sách
    await _refreshLevels();
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
    final double topPadding =
        kToolbarHeight + MediaQuery.of(context).padding.top + 16;

    return AppScaffold(
      title: "Học toán",
      levels: levels,
      onLevelsChanged: (updated) => setState(() => levels = updated),
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
                        final scale = (1.1 - (distance / screenH)).clamp(
                          0.8,
                          1.1,
                        );
                        final opacity = (1.2 - (distance / (screenH * 0.7)))
                            .clamp(0.4, 1.0);
                        final isCenter = distance < 50;

                        Widget node = LevelNode(
                          level: levels[i],
                          onTap: () => _openLevel(levels[i]),
                          isCenter: isCenter,
                          isNight:
                              DateTime.now().hour >= 18 ||
                              DateTime.now().hour < 6,
                        );

                        if (isCenter) {
                          node = ScaleTransition(
                            scale: _bounceController,
                            child: node,
                          );
                        }

                        double rawLeft =
                            (screenW - nodeSize) / 2 +
                            sin(i * 0.8) * safeAmplitude +
                            bias;
                        double left = rawLeft.clamp(
                          minMargin,
                          screenW - nodeSize - minMargin,
                        );

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
              colors: const [
                Colors.pink,
                Colors.blue,
                Colors.yellow,
                Colors.green,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
