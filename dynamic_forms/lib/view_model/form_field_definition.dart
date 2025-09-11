import 'package:flutter/material.dart';

// Validation Callback
typedef ValidationCallback =
    String? Function(
      BuildContext context, {
      String? value,
      String? errorLabel,
      bool isRequired,
    });

typedef FormatterCallback<T> = String? Function(T? value);

class DropdownOption {
  DropdownOption({
    required this.label,
    required this.value,
    this.color,
    this.backgroundColor,
  });
  final String label;
  final String value;
  final Color? color;
  final Color? backgroundColor;
}

enum FieldType {
  text,
  number,
  toggle,
  checkbox,
  dropdown,
  dropdownMultiple,
  password,
  textarea,
  date,
  dateRange,
  time,
  html,
}

enum ValidationType {
  email,
  password,
  phone,
  name,
  address,
  currency,
  double,
  int,
  date,
  percentage,
}

class FormFieldDefinition {
  FormFieldDefinition({
    required this.fieldName,
    required this.label,
    this.isEditable = true,
    this.isRequired = false,
    this.isListable = true,
    this.rowFlex,
    this.validator,
    this.fieldType = FieldType.text,
    this.textAreaRows = 1,
    this.errorLabel,
    this.description,
    this.options = const [],
    this.prefixIcon,
    this.sectionGroup = 0,

    this.color,
    this.backgroundColor,
    this.rowColumn = false,
    this.previewKey,
    this.formatter,
  });
  final String fieldName;
  final String label;
  final String? errorLabel;
  final String? description;
  final bool isEditable;
  final bool isRequired;
  final bool isListable;
  final int? rowFlex;
  final int textAreaRows;
  final ValidationCallback? validator;
  final FieldType fieldType;
  final List<DropdownOption> options;
  final IconData? prefixIcon;
  final int sectionGroup;
  final bool rowColumn;

  final Color? color;
  final Color? backgroundColor;
  final String? previewKey;

  final FormatterCallback? formatter;
}

class FormSection {
  FormSection({this.group = 0, this.fields, this.title, this.subtitle});
  final int group;
  final String? title;
  final String? subtitle;
  @Deprecated('Use `group` instead')
  final List<FormFieldDefinition>? fields;
}
