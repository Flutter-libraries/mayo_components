import 'package:flutter/material.dart';

class CustomTextArea extends StatelessWidget {
  final String hintText;
  final String? initialValue;
  final String? errorText;
  final Function(String) onChanged;
  const CustomTextArea(
      {Key? key,
      required this.hintText,
      this.errorText,
      required this.onChanged,
      this.initialValue})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: onChanged,
      initialValue: initialValue,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      style: const TextStyle(fontSize: 12),
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
              fontWeight: FontWeight.w600),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  BorderSide(width: 1, color: Colors.black.withOpacity(0.1))),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  BorderSide(width: 1, color: Colors.black.withOpacity(0.1))),
          contentPadding: const EdgeInsets.only(bottom: 16, left: 8, right: 8)),
    );
  }
}
