import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/level.dart';
import '../services/progress_service.dart';
import '../utils/route_observer.dart';
import '../widgets/app_shell.dart';
import '../widgets/level_node.dart';
import '../themes/app_theme.dart';
import 'level_detail.dart';

/// 🗺️ MapScreen 2025 v2 — Hiệu ứng Fintech + Mở route học thật
class MapScreen extends StatefulWidget {
  final ValueChanged<bool>? onScrollDirectionChanged;

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
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
      lowerBound: 0.95,
      upperBound: 1.05,
    )..repeat(reverse: true);

    _init();

    // 👇 Lắng nghe cuộn để ẩn / hiện BottomNavBar mượt
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
          final targetOffset = firstPlayableIndex * spacing - screenH / 2 + spacing / 2 + topPadding;
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

  List<Level> _defaultLevels() => ProgressService.defaultLevels();

  /// 🧭 Mở màn học hoặc LevelDetail tùy theo route
  void _openLevel(Level lv) async {
    if (lv.state == LevelState.locked) return;
    HapticFeedback.lightImpact();

    // ✅ Nếu có route cụ thể → mở màn học
    if (lv.route != null && lv.route!.isNotEmpty) {
      await Navigator.pushNamed(context, lv.route!);
      await _refreshLevels();
      _confettiController.play();
      return;
    }

    // ✅ Nếu chưa có route → mở màn chi tiết (LevelDetail)
    await Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, anim, __) => FadeTransition(
          opacity: anim,
          child: AppShell(
            child: LevelDetail(key: ValueKey(lv.levelKey)),
          ),
        ),
      ),
    );

    await _refreshLevels();
    _confettiController.play();
  }

  @override
  Widget build(BuildContext context) {
    if (levels.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isDark =
        Theme.of(context).brightness == Brightness.dark ||
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

    return Scaffold(
      backgroundColor: AppTheme.tpDarkBg,
      body: Stack(
        children: [
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
                        final scale = (1.1 - (distance / screenH)).clamp(0.8, 1.1);
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
                            child: ScaleTransition(
                              scale: _bounceController,
                              child: node,
                            ),
                          );
                        }

                        final rawLeft =
                            (screenW - nodeSize) / 2 +
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
