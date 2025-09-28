import 'package:flutter/material.dart';
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

class _MapScreenState extends State<MapScreen> {
  MapOrientation _orientation = MapOrientation.vertical;
  List<Level> levels = [];

  @override
  void initState() {
    super.initState();
    _init();
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
      await ProgressService.saveLevels(levels);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (levels.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()), // ⏳ loading
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
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEDE7F6), Color(0xFFF3E5F5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: isVertical ? _buildVertical() : _buildHorizontal(),
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

class _ConnectorPainter extends CustomPainter {
  final bool vertical;
  _ConnectorPainter({required this.vertical});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFFB39DDB)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    if (vertical) {
      final path = Path();
      path.moveTo(size.width / 2, 0);
      path.cubicTo(size.width / 2, size.height * 0.25, size.width / 2,
          size.height * 0.75, size.width / 2, size.height);
      canvas.drawPath(path, p);
    } else {
      final path = Path();
      path.moveTo(0, size.height / 2);
      path.cubicTo(size.width * 0.25, size.height / 2, size.width * 0.75,
          size.height / 2, size.width, size.height / 2);
      canvas.drawPath(path, p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
