// 🗺️ MapScreen v9.0 — Halo Pulse Edition
// 💎 TPBank x Wonder Kids Fintech Premium — Halo xoay & nhịp tim, Glass blur, Parallax star, Mascot, Confetti

import 'dart:math';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/level.dart';
import '../services/progress_service.dart';
import '../themes/app_theme.dart';
import '../utils/route_observer.dart';
import '../widgets/level_node.dart';
import '../widgets/app_shell.dart';
import 'level_detail.dart';

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
  late AnimationController _gradientController;
  late AnimationController _haloRotateController;
  late AnimationController _haloPulseController;
  late AnimationController _mascotController;
  final AudioPlayer _player = AudioPlayer();

  bool _showMascot = false;
  double _lastOffset = 0;
  bool _isNavHidden = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
    _gradientController =
    AnimationController(vsync: this, duration: const Duration(seconds: 8))
      ..repeat();
    _haloRotateController =
    AnimationController(vsync: this, duration: const Duration(seconds: 6))
      ..repeat();
    _haloPulseController =
    AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);
    _mascotController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _init();

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
      setState(() {});
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
    _gradientController.dispose();
    _haloRotateController.dispose();
    _haloPulseController.dispose();
    _confettiController.dispose();
    _scrollController.dispose();
    _mascotController.dispose();
    super.dispose();
  }

  @override
  void didPopNext() => _refreshLevels();

  Future<void> _init() async {
    levels = await ProgressService.ensureDefaultLevels(_defaultLevels);
    for (var lv in levels) {
      if (lv.levelKey != null) {
        lv.stars = await ProgressService.getStars(lv.levelKey!);
        lv.total = await _getTotalForLevel(lv.levelKey!);
      }
    }
    setState(() {});
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
    };
    return totals[key] ?? 0;
  }

  List<Level> _defaultLevels() => ProgressService.defaultLevels();

  void _openLevel(Level lv) async {
    if (lv.state == LevelState.locked) return;
    HapticFeedback.lightImpact();
    await _player.play(AssetSource('sounds/select.mp3'));

    if (lv.route != null && lv.route!.isNotEmpty) {
      await Navigator.pushNamed(context, lv.route!);
      await _refreshLevels();
      _showReward();
      return;
    }

    await Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, anim, __) => FadeTransition(
          opacity: anim,
          child: AppShell(child: LevelDetail(key: ValueKey(lv.levelKey))),
        ),
      ),
    );

    await _refreshLevels();
    _showReward();
  }

  void _showReward() async {
    _confettiController.play();
    await _player.play(AssetSource('sounds/success.mp3'));
    setState(() => _showMascot = true);
    _mascotController.forward(from: 0);
    await Future.delayed(const Duration(seconds: 3));
    setState(() => _showMascot = false);
  }

  @override
  Widget build(BuildContext context) {
    if (levels.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    const spacing = 240.0;
    const nodeSize = 100.0;
    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;
    final totalHeight = levels.length * spacing + 240;
    final safeAmplitude = (screenW - nodeSize * 1.5) / 2 * 0.3;
    final topPadding =
        kToolbarHeight + MediaQuery.of(context).padding.top + 16;

    return Scaffold(
      body: Stack(
        children: [
          AnimatedFintechBackground(),
          Positioned.fill(
            child: ParallaxStarfield(
              scrollController: _scrollController,
              layerDepth: 0.3,
            ),
          ),

          // 🌌 Scrollable content
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
                      final scale = (1.1 - (distance / screenH)).clamp(0.8, 1.1);
                      final opacity =
                      (1.2 - (distance / (screenH * 0.7))).clamp(0.3, 1.0);
                      final isCenter = distance < 60;

                      Widget node = GestureDetector(
                        onTap: () => _openLevel(levels[i]),
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: opacity,
                          child: LevelNode(
                            level: levels[i],
                            onTap: () => _openLevel(levels[i]),
                            isCenter: isCenter,
                            isNight: true,
                          ),
                        ),
                      );

                      if (isCenter) {
                        node = Stack(
                          alignment: Alignment.center,
                          children: [
                            // 🌈 Halo Energy xoay + pulse
                            AnimatedBuilder(
                              animation: Listenable.merge(
                                  [_haloRotateController, _haloPulseController]),
                              builder: (_, __) {
                                final rotation =
                                    _haloRotateController.value * 2 * pi;
                                final pulse = 0.9 +
                                    sin(_haloPulseController.value * 2 * pi) *
                                        0.15;
                                return Transform.rotate(
                                  angle: rotation,
                                  child: Transform.scale(
                                    scale: pulse,
                                    child: Container(
                                      width: 160,
                                      height: 160,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: SweepGradient(
                                          colors: const [
                                            Color(0xFFFF8B00),
                                            Color(0xFF5E2CED),
                                            Color(0xFFFF8B00),
                                          ],
                                          stops: const [0.0, 0.5, 1.0],
                                          transform:
                                          GradientRotation(rotation),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF5E2CED)
                                                .withOpacity(0.3),
                                            blurRadius: 40,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),

                            // 🧊 Glass blur + glow node
                            ClipRRect(
                              borderRadius: BorderRadius.circular(60),
                              child: BackdropFilter(
                                filter:
                                ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(60),
                                    border: Border.all(
                                      color: const Color(0xFFFF8B00)
                                          .withOpacity(0.4),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF5E2CED)
                                            .withOpacity(0.4),
                                        blurRadius: 30,
                                        spreadRadius: -5,
                                      ),
                                    ],
                                  ),
                                  child: ScaleTransition(
                                    scale:
                                    Tween(begin: 0.95, end: 1.05).animate(
                                      CurvedAnimation(
                                        parent: _gradientController,
                                        curve: Curves.easeInOut,
                                      ),
                                    ),
                                    child: node,
                                  ),
                                ),
                              ),
                            ),
                          ],
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
                    }),
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
                Color(0xFF5E2CED),
                Color(0xFFA58CFF),
                Color(0xFFFF8B00),
                Colors.white,
              ],
            ),
          ),

          if (_showMascot) WowMascotLayer(animation: _mascotController),
        ],
      ),
    );
  }
}

