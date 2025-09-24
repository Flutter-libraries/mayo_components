import 'package:flutter/material.dart';

class FilledCard extends StatelessWidget {
  const FilledCard({
    required this.child,
    this.clickable = false,
    this.width,
    this.height,
    this.padding = 24,
    this.radius = 8,
    this.color,
    super.key,
  });
  final Widget child;
  final bool clickable;
  final double? width;
  final double? height;
  final double padding;
  final double radius;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: clickable ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: Container(
        width: width,
        height: height,
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            radius,
          ),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          color: color ?? Theme.of(context).colorScheme.surfaceContainer,
        ),
        child: child,
      ),
    );
  }
}
