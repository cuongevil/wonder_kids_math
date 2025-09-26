import 'package:flutter/material.dart';
import '../models/vn_letter.dart';

class ImageColumn extends StatelessWidget {
  final List<ImageItem> items;
  final void Function(VnLetter) onTap;

  const ImageColumn({super.key, required this.items, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: items.map((item) {
        Color bg = Colors.white;
        if (item.isWrong) {
          bg = Colors.red.shade200;
        } else if (item.isSelected) {
          bg = Colors.green.shade200;
        }

        return GestureDetector(
          onTap: () => onTap(item.letter),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            height: 90,  // 🔥 đồng bộ với LetterColumn
            width: 90,
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
            child: item.image != null
                ? Image.asset(
              item.image!,
              fit: BoxFit.contain, // 🔥 ảnh co gọn trong khung
            )
                : const Icon(Icons.image, size: 40),
          ),
        );
      }).toList(),
    );
  }
}

/// Helper để truyền dữ liệu render
class ImageItem {
  final VnLetter letter;
  final String? image;
  final bool isSelected;
  final bool isWrong;

  ImageItem({
    required this.letter,
    this.image,
    this.isSelected = false,
    this.isWrong = false,
  });
}