/// 💜 Nền gradient động Fintech
class AnimatedFintechBackground extends StatefulWidget {
  @override
  State<AnimatedFintechBackground> createState() =>
      _AnimatedFintechBackgroundState();
}

class _AnimatedFintechBackgroundState extends State<AnimatedFintechBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller =
    AnimationController(vsync: this, duration: const Duration(seconds: 8))
      ..repeat(reverse: true);
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
      builder: (_, __) {
        final t = _controller.value;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.lerp(const Color(0xFF5E2CED), const Color(0xFFFF8B00), t)!,
                Color.lerp(const Color(0xFF2B0C69), const Color(0xFF5E2CED), 1 - t)!,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        );
      },
    );
  }
}

/// 🌌 Parallax Starfield — di chuyển ngược hướng scroll
class ParallaxStarfield extends StatefulWidget {
  final ScrollController scrollController;
  final double layerDepth;
  const ParallaxStarfield(
      {super.key, required this.scrollController, this.layerDepth = 0.3});

  @override
  State<ParallaxStarfield> createState() => _ParallaxStarfieldState();
}

class _ParallaxStarfieldState extends State<ParallaxStarfield>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _rand = Random();
  late List<Offset> _stars;

  @override
  void initState() {
    super.initState();
    _controller =
    AnimationController(vsync: this, duration: const Duration(seconds: 20))
      ..repeat();
    _stars = List.generate(120, (_) {
      return Offset(_rand.nextDouble(), _rand.nextDouble());
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final offset = widget.scrollController.hasClients
        ? widget.scrollController.offset * widget.layerDepth
        : 0.0;
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return CustomPaint(
          painter: _StarPainter(_stars, _controller.value, size, offset),
        );
      },
    );
  }
}

class _StarPainter extends CustomPainter {
  final List<Offset> stars;
  final double progress;
  final Size size;
  final double offset;
  _StarPainter(this.stars, this.progress, this.size, this.offset);

  @override
  void paint(Canvas canvas, Size _) {
    canvas.translate(0, -offset);
    final paint = Paint()..color = Colors.white.withOpacity(0.8);
    for (final s in stars) {
      final dx = (s.dx * size.width +
          sin(progress * 2 * pi + s.dy * 5) * 10) % size.width;
      final dy = (s.dy * size.height +
          cos(progress * 2 * pi + s.dx * 5) * 10) % size.height;
      canvas.drawCircle(Offset(dx, dy), 1.2, paint);
    }
  }

  @override
  bool shouldRepaint(_) => true;
}

/// 🧸 Linh vật bay qua màn hình
class WowMascotLayer extends StatelessWidget {
  final AnimationController animation;
  const WowMascotLayer({super.key, required this.animation});

  @override
  Widget build(BuildContext context) {
    final tween = Tween<Offset>(
      begin: const Offset(-1.5, -0.2),
      end: const Offset(1.5, -0.3),
    ).chain(CurveTween(curve: Curves.easeInOutCubic));

    final opacity = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: animation, curve: const Interval(0.1, 0.8)));

    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) {
        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(
            opacity: opacity,
            child: Align(
              alignment: Alignment.topCenter,
              child: Image.asset('assets/images/wow_mascot.png', height: 160),
            ),
          ),
        );
      },
    );
  }
}
