import 'package:example/media.dart';
import 'package:example/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:mayo_components/mayo_components.dart';

void main() {
  runApp(const MaterialApp(
    home: MainApp(),
    title: 'Example app',
  ));
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool unread = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Example app'),
      ),
      body: Column(
        children: [
          TextButton(
            child: const Text('Shimmer effect'),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ShimmerEffectPage(),
              ),
            ),
          ),
          TextButton(
            child: const Text('Media'),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MediaPage(),
              ),
            ),
          ),
          const Text('Read more widget'),
          const TextReadMore(
              text:
                  '''Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur porta odio sit amet nibh dictum condimentum. Suspendisse ipsum quam, iaculis at urna hendrerit, tincidunt laoreet enim. Duis rutrum lectus sit amet sollicitudin vestibulum. Nunc posuere sapien at orci euismod tempus. Aenean pharetra tincidunt lectus. Suspendisse efficitur leo ut turpis venenatis vehicula. Aenean ac condimentum ligula. Ut commodo justo lorem, at scelerisque lacus consequat eu. Integer quis tellus i''',
              textStyle: TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
              buttonText: 'Read more',
              maxLines: 5),
        ],
      ),
    );
  }
}
