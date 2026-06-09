import 'package:flutter/material.dart';

class ComingPage extends StatelessWidget {
  const ComingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Coming Soon")),
      body: const Center(child: Text("More Services Coming Soon")),
    );
  }
}