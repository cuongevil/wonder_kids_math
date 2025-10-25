import 'dart:math';
import 'dart:ui';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/level.dart';
import '../services/progress_service.dart';
import '../utils/route_observer.dart';
import '../widgets/level_node.dart';
import 'level_detail.dart';

/// 💜 MapScreen — TPBank Fintech Glow Style 2025 + Auto Hide BottomNav
class MapScreen extends StatefulWidget {
  final ValueChanged<bool>? onScrollDirectionChanged; // 👈 callback báo ẩn/hiện nav

  const MapScreen({super.key, this.onScrollDirectionChanged});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with TickerProviderStateMixin, RouteAware {
  List<Level> levels = [];
  late ConfettiController _confettiController;
  late ScrollController _scrollController;
  late AnimationController _bounceController;

  double _lastOffset = 0;
  bool _isNavHidden = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
      lowerBound: 0.95,
      upperBound: 1.05,
    )..repeat(reverse: true);

    _init();

    // 👇 Lắng nghe cuộn để xác định hướng (ẩn / hiện BottomNav)
    _scrollController.addListener(() {
      final offset = _scrollController.offset;
      final diff = offset - _lastOffset;

      if (diff > 10 && !_isNavHidden) {
        widget.onScrollDirectionChanged?.call(true);
        _isNavHidden = true;
      } else if (diff < -10 && _isNavHidden) {
        widget.onScrollDirectionChanged?.call(false);
        _isNavHidden = false;
      }

      _lastOffset = offset;
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
    _bounceController.dispose();
    _confettiController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didPopNext() => _refreshLevels();

  // 🔹 Khởi tạo dữ liệu ban đầu
  Future<void> _init() async {
    levels = await ProgressService.ensureDefaultLevels(_defaultLevels);
    for (var lv in levels) {
      if (lv.levelKey != null) {
        lv.stars = await ProgressService.getStars(lv.levelKey!);
        lv.total = await _getTotalForLevel(lv.levelKey!);
      }
    }

    final firstPlayableIndex =
    levels.indexWhere((e) => e.state == LevelState.playable);

    if (mounted) {
      setState(() {});
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients && firstPlayableIndex != -1) {
          const spacing = 240.0;
          final screenH = MediaQuery.of(context).size.height;
          final topPadding =
              kToolbarHeight + MediaQuery.of(context).padding.top + 16;
          final targetOffset = firstPlayableIndex * spacing -
              screenH / 2 +
              spacing / 2 +
              topPadding;
          _scrollController.animateTo(
            targetOffset.clamp(0, _scrollController.position.maxScrollExtent),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
          );
        }
      });
    }
  }

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

  Future<int> _getTotalForLevel(String key) async {
    const totals = {
      "0_10": 11,
      "0_20": 21,
      "0_50": 51,
      "0_100": 101,
      "compare": 10,
      "addition10": 10,
      "subtraction10": 10,
      "addition20": 10,
      "subtraction20": 10,
      "addition50": 10,
      "subtraction50": 10,
      "addition100": 10,
      "subtraction100": 10,
      "shapes": 12,
      "measure": 10,
      "final_boss": 20,
    };
    return totals[key] ?? 0;
  }

  List<Level> _defaultLevels() => [
    Level(
        index: 0,
        title: 'Bắt đầu',
        type: LevelType.start,
        state: LevelState.playable,
        levelKey: "start"),
    Level(
        index: 1,
        title: 'Số 0–10',
        type: LevelType.topic,
        route: '/learn_numbers',
        levelKey: "0_10"),
    Level(
        index: 2,
        title: 'Số 0–20',
        type: LevelType.topic,
        route: '/learn_numbers_20',
        levelKey: "0_20"),
    Level(
        index: 3,
        title: 'Số 0–50',
        type: LevelType.topic,
        route: '/learn_numbers_50',
        levelKey: "0_50"),
    Level(
        index: 4,
        title: 'Số 0–100',
        type: LevelType.topic,
        route: '/learn_numbers_100',
        levelKey: "0_100"),
    Level(
        index: 5,
        title: 'So Sánh',
        type: LevelType.topic,
        route: '/game_compare',
        levelKey: "compare"),
    Level(
        index: 6,
        title: 'Cộng ≤10',
        type: LevelType.topic,
        route: '/game_addition10',
        levelKey: "addition10"),
    Level(
        index: 7,
        title: 'Trừ ≤10',
        type: LevelType.topic,
        route: '/game_subtraction10',
        levelKey: "subtraction10"),
    Level(
        index: 8,
        title: 'Cộng ≤20',
        type: LevelType.topic,
        route: '/game_addition20',
        levelKey: "addition20"),
    Level(
        index: 9,
        title: 'Trừ ≤20',
        type: LevelType.topic,
        route: '/game_subtraction20',
        levelKey: "subtraction20"),
    Level(
        index: 10,
        title: 'Cộng ≤50',
        type: LevelType.topic,
        route: '/game_addition50',
        levelKey: "addition50"),
    Level(
        index: 11,
        title: 'Trừ ≤50',
        type: LevelType.topic,
        route: '/game_subtraction50',
        levelKey: "subtraction50"),
    Level(
        index: 12,
        title: 'Cộng ≤100',
        type: LevelType.topic,
        route: '/game_addition100',
        levelKey: "addition100"),
    Level(
        index: 13,
        title: 'Trừ ≤100',
        type: LevelType.topic,
        route: '/game_subtraction100',
        levelKey: "subtraction100"),
    Level(
        index: 14,
        title: 'Hình Học',
        type: LevelType.topic,
        route: '/game_shapes',
        levelKey: "shapes"),
    Level(
        index: 15,
        title: 'Đo Lường',
        type: LevelType.topic,
        route: '/game_measure_time',
        levelKey: "measure"),
    Level(
        index: 16,
        title: 'Tổng hợp',
        type: LevelType.boss,
        route: '/game_final_boss',
        levelKey: "final_boss"),
  ];

  void _openLevel(Level lv) async {
    if (lv.state == LevelState.locked) return;
    HapticFeedback.lightImpact();

    // ✅ Luôn truyền object Level thay vì int
    final bool? completed = await Navigator.pushNamed(
      context,
      lv.route ?? LevelDetail.routeName,
      arguments: lv,
    ) as bool?;

    if (completed == true) {
      await _refreshLevels();
      _confettiController.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (levels.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isDark = Theme.of(context).brightness == Brightness.dark ||
        DateTime.now().hour >= 18 ||
        DateTime.now().hour < 6;

    const double spacing = 240;
    const double nodeSize = 100;
    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;
    final totalHeight = levels.length * spacing + 240;
    final safeAmplitude = (screenW - nodeSize * 1.5) / 2 * 0.3;
    final double topPadding =
        kToolbarHeight + MediaQuery.of(context).padding.top + 16;

    final List<Color> gradientColors = isDark
        ? [const Color(0xFF1E1E2E), const Color(0xFF5E2CED), const Color(0xFFA58CFF)]
        : [const Color(0xFF5E2CED), const Color(0xFFA58CFF), const Color(0xFFFF8B00)];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white.withOpacity(0.05),
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(color: Colors.white.withOpacity(0.05)),
          ),
        ),
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF5E2CED), Color(0xFFFF8B00)],
          ).createShader(bounds),
          child: Text(
            "Vui Học Toán",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // 🌈 Gradient nền fintech
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(seconds: 2),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: gradientColors,
                ),
              ),
            ),
          ),

          // 💫 Các node level
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
                        final scale =
                        (1.1 - (distance / screenH)).clamp(0.8, 1.1);
                        final opacity = (1.2 - (distance / (screenH * 0.7)))
                            .clamp(0.4, 1.0);
                        final isCenter = distance < 50;

                        Widget node = GestureDetector(
                          onTap: () => _openLevel(levels[i]),
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 300),
                            opacity: opacity,
                            child: LevelNode(
                              level: levels[i],
                              onTap: () => _openLevel(levels[i]),
                              isCenter: isCenter,
                              isNight: isDark,
                            ),
                          ),
                        );

                        if (isCenter) {
                          node = Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF5E2CED).withOpacity(0.5),
                                  blurRadius: 40,
                                  spreadRadius: -10,
                                ),
                                BoxShadow(
                                  color: const Color(0xFFFF8B00).withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: -5,
                                ),
                              ],
                            ),
                            child:
                            ScaleTransition(scale: _bounceController, child: node),
                          );
                        }

                        final rawLeft = (screenW - nodeSize) / 2 +
                            sin(i * 0.8) * safeAmplitude -
                            40;
                        return Positioned(
                          top: levelTop,
                          left: rawLeft,
                          child: Transform.scale(scale: scale, child: node),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),

          // 🎉 Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              colors: const [
                Color(0xFF5E2CED),
                Color(0xFFA58CFF),
                Color(0xFFFF8B00),
                Colors.white,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
