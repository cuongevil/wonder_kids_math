import 'package:flutter/material.dart';
import '../models/vn_letter.dart';

class LetterColumn extends StatelessWidget {
  final List<LetterItem> items;
  final void Function(VnLetter) onTap;

  const LetterColumn({super.key, required this.items, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: items.map((item) {
        Color bg = Colors.white;
        if (item.isWrong) {
          bg = Colors.red.shade200;
        } else if (item.isSelected) {
          bg = Colors.blue.shade200;
        }

        return GestureDetector(
          onTap: () => onTap(item.letter),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            height: 90,  // 🔥 Chiều cao cố định
            width: 90,   // 🔥 Chiều rộng cố định
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(2, 2),
                )
              ],
            ),
            child: Text(
              item.letter.char,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Helper để truyền dữ liệu render
class LetterItem {
  final VnLetter letter;
  final bool isSelected;
  final bool isWrong;

  LetterItem({
    required this.letter,
    this.isSelected = false,
    this.isWrong = false,
  });
}
