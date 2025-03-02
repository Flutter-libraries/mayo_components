import 'package:flutter/material.dart';

/// A dialog that displays an image in full screen mode with interactive capabilities.
///
/// The [FullScreenImage] widget is a stateless widget that takes a [Widget] image
/// as a required parameter and displays it in an [InteractiveViewer] to allow for
/// panning and zooming.
///
/// Example usage:
/// ```dart
/// showDialog(
///   context: context,
///   builder: (BuildContext context) {
///     return FullScreenImage(
///       image: Image.network('https://example.com/image.jpg'),
///     );
///   },
/// );
/// ```
///
/// The [InteractiveViewer] widget is used to provide interactive features such as
/// panning and zooming. The image is centered within the dialog.
class FullScreenImage extends StatelessWidget {
  /// Creates a [FullScreenImage] widget.
  ///
  /// The [image] parameter must not be null.
  const FullScreenImage({
    required this.image,
    super.key,
  });

  /// The image to be displayed in full screen mode.
  final Widget image;

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      // clipBehavior: Clip.none,
      // panEnabled: false,
      // scaleEnabled: false,
      child: Center(
        child: image,
      ),
    );
  }
}