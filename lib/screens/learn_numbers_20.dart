import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class LearnNumbers20Screen extends StatefulWidget {
  const LearnNumbers20Screen({super.key});

  @override
  State<LearnNumbers20Screen> createState() => _LearnNumbers20ScreenState();
}

class _LearnNumbers20ScreenState extends State<LearnNumbers20Screen> {
  List<dynamic> numbers = [];
  int currentIndex = 0;
  final AudioPlayer _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _loadNumbers();
  }

  Future<void> _loadNumbers() async {
    final String response =
    await rootBundle.loadString('assets/configs/numbers_20.json');
    final data = await json.decode(response);
    setState(() {
      numbers = data["numbers"];
    });
  }

  void _next() {
    if (currentIndex < numbers.length - 1) {
      setState(() => currentIndex++);
    }
  }

  void _prev() {
    if (currentIndex > 0) {
      setState(() => currentIndex--);
    }
  }

  Future<void> _playAudio(String path) async {
    await _player.stop();
    await _player.play(AssetSource(path.replaceFirst('assets/', '')));
  }

  @override
  Widget build(BuildContext context) {
    if (numbers.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final item = numbers[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Làm quen số 11–20"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            item["value"].toString(),
            style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Image.asset(item["image"], width: 150, height: 150),
          const SizedBox(height: 20),
          Text(
            item["text"],
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.volume_up),
            label: const Text("Nghe đọc"),
            onPressed: () => _playAudio(item["audio"]),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, size: 40),
                onPressed: _prev,
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward, size: 40),
                onPressed: _next,
              ),
            ],
          ),
          const SizedBox(height: 40),

          // 🔥 Nút Hoàn thành
          ElevatedButton.icon(
            icon: const Icon(Icons.check_circle),
            label: const Text("Hoàn thành"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              textStyle: const TextStyle(fontSize: 20),
            ),
            onPressed: () {
              Navigator.pop(context, true); // báo về Map đã hoàn thành
            },
          ),
        ],
      ),
    );
  }
}
