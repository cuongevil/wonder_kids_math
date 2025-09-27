import 'package:flutter/material.dart';

class AdditionScreen extends StatelessWidget {
  const AdditionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Phép cộng")),
      body: const Center(
        child: Text("Nội dung học Phép cộng"),
      ),
    );
  }
}
