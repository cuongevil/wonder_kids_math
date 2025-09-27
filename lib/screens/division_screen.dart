import 'package:flutter/material.dart';

class DivisionScreen extends StatelessWidget {
  const DivisionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Phép chia")),
      body: const Center(
        child: Text("Nội dung học Phép chia"),
      ),
    );
  }
}
