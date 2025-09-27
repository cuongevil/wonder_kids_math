import 'package:flutter/material.dart';

class MultiplicationScreen extends StatelessWidget {
  const MultiplicationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Phép nhân")),
      body: const Center(
        child: Text("Nội dung học Phép nhân"),
      ),
    );
  }
}
