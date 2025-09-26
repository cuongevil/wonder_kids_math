import 'dart:math';

import 'package:flutter/material.dart';

import '../config/app_routes.dart';
import '../services/game_registry.dart';
import '../services/learning_registry.dart';
import '../services/progress_service.dart';
import '../widgets/game_card.dart';
import '../widgets/learning_button.dart';
import '../widgets/mascot_widget.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB3E5FC), Color(0xFFF8BBD0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 8),
              const MascotWidget(),
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.purple, Colors.pink],
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.deepPurple,
                  tabs: const [
                    Tab(icon: Icon(Icons.menu_book, size: 28), text: "Học"),
                    Tab(
                      icon: Icon(Icons.videogame_asset, size: 28),
                      text: "Trò chơi",
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [_buildLearnTab(context), _buildGameTab(context)],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 📚 Tab Học
  Widget _buildLearnTab(BuildContext context) {
    final learnings = LearningRegistry.getLearnings();
    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: learnings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, i) {
        final l = learnings[i];
        return FutureBuilder<double>(
          future: ProgressService.getProgress(l.id, l.total),
          builder: (context, snapshot) {
            final progress = snapshot.data ?? 0.0;
            return LearningButton(
              title: l.title,
              icon: l.icon,
              gradient: l.gradient,
              onTap: () async {
                if (l.route == AppRoutes.write) {
                  // 🔹 Load danh sách chữ cái từ JSON
                  final letters = await LearningRegistry.loadLetters();
                  if (letters.isEmpty) return;

                  // 🔹 Random 1 chữ
                  final randomIndex = Random().nextInt(letters.length);

                  Navigator.pushNamed(
                    context,
                    AppRoutes.write,
                    arguments: {'letters': letters, 'startIndex': randomIndex},
                  );
                } else if (l.route == AppRoutes.home ||
                    l.route == AppRoutes.flashcard) {
                  // 🔹 Các màn khác: vẫn push route bình thường
                  Navigator.pushNamed(context, l.route);
                }
              },
            );
          },
        );
      },
    );
  }

  // 🎮 Tab Trò chơi
  Widget _buildGameTab(BuildContext context) {
    final games = GameRegistry.getGames();
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: games.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemBuilder: (context, i) {
        final g = games[i];
        return FutureBuilder<double>(
          future: ProgressService.getProgress(g.id, g.total),
          builder: (context, snapshot) {
            final progress = snapshot.data ?? 0.0;
            return GameCard(
              gameId: g.id,
              title: g.title,
              icon: g.icon,
              color: g.color,
              onTap: () => Navigator.pushNamed(context, g.route),
            );
          },
        );
      },
    );
  }
}
