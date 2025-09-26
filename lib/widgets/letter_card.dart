import 'package:flutter/material.dart';
import '../models/vn_letter.dart';
import '../utils/letter_colors.dart';
import 'wow_card.dart';

class LetterCard extends StatelessWidget {
  final VnLetter letter;
  final VoidCallback? onTap;

  const LetterCard({
    super.key,
    required this.letter,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = LetterColors.getGradient(letter.char);

    return WowCard(
      gradient: gradient,
      size: 140,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: letter.imagePath != null
            ? Image.asset(letter.imagePath!, fit: BoxFit.contain)
            : const Icon(Icons.image_not_supported, size: 64),
      ),
    );
  }
}
