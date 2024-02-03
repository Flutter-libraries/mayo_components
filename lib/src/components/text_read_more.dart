import 'package:flutter/material.dart';

const kMaxLines = 5;

///
class TextReadMore extends StatelessWidget {
  /// Constructor
  const TextReadMore({
    required this.text,
    required this.textStyle,
    required this.readMoreButton,
    required this.padding,
    this.maxLines = kMaxLines,
    super.key,
    this.unread = true,
  });

  final String text;
  final TextStyle textStyle;
  final Widget readMoreButton;
  final EdgeInsets padding;
  final int maxLines;
  final bool unread;

  @override
  Widget build(BuildContext context) {
    final span = TextSpan(
      text: text,
      style: textStyle,
    );
    final tp = TextPainter(text: span, textDirection: TextDirection.ltr)
      ..layout(maxWidth: MediaQuery.of(context).size.width - 64);
    final numLines = tp.computeLineMetrics().length;
    // final text = numLines > 5
    //     ? '${state.maker.shopDescription}\n\n'
    //     : state.maker.shopDescription;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            Text(
              text,
              style: textStyle,
              maxLines: unread ? maxLines : null,
              overflow: unread ? TextOverflow.fade : null,
            ),
            if (unread && numLines > maxLines) readMoreButton
          ],
        ),
      ],
    );
  }
}
