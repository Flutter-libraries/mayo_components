import 'package:example/shimmer.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    home: MainApp(),
    title: 'Example app',
  ));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Example app'),
      ),
      body: Center(
        child: TextButton(
          child: const Text('Shimmer effect'),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ShimmerEffectPage(),
            ),
          ),
        ),
      ),
    );
  }
}
