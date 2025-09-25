import 'package:flutter/material.dart';
import 'learn/learn_numbers.dart';
import 'games/game_addition.dart';
import 'games/game_subtraction.dart';
import 'games/game_multiplication.dart';
import 'games/game_division.dart';
import 'games/game_mix.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});
  @override State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> with TickerProviderStateMixin {
  late final TabController _tabController;
  @override void initState() { super.initState(); _tabController = TabController(length: 2, vsync: this); }
  @override void dispose() { _tabController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TabBar(controller: _tabController, tabs: const [Tab(text: "Học"), Tab(text: "Trò chơi")]),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                LearnNumbers(),
                ListView(children: [
                  ListTile(title: const Text("Game cộng"), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_)=> const GameAddition()))),
                  ListTile(title: const Text("Game trừ"), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_)=> const GameSubtraction()))),
                  ListTile(title: const Text("Game nhân"), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_)=> const GameMultiplication()))),
                  ListTile(title: const Text("Game chia"), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_)=> const GameDivision()))),
                  ListTile(title: const Text("Game tổng hợp"), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_)=> const GameMix()))),
                ]),
              ],
            ),
          )
        ],
      ),
    );
  }
}
