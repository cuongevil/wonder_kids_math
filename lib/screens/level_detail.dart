import 'package:flutter/material.dart';

class LevelDetail extends StatelessWidget {
  static const routeName = '/level_detail';

  const LevelDetail({super.key});

  @override
  Widget build(BuildContext context) {
    final int? levelIndex = ModalRoute.of(context)?.settings.arguments as int?;

    return Scaffold(
      appBar: AppBar(
        title: Text("Chi tiết Level ${levelIndex ?? ''}"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Đây là màn chơi số ${levelIndex ?? ''}",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              "Hiện chưa có game cụ thể.\nBạn có thể hoàn thành thủ công.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.check_circle),
              label: const Text("Hoàn thành"),
              onPressed: () {
                Navigator.pop(context, true); // báo Completed cho Map
              },
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              icon: const Icon(Icons.arrow_back),
              label: const Text("Quay lại"),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
          ],
        ),
      ),
    );
  }
}
