import 'package:flutter/material.dart';
import 'package:mayo_components/mayo_components.dart';
import 'package:quill_html_editor/quill_html_editor.dart';

class HtmlEditor extends StatefulWidget {
  const HtmlEditor({
    super.key,
    required this.initialValue,
    this.hintText,
    required this.enabled,
    this.onTextChanged,
    this.title,
    this.onFocusChanged,
  });

  final String initialValue;
  final bool enabled;
  final String? title;
  final String? hintText;
  final void Function(String text)? onTextChanged;
  final void Function(bool value)? onFocusChanged;

  @override
  State<HtmlEditor> createState() => _HtmlEditorState();
}

class _HtmlEditorState extends State<HtmlEditor> {
  final QuillEditorController controller = QuillEditorController();

  final customToolBarList = [
    ToolBarStyle.bold,
    ToolBarStyle.italic,
    ToolBarStyle.align,
    ToolBarStyle.color,
    ToolBarStyle.background,
    ToolBarStyle.listBullet,
    ToolBarStyle.listOrdered,
    ToolBarStyle.clean,
    ToolBarStyle.addTable,
    ToolBarStyle.editTable,
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        if (widget.title != null)
          Text(
            widget.title!,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        OutlinedCard(
          child: Column(
            children: [
              ToolBar(
                toolBarColor: Theme.of(context).colorScheme.surface,
                padding: const EdgeInsets.all(8),
                iconSize: 25,
                iconColor: Theme.of(context).colorScheme.onSurface,
                activeIconColor: Theme.of(context).colorScheme.primary,
                controller: controller,
                crossAxisAlignment: WrapCrossAlignment.start,
                direction: Axis.horizontal,
                customButtons: [
                  Container(
                    width: 25,
                    height: 25,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      var selectedText = await controller.getSelectedText();
                      debugPrint('selectedText $selectedText');
                      var selectedHtmlText =
                          await controller.getSelectedHtmlText();
                      debugPrint('selectedHtmlText $selectedHtmlText');
                    },
                    child: const Icon(
                      Icons.add_circle,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              SingleChildScrollView(
                child: QuillHtmlEditor(
                  hintText: widget.hintText,
                  controller: controller,
                  isEnabled: widget.enabled,
                  minHeight: 300,
                  ensureVisible: true,
                  textStyle: Theme.of(context).textTheme.bodyMedium,
                  hintTextStyle: Theme.of(context).textTheme.labelMedium,
                  hintTextAlign: TextAlign.start,
                  padding: const EdgeInsets.only(left: 10, top: 5),
                  hintTextPadding: EdgeInsets.zero,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  onFocusChanged: (hasFocus) =>
                      debugPrint('has focus $hasFocus'),
                  onTextChanged: (text) => widget.onTextChanged?.call(text),
                  onEditorCreated: () {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Future.delayed(
                        const Duration(milliseconds: 1000),
                        () => controller.setText(widget.initialValue),
                      );
                    });
                  },
                  onEditingComplete: (s) => debugPrint('Editing completed $s'),
                  onEditorResized: (height) =>
                      debugPrint('Editor resized $height'),
                  onSelectionChanged: (sel) =>
                      debugPrint('${sel.index},${sel.length}'),
                  loadingBuilder: (context) {
                    return const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 0.4,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
