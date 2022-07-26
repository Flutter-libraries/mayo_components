import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final TextInputType? keyboardType;
  final String? title;
  final String hintText;
  final double separation;
  final String? errorText;
  final TextEditingController? controller;
  final String? initialValue;
  final FocusNode? focusNode;
  final bool enabled;
  final List<String>? autofillHints;
  final String? label;

  final Function(String)? onChanged;
  final Function(String)? onFieldSubmitted;
  final Function()? onEditingComplete;

  const CustomTextFormField({
    Key? key,
    this.keyboardType,
    this.title,
    this.separation = 8,
    this.hintText = '',
    this.onChanged,
    this.errorText,
    this.onFieldSubmitted,
    this.onEditingComplete,
    this.controller,
    this.focusNode,
    this.initialValue,
    this.enabled = true,
    this.autofillHints,
    this.label,
  })  : assert(controller == null || initialValue == null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Text(title!, style: Theme.of(context).textTheme.headline6),
        SizedBox(height: title != null ? separation : 0),
        Stack(
          children: [
            Container(height: 36),
            TextFormField(
              autofillHints: autofillHints,
              enabled: enabled,
              initialValue: initialValue,
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              onFieldSubmitted: onFieldSubmitted,
              onEditingComplete: onEditingComplete,
              keyboardType: keyboardType,
              textAlignVertical: TextAlignVertical.center,
              obscureText: keyboardType == TextInputType.visiblePassword,
              style: Theme.of(context).textTheme.headline3!.copyWith(
                  fontSize: 14,
                  color: enabled ? null : Theme.of(context).primaryColor,
                  fontWeight: enabled ? null : FontWeight.w500),
              decoration: InputDecoration(
                  labelText: label,
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
                      borderSide: BorderSide(
                          width: 1, color: Colors.black.withOpacity(0.1))),
                  disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                          width: 1, color: Colors.black.withOpacity(0.1))),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                          width: 1, color: Colors.black.withOpacity(0.1))),
                  contentPadding:
                      const EdgeInsets.only(bottom: 16, left: 8, right: 8)),
            )
          ],
        ),
      ],
    );
  }
}
