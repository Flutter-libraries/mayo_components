import 'package:flutter/material.dart';
import 'package:mayo_components/mayo_components.dart';

class ShimmerEffectPage extends StatefulWidget {
  const ShimmerEffectPage({super.key});

  @override
  State<ShimmerEffectPage> createState() => _ShimmerEffectPageState();
}

class _ShimmerEffectPageState extends State<ShimmerEffectPage> {
  bool _isLoading = true;

  void _toggleLoading() {
    setState(() {
      _isLoading = !_isLoading;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Shimmer effect'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _toggleLoading,
          child: Icon(
            _isLoading ? Icons.hourglass_full : Icons.hourglass_bottom,
          ),
        ),
        body: Shimmer(
            child: ListView(
          children: [
            _buildTopRowItem(),
            _buildListItem(),
          ],
        )));
  }

  Widget _buildTopRowItem() {
    return ShimmerLoading(
      isLoading: _isLoading,
      child: SizedBox(
        height: 72,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: _isLoading
              ? const [
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      child: ShimmerCircle(size: 54)),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      child: ShimmerCircle(size: 54)),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      child: ShimmerCircle(size: 54)),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      child: ShimmerCircle(size: 54)),
                ]
              : const [
                  CircleListItem(),
                  CircleListItem(),
                  CircleListItem(),
                  CircleListItem(),
                ],
        ),
      ),
    );
  }

  Widget _buildListItem() {
    return ShimmerLoading(
      isLoading: _isLoading,
      child: CardListItem(
        isLoading: _isLoading,
      ),
    );
  }
}

class CircleListItem extends StatelessWidget {
  const CircleListItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Container(
        width: 54,
        height: 54,
        decoration: const BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
        ),
        child: ClipOval(
          child: Image.network(
            'https://docs.flutter.dev/cookbook'
            '/img-files/effects/split-check/Avatar1.jpg',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class CardListItem extends StatelessWidget {
  const CardListItem({
    super.key,
    required this.isLoading,
  });

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isLoading
              ? const ShimmerRectangle(width: double.infinity, height: 200)
              : _buildImage(),
          const SizedBox(height: 16),
          _buildText(),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            'https://docs.flutter.dev/cookbook'
            '/img-files/effects/split-check/Food1.jpg',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildText() {
    if (isLoading) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerRectangle(
            width: double.infinity,
            height: 24,
          ),
          SizedBox(height: 16),
          ShimmerRectangle(
            width: 250,
            height: 24,
          ),
        ],
      );
    } else {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do '
          'eiusmod tempor incididunt ut labore et dolore magna aliqua.',
        ),
      );
    }
  }
}