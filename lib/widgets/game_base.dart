import 'package:flutter/material.dart';

/// Lớp cơ sở cho các game
abstract class GameBaseState<T extends StatefulWidget> extends State<T> {
  /// ID game (ví dụ: "game1")
  String get gameId;

  /// Tiêu đề game (hiển thị trên AppBar)
  String get title;

  /// Khi trả lời (đúng hoặc sai)
  /// - Không tăng round ở đây nữa (để game con tự xử lý)
  Future<void> onAnswer(bool correct) async {
    // Có thể ghi log, lưu tiến trình, gửi analytics... tại đây
  }

  /// Reset lại trạng thái game (override ở game con)
  void onReset();

  /// UI của game (override ở game con)
  Widget buildGame(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: onReset,
          ),
        ],
      ),
      body: buildGame(context),
    );
  }
}
