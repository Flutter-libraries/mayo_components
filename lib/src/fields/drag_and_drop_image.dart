import 'dart:developer';

import 'package:dotted_decoration/dotted_decoration.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:mayo_components/mayo_components.dart';

///
/// [DropImageInfo.]
///
/// [@author	Unknown]
/// [ @since	v0.0.1 ]
/// [@version	v1.0.0	Monday, November 7th, 2022]
/// [@global]
///
class DropImageInfo {
  ///
  DropImageInfo(
    this.url,
    this.data,
    this.mime,
    this.filename,
    this.size,
  ) : extension = filename.contains('.') ? filename.split('.')[1] : '';

  ///
  /// [@var		final	String]
  ///
  final String url;

  ///
  /// [@var		final	Uint8List]
  ///
  final Uint8List data;

  ///
  /// [@var		final	String]
  ///
  final String mime;

  ///
  /// [@var		final	String]
  ///
  final String filename;

  ///
  /// [@var		final	double]
  ///
  final int size;

  ///
  /// [@var		final	String]
  ///
  final String extension;

  ///
  /// [@var		final	String]
  ///
  String get fullFilename =>
      extension.isNotEmpty ? '$filename.$extension' : filename;

  ///
  bool get isImage => mime.startsWith('image/');
}

///
/// [DragAndDropImage.]
///
/// [@author	Unknown]
/// [ @since	v0.0.1 ]
/// [@version	v1.0.0	Monday, November 7th, 2022]
/// [@see		StatefulWidget]
/// [@global]
///
class DragAndDropImage extends StatefulWidget {
  ///
  const DragAndDropImage({
    required this.onHoverPreview,
    required this.onDeletePressed,
    required this.onDropViewLoaded,
    required this.onDropImage,
    required this.dropAreaContent,
    required this.previewAreaContent,
    this.width,
    this.height,
    this.imageUrl,
    this.onUpdateButtonPressed,
    this.onDropImages,
    this.multiple = false,
    this.acceptedMimeTypes,
    super.key,
  });

  ///
  /// [@var		final	String]
  ///
  final String? imageUrl;

  ///
  /// [@var		final	Widget]
  ///
  final Widget dropAreaContent;

  ///
  /// [@var		final	Widget]
  ///
  final Widget previewAreaContent;

  ///
  /// [@var		final	double]
  ///
  final double? width;

  ///
  /// [@var		final	double]
  ///
  final double? height;

  ///
  /// [final void Function(DropzoneViewController controller)
  /// onCreatedController;]
  ///
  /// [@var		mixed	onDropImage]
  ///
  final void Function(DropImageInfo dropImageInfo) onDropImage;

  ///
  ///
  final void Function(List<DropImageInfo> dropImageInfo)? onDropImages;

  ///
  /// [@var		mixed	onDropViewLoaded]
  ///
  final void Function()? onDropViewLoaded;

  ///
  /// [@var		mixed	onUpdateButtonPressed]
  ///
  final void Function()? onUpdateButtonPressed;

  ///
  /// [@var		mixed	onHover]
  ///
  final void Function(bool value) onHoverPreview;

  ///
  /// [@var		mixed	onDeletePressed]
  ///
  final void Function() onDeletePressed;

  ///
  ///
  final bool multiple;

  final List<String>? acceptedMimeTypes;

  @override
  State<DragAndDropImage> createState() => _DragAndDropImageState();
}

class _DragAndDropImageState extends State<DragAndDropImage> {
  late DropzoneViewController _controller;
  bool _isDragging = false;

  bool get hasImage => widget.imageUrl != null;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: _isDragging
          ? DottedDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: Shape.box,
              strokeWidth: 4,
            )
          : const BoxDecoration(),
      child: hasImage
          ? imagePreview(context, widget.imageUrl!)
          : dropZone(context, widget.key),
    );
  }

  Widget imagePreview(
    BuildContext context,
    String url,
  ) =>
      InkWell(
        onHover: widget.onHoverPreview,
        onTap: () => {},
        child: ColumnAutoLayout(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 8,
          children: [
            widget.previewAreaContent,
            OutlinedButton(
              onPressed: widget.onDeletePressed,
              child: const Text('Eliminar'),
            ),
          ],
        ),
      );

  Widget dropZone(BuildContext context, Key? key) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: DropzoneView(
            mime: widget.acceptedMimeTypes,
            key: key,
            operation: DragOperation.copy,
            cursor: CursorType.grab,
            onCreated: (controller) => _controller = controller,
            onLoaded: widget.onDropViewLoaded,
            onError: (String? ev) => log('Error: $ev'),
            onHover: () {
              setState(() => _isDragging = true);
              widget.onHoverPreview(true);
            },
            onLeave: () {
              setState(() => _isDragging = false);
              widget.onHoverPreview(false);
            },
            onDropFile: (event) async {
              widget.onDropImage(
                DropImageInfo(
                  await _controller.createFileUrl(event),
                  await _controller.getFileData(event),
                  await _controller.getFileMIME(event),
                  await _controller.getFilename(event),
                  await _controller.getFileSize(event),
                ),
              );
              setState(() => _isDragging = false);
            },
            onDropFiles: widget.multiple
                ? (event) async {
                    if (event == null) return;
                    widget.onDropImages?.call(
                      await Future.wait(
                        event.map(
                          (e) async => DropImageInfo(
                            await _controller.createFileUrl(e),
                            await _controller.getFileData(e),
                            await _controller.getFileMIME(e),
                            await _controller.getFilename(e),
                            await _controller.getFileSize(e),
                          ),
                        ),
                      ),
                    );

                    setState(() => _isDragging = false);
                  }
                : null,
          ),
        ),
        InkWell(
          onTap: () => _controller.pickFiles().then(
            (eventList) async {
              if (eventList.isNotEmpty) {
                widget.onDropImage(
                  DropImageInfo(
                    await _controller.createFileUrl(eventList.first),
                    await _controller.getFileData(eventList.first),
                    await _controller.getFileMIME(eventList.first),
                    await _controller.getFilename(eventList.first),
                    await _controller.getFileSize(eventList.first),
                  ),
                );
              }
            },
          ),
          child: widget.dropAreaContent,
        ),
      ],
    );
  }
}
