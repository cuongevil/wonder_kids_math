import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart'; // 👈 thêm import

import '../models/level.dart';
import '../services/progress_service.dart';
import '../widgets/level_node.dart';
import '../widgets/mascot_widget.dart';
import '../widgets/map_background.dart';
import '../widgets/sky_widget.dart';
import 'level_detail.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  List<Level> levels = [];

  late ConfettiController _confettiController;
  late AnimationController _mascotIdleController;
  late ScrollController _scrollController;

  late AudioPlayer _windPlayer;   // 🌬️ player cho tiếng gió
  late AudioPlayer _birdPlayer;   // 🐦 player cho tiếng chim

  int mascotPosition = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _mascotIdleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _windPlayer = AudioPlayer();
    _birdPlayer = AudioPlayer();

    _playBackgroundSounds(); // 👈 phát nhạc nền

    _init();
  }

  Future<void> _playBackgroundSounds() async {
    // 🌬️ Gió loop
    await _windPlayer.setReleaseMode(ReleaseMode.loop);
    await _windPlayer.play(AssetSource("audios/wind_breeze.mp3"), volume: 0.4);

    // 🐦 Chim loop
    await _birdPlayer.setReleaseMode(ReleaseMode.loop);
    await _birdPlayer.play(AssetSource("audios/birds_chirp.mp3"), volume: 0.6);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _confettiController.dispose();
    _mascotIdleController.dispose();
    _windPlayer.dispose();
    _birdPlayer.dispose();
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
      Level(index: 1, title: '1. Làng Số 0–10 🍎', type: LevelType.topic, state: LevelState.playable, route: '/learn_numbers'),
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

      if (i + 1 < levels.length && levels[i + 1].state == LevelState.locked) {
        levels[i + 1].state = LevelState.playable;
      }

      mascotPosition = i;
      _confettiController.play();
      _showRewardPopup();

      await ProgressService.saveLevels(levels);
      setState(() {});
    }
  }

  void _showRewardPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("🎁 Bé nhận được Sticker mới!",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Icon(Icons.emoji_emotions, size: 64, color: Colors.orange),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Yeah!"),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (levels.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Bé học toán ⛰️✨')),
      body: Stack(
        alignment: Alignment.center,
        children: [
          MapBackground(scrollController: _scrollController),
          SkyWidget(currentLevel: mascotPosition),
          _buildVertical(),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              colors: const [Colors.pink, Colors.blue, Colors.yellow, Colors.green],
            ),
          ),
          if (levels.isNotEmpty)
            AnimatedBuilder(
              animation: _mascotIdleController,
              builder: (context, child) {
                final bounce = 8 * _mascotIdleController.value;
                return Positioned(
                  left: MediaQuery.of(context).size.width / 2 - 30,
                  top: mascotPosition * 140.0 + bounce,
                  child: MascotWidget(position: Offset(0, 0)),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildVertical() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          for (var i = 0; i < levels.length; i++) ...[
            LevelNode(level: levels[i], onTap: () => _openLevel(levels[i])),
            if (i < levels.length - 1) const SizedBox(height: 60),
          ],
        ],
      ),
    );
  }
}
