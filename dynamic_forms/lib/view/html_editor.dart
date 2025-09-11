import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart' as html_editor;

class HtmlEditor extends StatefulWidget {
  const HtmlEditor({
    super.key,
    required this.initialValue,
    required this.height,
    this.hintText,
    required this.enabled,
    this.onTextChanged,
    this.title,
    this.onFocusChanged,
    this.customButtons = const [],
    this.onSelectionChanged,
    required this.controller,
  });

  final String initialValue;
  final bool enabled;
  final String? title;
  final String? hintText;
  final double height;
  final void Function(String text)? onTextChanged;
  final void Function(bool value)? onFocusChanged;

  final List<Widget> customButtons;
  final void Function(int index, int length)? onSelectionChanged;
  final html_editor.HtmlEditorController controller;

  @override
  State<HtmlEditor> createState() => _HtmlEditorState();
}

class _HtmlEditorState extends State<HtmlEditor> {
  @override
  void initState() {
    super.initState();
    // La inicialización del texto se maneja en el callback onInit
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        if (widget.title != null)
          Text(widget.title!, style: Theme.of(context).textTheme.titleMedium),
        html_editor.HtmlEditor(
          controller: widget.controller,
          htmlEditorOptions: html_editor.HtmlEditorOptions(
            hint: widget.hintText ?? 'Escribe aquí...',
            shouldEnsureVisible: true,
            autoAdjustHeight: true,
            //initialText: "<p>text content initial, if any</p>",
          ),
          htmlToolbarOptions: html_editor.HtmlToolbarOptions(
            toolbarPosition:
                html_editor.ToolbarPosition.aboveEditor, //by default
            toolbarType: html_editor.ToolbarType.nativeScrollable, //by default
            customToolbarButtons: widget.customButtons,
            customToolbarInsertionIndices: widget.customButtons.isNotEmpty
                ? List.generate(widget.customButtons.length, (index) => index)
                : [],
            onButtonPressed:
                (
                  html_editor.ButtonType type,
                  bool? status,
                  Function? updateStatus,
                ) {
                  debugPrint(
                    "button '${type.name}' pressed, the current selected status is $status",
                  );
                  return true;
                },
            onDropdownChanged:
                (
                  html_editor.DropdownType type,
                  dynamic changed,
                  Function(dynamic)? updateSelectedItem,
                ) {
                  debugPrint("dropdown '${type.name}' changed to $changed");
                  return true;
                },
            mediaLinkInsertInterceptor:
                (String url, html_editor.InsertFileType type) {
                  debugPrint(url);
                  return true;
                },
          ),
          otherOptions: html_editor.OtherOptions(height: widget.height),
          callbacks: html_editor.Callbacks(
            onBeforeCommand: (String? currentHtml) {
              debugPrint('html before change is $currentHtml');
            },
            onChangeContent: (String? changed) {
              debugPrint('content changed to $changed');
              widget.onTextChanged?.call(changed ?? '');
            },
            onChangeCodeview: (String? changed) {
              debugPrint('code changed to $changed');
              widget.onTextChanged?.call(changed ?? '');
            },
            onChangeSelection: (html_editor.EditorSettings settings) {
              debugPrint('parent element is ${settings.parentElement}');
              debugPrint('font name is ${settings.fontName}');
              // Simular selectionChanged si tenemos el callback
              widget.onSelectionChanged?.call(0, 0); // Valores por defecto
            },
            onDialogShown: () {
              debugPrint('dialog shown');
            },
            onEnter: () {
              debugPrint('enter/return pressed');
            },
            onFocus: () {
              debugPrint('editor focused');
              widget.onFocusChanged?.call(true);
            },
            onBlur: () {
              debugPrint('editor unfocused');
              widget.onFocusChanged?.call(false);
            },
            onBlurCodeview: () {
              debugPrint('codeview either focused or unfocused');
            },
            onInit: () {
              debugPrint('init');
              // Establecer el valor inicial cuando el editor esté listo
              if (widget.initialValue.isNotEmpty) {
                Future.delayed(const Duration(milliseconds: 500), () {
                  widget.controller.setText(widget.initialValue);
                });
              }
            },
            onKeyDown: (int? keyCode) {
              debugPrint('$keyCode key downed');
              debugPrint(
                'current character count: ${widget.controller.characterCount}',
              );
            },
            onKeyUp: (int? keyCode) {
              debugPrint('$keyCode key released');
            },
            onMouseDown: () {
              debugPrint('mouse downed');
            },
            onMouseUp: () {
              debugPrint('mouse released');
            },
            onNavigationRequestMobile: (String url) {
              debugPrint(url);
              return html_editor.NavigationActionPolicy.ALLOW;
            },
            onPaste: () {
              debugPrint('pasted into editor');
            },
            onScroll: () {
              debugPrint('editor scrolled');
            },
          ),
        ),
      ],
    );
  }
}
