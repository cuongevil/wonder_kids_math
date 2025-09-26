import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

import '../config/app_routes.dart';
import '../models/vn_letter.dart';
import '../widgets/letter_card.dart';
import '../services/audio_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<VnLetter> letters = [];
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadLetters();
  }

  Future<void> _loadLetters() async {
    final String response =
    await rootBundle.loadString('assets/config/letters.json');
    final List<dynamic> data = json.decode(response);
    setState(() {
      letters = data.map((e) => VnLetter.fromJson(e)).toList();
    });
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    AudioService.play("audio/ting.mp3");
  }

  @override
  Widget build(BuildContext context) {
    // chia thành từng nhóm 6 chữ cái
    final chunks = <List<VnLetter>>[];
    for (var i = 0; i < letters.length; i += 6) {
      chunks.add(
        letters.sublist(i, i + 6 > letters.length ? letters.length : i + 6),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
            "Chữ cái"),
        centerTitle: true,
        backgroundColor: Colors.pinkAccent.shade100,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB3E5FC), Color(0xFFF8BBD0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: chunks.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, pageIndex) {
                  return AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, child) {
                      double value = 1.0;
                      if (_pageController.position.haveDimensions) {
                        value = _pageController.page! - pageIndex;
                      }
                      final scale = (1 - value.abs() * 0.2).clamp(0.85, 1.0);
                      final rotation = value * 0.15;
                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..scale(scale)
                          ..rotateZ(rotation),
                        child: Opacity(
                          opacity: (1 - value.abs() * 0.5).clamp(0.5, 1.0),
                          child: child,
                        ),
                      );
                    },
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: chunks[pageIndex].length,
                      itemBuilder: (context, indexInChunk) {
                        final letter = chunks[pageIndex][indexInChunk];
                        final globalIndex = pageIndex * 6 + indexInChunk;

                        return LetterCard(
                          letter: letter,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.letter,
                              arguments: {
                                "letters": letters,
                                "currentIndex": globalIndex,
                              },
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            // Thanh chấm chỉ số trang
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(chunks.length, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 16 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? Colors.pinkAccent
                          : Colors.grey[400],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
