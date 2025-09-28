import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:confetti/confetti.dart';

import '../models/level.dart';
import '../services/progress_service.dart';
import '../widgets/level_node.dart';
import 'level_detail.dart';

enum MapOrientation { vertical, horizontal }

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  MapOrientation _orientation = MapOrientation.vertical;
  List<Level> levels = [];

  late ConfettiController _confettiController;
  late AnimationController _mascotController;
  late Animation<double> _mascotAnimation;

  int mascotPosition = 0; // vị trí index hiện tại
  int targetPosition = 0; // vị trí index sẽ đi đến
  Path? _mascotPath;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _mascotController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _mascotAnimation = Tween<double>(begin: 0, end: 0).animate(CurvedAnimation(
      parent: _mascotController,
      curve: Curves.easeInOut,
    ));
    _init();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _mascotController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    final isVertical = await ProgressService.loadOrientation();
    _orientation = isVertical ? MapOrientation.vertical : MapOrientation.horizontal;

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
      Level(index: 1, title: '1. Làng Số 0–10 🍎', type: LevelType.topic, state: LevelState.playable, progress: 0.0, route: '/learn_numbers'),
      Level(index: 2, title: '2. Rừng Số 11–20 🌲', type: LevelType.topic, state: LevelState.locked, route: '/learn_numbers_20'),
      Level(index: 3, title: '3. Cầu Cộng ≤10 🌉', type: LevelType.topic, state: LevelState.locked, route: '/game_addition10'),
      Level(index: 4, title: '4. Hang Trừ ≤10 ⛰️', type: LevelType.topic, state: LevelState.locked, route: '/game_subtraction10'),
      Level(index: 5, title: '5. Đồng Bằng So Sánh ⚖️', type: LevelType.topic, state: LevelState.locked, route: '/game_compare'),
      Level(index: 6, title: '6. Sông Cộng ≤20 🌊', type: LevelType.topic, state: LevelState.locked, route: '/game_addition20'),
      Level(index: 7, title: '7. Sa Mạc Trừ ≤20 🏜️', type: LevelType.topic, state: LevelState.locked, route: '/game_subtraction20'),
      Level(index: 8, title: '8. Thành Phố Hình Học 🏙️', type: LevelType.topic, state: LevelState.locked, route: '/game_shapes'),
      Level(index: 9, title: '9. Thung Lũng Đo Lường & Thời Gian ⏰', type: LevelType.topic, state: LevelState.locked, route: '/game_measure_time'),
      Level(index: 10, title: '10. Lâu Đài Boss Cuối 🏰🐉', type: LevelType.boss, state: LevelState.locked, route: '/game_final_boss'),
      Level(index: 11, title: 'End 🌟', type: LevelType.end, state: LevelState.locked),
    ];
  }

  Future<void> _toggleOrientation() async {
    setState(() {
      _orientation = _orientation == MapOrientation.vertical
          ? MapOrientation.horizontal
          : MapOrientation.vertical;
    });
    await ProgressService.saveOrientation(_orientation == MapOrientation.vertical);
  }

  void _openLevel(Level lv) async {
    if (lv.route != null) {
      final result = await Navigator.pushNamed(context, lv.route!, arguments: lv.index);
      if (result == true) {
        _markCompleted(lv.index);
      }
    } else {
      final result = await Navigator.pushNamed(context, LevelDetail.routeName, arguments: lv.index);
      if (result == true) {
        _markCompleted(lv.index);
      }
    }
  }

  Future<void> _markCompleted(int idx) async {
    final i = levels.indexWhere((e) => e.index == idx);
    if (i != -1) {
      levels[i].state = LevelState.completed;
      levels[i].progress = 1.0;

      if (i + 1 < levels.length && levels[i + 1].state == LevelState.locked) {
        levels[i + 1].state = LevelState.playable;
        levels[i + 1].progress ??= 0.0;
      }

      // 🚀 Tính vị trí start & end
      final start = Offset(mascotPosition * 120.0, mascotPosition * 120.0);
      final end = Offset(i * 120.0, i * 120.0);
      _mascotPath = buildCurvePath(start, end, _orientation == MapOrientation.vertical);

      _mascotAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _mascotController,
        curve: Curves.easeInOut,
      ));

      _mascotController.forward(from: 0).whenComplete(() {
        mascotPosition = i;
      });

      _confettiController.play();
      await ProgressService.saveLevels(levels);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (levels.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isVertical = _orientation == MapOrientation.vertical;

    return Scaffold(
      appBar: AppBar(
        title: Text(isVertical ? 'Map Dọc (Mobile)' : 'Map Ngang'),
        actions: [
          IconButton(
            tooltip: isVertical ? 'Chuyển sang ngang' : 'Chuyển sang dọc',
            onPressed: _toggleOrientation,
            icon: Icon(isVertical ? Icons.swap_horiz : Icons.swap_vert),
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // 🌈 Background
          DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE1F5FE), Color(0xFFFFF9C4)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: isVertical ? _buildVertical() : _buildHorizontal(),
          ),

          // 🎉 Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [Colors.pink, Colors.blue, Colors.yellow, Colors.green],
            ),
          ),

          // 🐻 Mascot + Magic Stars
          if (_mascotPath != null)
            AnimatedBuilder(
              animation: _mascotAnimation,
              builder: (context, child) {
                final pos = positionAlongPath(_mascotPath!, _mascotAnimation.value);
                return Stack(
                  children: [
                    ...buildStarsAlongPath(_mascotPath!, _mascotAnimation.value),
                    Positioned(
                      left: 20 + pos.dx,
                      bottom: 40 + pos.dy,
                      child: SizedBox(
                        width: 80,
                        height: 80,
                        child: Lottie.asset('assets/images/mascot/mascot.png'),
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildVertical() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          for (var i = 0; i < levels.length; i++) ...[
            LevelNode(
              level: levels[i],
              onTap: () => _openLevel(levels[i]),
            ),
            if (i < levels.length - 1)
              SizedBox(
                height: 60,
                child: CustomPaint(
                  size: const Size(8, 60),
                  painter: _ConnectorPainter(vertical: true),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildHorizontal() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < levels.length; i++) ...[
            LevelNode(
              level: levels[i],
              onTap: () => _openLevel(levels[i]),
            ),
            if (i < levels.length - 1)
              SizedBox(
                width: 80,
                child: CustomPaint(
                  size: const Size(80, 8),
                  painter: _ConnectorPainter(vertical: false),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

/// --- MAGIC PATH HELPERS ---

Path buildCurvePath(Offset start, Offset end, bool vertical) {
  final path = Path()..moveTo(start.dx, start.dy);

  if (start == end) {
    // fix trường hợp path trống
    path.lineTo(end.dx + 0.01, end.dy);
    return path;
  }

  if (vertical) {
    // ⛰️ Bậc thang leo núi
    final midY = (start.dy + end.dy) / 2;
    path.lineTo(start.dx, midY);
    path.lineTo(end.dx, midY);
    path.lineTo(end.dx, end.dy);
  } else {
    // 🌈 Cầu vồng ngang
    final control1 = Offset((start.dx + end.dx) / 2, start.dy - 120);
    final control2 = Offset((start.dx + end.dx) / 2, end.dy - 120);
    path.cubicTo(control1.dx, control1.dy, control2.dx, control2.dy, end.dx, end.dy);
  }

  return path;
}

Offset positionAlongPath(Path path, double t) {
  final metrics = path.computeMetrics();
  if (metrics.isEmpty) return Offset.zero;

  final metric = metrics.first;
  final pos = metric.getTangentForOffset(metric.length * t);
  return pos?.position ?? Offset.zero;
}

List<Widget> buildStarsAlongPath(Path path, double progress) {
  final metrics = path.computeMetrics();
  if (metrics.isEmpty) return [];

  final metric = metrics.first;
  final length = metric.length;
  final stars = <Widget>[];

  for (int i = 0; i < 5; i++) {
    final t = progress - i * 0.1;
    if (t > 0) {
      final pos = metric.getTangentForOffset(length * t)?.position;
      if (pos != null) {
        stars.add(Positioned(
          left: 20 + pos.dx,
          bottom: 40 + pos.dy,
          child: Opacity(
            opacity: 1 - (progress - t),
            child: Icon(
              Icons.star,
              size: 16,
              color: Colors.yellowAccent.withOpacity(0.9),
            ),
          ),
        ));
      }
    }
  }
  return stars;
}

class _ConnectorPainter extends CustomPainter {
  final bool vertical;
  _ConnectorPainter({required this.vertical});

  @override
  void paint(Canvas canvas, Size size) {
    final gradient = LinearGradient(
      colors: [Colors.pinkAccent, Colors.blueAccent, Colors.yellowAccent],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final p = Paint()
      ..shader = gradient
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (vertical) {
      final path = Path();
      path.moveTo(size.width / 2, 0);
      path.lineTo(size.width / 2, size.height);
      canvas.drawPath(path, p);
    } else {
      final path = Path();
      path.moveTo(0, size.height / 2);
      path.lineTo(size.width, size.height / 2);
      canvas.drawPath(path, p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
