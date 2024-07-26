import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

const kMaxLines = 5;

///
class TextReadMore extends StatefulWidget {
  /// Constructor
  const TextReadMore({
    required this.text,
    required this.textStyle,
    required this.buttonText,
    this.buttonStyle,
    this.floating = false,
    this.maxLines = kMaxLines,
    this.clickable = true,
    super.key,
  });

  final String text;
  final TextStyle textStyle;
  final TextStyle? buttonStyle;
  final String buttonText;
  final int maxLines;
  final bool floating;
  final bool clickable;

  @override
  State<TextReadMore> createState() => _TextReadMoreState();
}

class _TextReadMoreState extends State<TextReadMore> {
  bool unread = true;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final span = TextSpan(
          text: widget.text,
          style: widget.textStyle,
        );
        final tp = TextPainter(text: span, textDirection: TextDirection.ltr)
          ..layout(maxWidth: constraints.maxWidth);
        final numLines = tp.computeLineMetrics().length;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      widget.text,
                      style: widget.textStyle,
                      maxLines: unread ? widget.maxLines : null,
                      overflow: unread
                          ? kIsWeb
                              ? TextOverflow.ellipsis
                              : TextOverflow.fade
                          : null,
                    ),
                  ),
                ),
                if (unread && numLines > widget.maxLines)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: widget.clickable
                        ? GestureDetector(
                            onTap: () {
                              setState(() {
                                unread = false;
                              });
                            },
                            child: Text(
                              widget.buttonText,
                              style: widget.buttonStyle,
                            ),
                          )
                        : Text(
                            widget.buttonText,
                            style: widget.buttonStyle,
                          ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}
