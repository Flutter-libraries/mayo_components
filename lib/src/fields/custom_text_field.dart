import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

///
/// [CustomTextFormField.]
///
/// [@author	Unknown]
/// [ @since	v0.0.1 ]
/// [@version	v1.0.0	Wednesday, November 2nd, 2022]
/// [@see		StatelessWidget]
/// [@global]
///
class CustomTextFormField extends StatelessWidget {
  /// Constructor
  const CustomTextFormField({
    super.key,
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
    this.inputFormatters,
    this.fillColor = Colors.white,
  }) : assert(
          controller == null || initialValue == null,
          'Controller and initialValue are no compatibles',
        );

  ///
  /// [@var		final	TextInputType]
  ///
  final TextInputType? keyboardType;

  ///
  /// [@var		final	String]
  ///
  final String? title;

  ///
  /// [@var		final	String]
  ///
  final String hintText;

  ///
  /// [@var		final	double]
  ///
  final double separation;

  ///
  /// [@var		final	String]
  ///
  final String? errorText;

  ///
  /// [@var		final	TextEditingController]
  ///
  final TextEditingController? controller;

  ///
  /// [@var		final	String]
  ///
  final String? initialValue;

  ///
  /// [@var		final	FocusNode]
  ///
  final FocusNode? focusNode;

  ///
  /// [@var		final	bool]
  ///
  final bool enabled;

  ///
  /// [@var		mixed	autofillHints]
  ///
  final List<String>? autofillHints;

  ///
  /// [@var		final	String]
  ///
  final String? label;

  ///
  /// [@var		final	Color]
  ///
  final Color? fillColor;

  ///
  /// [@var		mixed	inputFormatters]
  ///
  final List<TextInputFormatter>? inputFormatters;

  ///
  /// [@var		mixed	onChanged]
  ///
  final void Function(String)? onChanged;

  ///
  /// [@var		mixed	onFieldSubmitted]
  ///
  final void Function(String)? onFieldSubmitted;

  ///
  /// [@var		mixed	onEditingComplete]
  ///
  final void Function()? onEditingComplete;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Text(title!, style: Theme.of(context).textTheme.bodyText2),
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
              inputFormatters: inputFormatters,
              style: Theme.of(context).textTheme.bodyText1,
              decoration: InputDecoration(
                labelText: label,
                errorText: errorText,
                hintText: hintText,
                fillColor: fillColor,
                filled: true,
                focusColor: Colors.red,
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[300],
                  fontWeight: FontWeight.w600,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Colors.black.withOpacity(0.1),
                  ),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Colors.black.withOpacity(0.1),
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Colors.black.withOpacity(0.1),
                  ),
                ),
                contentPadding:
                    const EdgeInsets.only(bottom: 16, left: 8, right: 8),
              ),
            )
          ],
        ),
      ],
    );
  }
}
