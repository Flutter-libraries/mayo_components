import 'package:flutter/material.dart';

///
/// [CustomTextArea.]
///
/// [@author	Unknown]
/// [ @since	v0.0.1 ]
/// [@version	v1.0.0	Tuesday, November 22nd, 2022]
/// [@see		StatelessWidget]
/// [@global]
///
class CustomTextArea extends StatelessWidget {
  /// Constructor
  const CustomTextArea({
    super.key,
    required this.hintText,
    this.errorText,
    required this.onChanged,
    this.initialValue,
    this.autofocus = false,
  });

  ///
  /// [@var		final	String]
  ///
  final String hintText;

  ///
  /// [@var		final	String]
  ///
  final String? initialValue;

  ///
  /// [@var		final	String]
  ///
  final String? errorText;

  ///
  /// [@var		final	bool]
  ///
  final bool autofocus;

  ///
  /// [@var		mixed	onChanged]
  ///
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: onChanged,
      initialValue: initialValue,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      style: const TextStyle(fontSize: 12),
      autofocus: autofocus,
      minLines: 30,
      maxLines: null,
      decoration: InputDecoration(
        errorText: errorText,
        hintText: hintText,
        fillColor: Colors.white,
        filled: true,
        focusColor: Colors.red,
        hintStyle: TextStyle(
          fontSize: 14,
          color: Colors.grey[300],
          fontWeight: FontWeight.w600,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              BorderSide(width: 1, color: Colors.black.withOpacity(0.1)),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              BorderSide(width: 1, color: Colors.black.withOpacity(0.1)),
        ),
        contentPadding: const EdgeInsets.only(bottom: 16, left: 8, right: 8),
      ),
    );
  }
}
