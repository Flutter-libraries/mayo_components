import 'package:flutter/material.dart';

class OutlinedCard extends StatelessWidget {
  const OutlinedCard({
    required this.child,
    super.key,
    this.clickable = false,
    this.width,
    this.height,
    this.padding = 24,
    this.radius = 8,
    this.borderColor,
  });
  final Widget child;
  final bool clickable;
  final double? width;
  final double? height;
  final double padding;
  final double radius;
  final Color? borderColor;

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
            color: borderColor ?? Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: child,
      ),
    );
  }
}
