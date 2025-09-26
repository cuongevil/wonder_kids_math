import 'dart:math';
import 'package:flutter/material.dart';
import '../models/vn_letter.dart';

class OptionsGrid extends StatelessWidget {
  final List<VnLetter> options;
  final VnLetter? selected;
  final bool isCorrect;
  final void Function(VnLetter) onTap;

  const OptionsGrid({
    super.key,
    required this.options,
    required this.selected,
    required this.isCorrect,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pastelColors = [
      [Colors.pinkAccent, Colors.pink.shade100],
      [Colors.lightBlueAccent, Colors.blue.shade100],
      [Colors.lightGreen, Colors.green.shade100],
      [Colors.orangeAccent, Colors.orange.shade100],
      [Colors.purpleAccent, Colors.purple.shade100],
    ];

    return GridView.count(
      crossAxisCount: 3,
      padding: const EdgeInsets.all(16),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: options.map((letter) {
        final isSelected = selected == letter;
        final correctChoice = isSelected && isCorrect;
        final wrongChoice = isSelected && !isCorrect;

        final gradient = correctChoice
            ? [Colors.green, Colors.lightGreenAccent]
            : wrongChoice
            ? [Colors.red, Colors.redAccent]
            : pastelColors[Random().nextInt(pastelColors.length)];

        return GestureDetector(
          onTap: selected == null ? () => onTap(letter) : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(2, 2),
                )
              ],
            ),
            child: Text(letter.char,
                style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ),
        );
      }).toList(),
    );
  }
}
