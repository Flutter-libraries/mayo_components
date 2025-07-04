import 'package:dynamic_forms/dynamic_forms.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mayo_components/mayo_components.dart';

import 'package:responsive_framework/responsive_framework.dart';

class DynamicFormBuilder<T extends FormConfiguration<U>, U>
    extends StatefulWidget {
  const DynamicFormBuilder({
    required this.formConfiguration,
    required this.formKey,
    required this.onFormChanged,
    required this.onValidChanged,
    this.enabled = true,
    this.rowSpacing = 24,
    this.columnSpacing = 24,
    this.layoutType = ResponsiveRowColumnType.COLUMN,
    this.titleStyle = const TextStyle(),
    super.key,
  });
  final double rowSpacing;
  final double columnSpacing;
  final ResponsiveRowColumnType layoutType;
  final TextStyle titleStyle;

  final T formConfiguration;
  final GlobalKey<FormState> formKey;
  final void Function(U item) onFormChanged;
  final void Function(bool value) onValidChanged;
  final bool enabled;

  @override
  State<DynamicFormBuilder<T, U>> createState() =>
      _DynamicFormBuilderState<T, U>();
}

class _DynamicFormBuilderState<T extends FormConfiguration<U>, U>
    extends State<DynamicFormBuilder<T, U>> {
  late U model;

  @override
  void initState() {
    super.initState();

    model = widget.formConfiguration.model;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onChanged: () {
        widget.onValidChanged(widget.formKey.currentState?.validate() ?? false);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: widget.columnSpacing,
        children: widget.formConfiguration.sections.asMap().entries.map((
          entry,
        ) {
          final index = entry.key;
          final section = entry.value;

          // If the section has its own fields, use them; otherwise, use the fields with the same index from the form configuration
          final fields = section.fields != null
              ? section.fields!
              : widget.formConfiguration.fields
                    .where(
                      (element) =>
                          element.sectionGroup == index && element.isEditable,
                    )
                    .toList();

          final form = ResponsiveRowColumn(
            layout: widget.layoutType,
            rowCrossAxisAlignment: CrossAxisAlignment.start,
            rowSpacing: widget.rowSpacing,
            columnSpacing: widget.columnSpacing,
            children: fields.map((fieldConfig) {
              return ResponsiveRowColumnItem(
                rowFlex: fieldConfig.rowFlex,
                child: _buildFormField(fieldConfig),
              );
            }).toList(),
          );
          if (section.title != null) {
            return OutlinedCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: widget.columnSpacing,
                children: [
                  Text(section.title!, style: widget.titleStyle),
                  form,
                ],
              ),
            );
          } else {
            return form;
          }
        }).toList(),
      ),
    );
  }

  Widget _buildFormField(FormFieldDefinition fieldConfig) {
    switch (fieldConfig.fieldType) {
      case FieldType.text:
      case FieldType.number:
        return TextFormField(
          initialValue: fieldConfig.fieldType == FieldType.number
              ? widget.formConfiguration
                    .getValue<double>(fieldConfig.fieldName)
                    .toString()
              : widget.formConfiguration.getValue<String>(
                  fieldConfig.fieldName,
                ),
          enabled: widget.enabled,
          decoration: InputDecoration(hintText: fieldConfig.label),
          textInputAction: TextInputAction.next,
          keyboardType: fieldConfig.fieldType == FieldType.number
              ? TextInputType.number
              : TextInputType.text,
          inputFormatters: fieldConfig.fieldType == FieldType.number
              ? [FilteringTextInputFormatter.digitsOnly]
              : [],
          validator: fieldConfig.validator != null
              ? (value) => fieldConfig.validator!(
                  context,
                  isRequired: fieldConfig.isRequired,
                  value: value,
                )
              : null,
          onChanged: (value) => _callback(
            fieldConfig.fieldName,
            fieldConfig.fieldType == FieldType.number
                ? double.tryParse(value)
                : value,
          ),
        );
      case FieldType.textarea:
        return TextFormField(
          initialValue: widget.formConfiguration.getValue<String>(
            fieldConfig.fieldName,
          ),
          enabled: widget.enabled && fieldConfig.isEditable,
          maxLines: fieldConfig.textAreaRows,
          decoration: InputDecoration(hintText: fieldConfig.label),
          onChanged: (value) => _callback(fieldConfig.fieldName, value),
        );

      case FieldType.password:
        return TextFormField(
          enabled: widget.enabled && fieldConfig.isEditable,
          decoration: InputDecoration(hintText: fieldConfig.label),
          obscureText: true,
          onChanged: (value) => _callback(fieldConfig.fieldName, value),
        );

      case FieldType.checkbox:
        return FormField<bool>(
          initialValue: widget.formConfiguration.getValue<bool>(
            fieldConfig.fieldName,
          ),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          // validator: (value) => value == false
          //     ? fieldConfig.errorLabel ?? context.localization.unknownError
          //     : null,
          builder: (fieldstate) => CheckboxListTile(
            value: fieldstate.value ?? false,
            title: Text(fieldConfig.label),
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (value) {
              fieldstate.didChange(value);

              _callback(fieldConfig.fieldName, value);
            },
          ),
        );
      case FieldType.toggle:
        return FormField<bool>(
          initialValue: widget.formConfiguration.getValue<bool>(
            fieldConfig.fieldName,
          ),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          // validator: (value) => value == false
          //     ? fieldConfig.errorLabel ?? context.localization.unknownError
          //     : null,
          builder: (fieldstate) => SwitchListTile(
            value: fieldstate.value ?? false,
            title: Text(fieldConfig.label),
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (value) {
              fieldstate.didChange(value);

              _callback(fieldConfig.fieldName, value);
            },
          ),
        );

      case FieldType.dropdown:
        return LayoutBuilder(
          builder: (context, constraints) => SizedBox(
            width: double.infinity,
            child: DropdownMenu(
              enableSearch: false,
              label: Text(fieldConfig.label),
              width: constraints.maxWidth,
              leadingIcon: fieldConfig.prefixIcon != null
                  ? Icon(fieldConfig.prefixIcon)
                  : null,
              dropdownMenuEntries: fieldConfig.options
                  .map(
                    (event) => DropdownMenuEntry(
                      value: event.value,
                      label: event.label,
                    ),
                  )
                  .toList(),
              onSelected: (event) {
                if (event != null) {
                  _callback(fieldConfig.fieldName, event);
                }
              },
            ),
          ),
        );
      case FieldType.dropdownMultiple:
        final value = widget.formConfiguration.getValue<List<String>>(
          fieldConfig.fieldName,
        );
        return LayoutBuilder(
          builder: (context, constraints) => SizedBox(
            width: double.infinity,
            child: DropdownMenu(
              enableSearch: false,
              label: Text(value?.join(', ') ?? fieldConfig.label),
              width: constraints.maxWidth,
              leadingIcon: fieldConfig.prefixIcon != null
                  ? Icon(fieldConfig.prefixIcon)
                  : null,
              dropdownMenuEntries: fieldConfig.options
                  .map(
                    (event) => DropdownMenuEntry(
                      value: event.value,
                      label: event.label,
                      labelWidget: CheckboxListTile(
                        title: Text(event.label),
                        dense: true,
                        value: value?.contains(event.value),
                        onChanged: (value) {
                          if (value != null) {
                            _callback(
                              fieldConfig.fieldName,
                              event.value,
                              concatenate: true,
                            );
                          }
                        },
                      ),
                    ),
                  )
                  .toList(),
              onSelected: (event) {
                if (event != null) {
                  _callback(fieldConfig.fieldName, event);
                }
              },
            ),
          ),
        );
      default:
        return TextFormField(
          enabled: widget.enabled && fieldConfig.isEditable,
          decoration: InputDecoration(hintText: fieldConfig.label),
          onChanged: (value) {
            setState(() {
              model = widget.formConfiguration.onChange(value, model);
              widget.onFormChanged(model);
            });
          },
        );
    }
  }

  void _callback(String fieldName, dynamic value, {bool concatenate = false}) {
    setState(() {
      model = widget.formConfiguration.onChange(
        fieldName,
        value,
        concatenate: concatenate,
      );
    });
    widget.onFormChanged(model);
  }
}

class DynamicFormBuilder2<
  T extends FormConfiguration2<U>,
  U extends ListableModel<U>
>
    extends StatefulWidget {
  const DynamicFormBuilder2({
    required this.item,
    required this.formConfiguration,
    required this.formKey,
    required this.onFormChanged,
    required this.onValidChanged,
    required this.fromJson,
    this.enabled = true,
    this.rowSpacing = 24,
    this.columnSpacing = 24,
    this.layoutType = ResponsiveRowColumnType.COLUMN,
    this.titleStyle,
    super.key,
  });
  final double rowSpacing;
  final double columnSpacing;
  final ResponsiveRowColumnType layoutType;
  final TextStyle? titleStyle;

  final U item;
  final T formConfiguration;
  final GlobalKey<FormState> formKey;
  final void Function(U item) onFormChanged;
  final void Function(bool value) onValidChanged;

  final U Function(Map<String, dynamic>) fromJson;
  final bool enabled;

  @override
  State<DynamicFormBuilder2<T, U>> createState() =>
      _DynamicFormBuilder2State<T, U>();
}

class _DynamicFormBuilder2State<
  T extends FormConfiguration2<U>,
  U extends ListableModel<U>
>
    extends State<DynamicFormBuilder2<T, U>> {
  late U item;

  @override
  void initState() {
    super.initState();

    item = widget.item;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onChanged: () {
        widget.onValidChanged(widget.formKey.currentState?.validate() ?? false);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: widget.columnSpacing,
        children: widget.formConfiguration.sections.asMap().entries.map((
          entry,
        ) {
          final index = entry.key;
          final section = entry.value;

          final fields = widget.formConfiguration.fields
              .where(
                (element) =>
                    element.sectionGroup == index && element.isEditable,
              )
              .toList();

          final form = ResponsiveRowColumn(
            layout: widget.layoutType,
            rowCrossAxisAlignment: CrossAxisAlignment.start,
            rowSpacing: widget.rowSpacing,
            columnSpacing: widget.columnSpacing,
            children: fields.map((fieldConfig) {
              return ResponsiveRowColumnItem(
                rowFit: FlexFit.loose,
                rowFlex: fieldConfig.rowFlex,
                rowColumn: fieldConfig.rowColumn,
                child: _buildFormField(fieldConfig),
              );
            }).toList(),
          );
          if (section.title != null) {
            return OutlinedCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: widget.columnSpacing,
                children: [
                  Text(
                    section.title!,
                    style:
                        widget.titleStyle ??
                        Theme.of(context).textTheme.headlineSmall,
                  ),
                  form,
                ],
              ),
            );
          } else {
            return form;
          }
        }).toList(),
      ),
    );
  }

  Widget _buildFormField(FormFieldDefinition fieldConfig) {
    switch (fieldConfig.fieldType) {
      case FieldType.text:
      case FieldType.number:
        return TextFormField(
          initialValue: fieldConfig.fieldType == FieldType.number
              ? item.getValue<double>(fieldConfig.fieldName).toString()
              : item.getValue<String>(fieldConfig.fieldName),
          enabled: widget.enabled,
          decoration: InputDecoration(
            labelText: fieldConfig.label,
            helperText: fieldConfig.description,
          ),
          textInputAction: TextInputAction.next,
          keyboardType: fieldConfig.fieldType == FieldType.number
              ? TextInputType.number
              : TextInputType.text,
          inputFormatters: fieldConfig.fieldType == FieldType.number
              ? [FilteringTextInputFormatter.digitsOnly]
              : [],
          validator: fieldConfig.validator != null
              ? (value) => fieldConfig.validator!(
                  context,
                  isRequired: fieldConfig.isRequired,
                  value: value,
                )
              : null,
          onChanged: (value) => _callback(
            fieldConfig.fieldName,
            fieldConfig.fieldType == FieldType.number
                ? double.tryParse(value)
                : value,
          ),
        );
      case FieldType.textarea:
        return TextFormField(
          initialValue: item.getValue<String>(fieldConfig.fieldName),
          enabled: widget.enabled && fieldConfig.isEditable,
          maxLines: fieldConfig.textAreaRows,
          decoration: InputDecoration(
            labelText: fieldConfig.label,
            helperText: fieldConfig.description,
          ),
          onChanged: (value) => _callback(fieldConfig.fieldName, value),
        );

      case FieldType.password:
        return TextFormField(
          enabled: widget.enabled && fieldConfig.isEditable,
          decoration: InputDecoration(
            labelText: fieldConfig.label,
            helperText: fieldConfig.description,
          ),
          obscureText: true,
          onChanged: (value) => _callback(fieldConfig.fieldName, value),
        );

      case FieldType.checkbox:
        return FormField<bool>(
          initialValue: item.getValue<bool>(fieldConfig.fieldName),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          // validator: (value) => value == false
          //     ? fieldConfig.errorLabel ?? context.localization.unknownError
          //     : null,
          builder: (fieldstate) => CheckboxListTile(
            value: fieldstate.value ?? false,
            title: Text(fieldConfig.label),
            subtitle: fieldConfig.description != null
                ? Text(fieldConfig.description!)
                : null,
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (value) {
              fieldstate.didChange(value);

              _callback(fieldConfig.fieldName, value);
            },
          ),
        );
      case FieldType.toggle:
        return FormField<bool>(
          initialValue: item.getValue<bool>(fieldConfig.fieldName),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          // validator: (value) => value == false
          //     ? fieldConfig.errorLabel ?? context.localization.unknownError
          //     : null,
          builder: (fieldstate) => SwitchListTile(
            value: fieldstate.value ?? false,
            title: Text(fieldConfig.label),
            subtitle: fieldConfig.description != null
                ? Text(fieldConfig.description!)
                : null,
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (value) {
              fieldstate.didChange(value);

              _callback(fieldConfig.fieldName, value);
            },
          ),
        );

      case FieldType.dropdown:
        return LayoutBuilder(
          builder: (context, constraints) => SizedBox(
            width: double.infinity,
            child: DropdownMenu(
              enableSearch: false,
              initialSelection: item.getValue<String>(fieldConfig.fieldName),
              label: Text(fieldConfig.label),
              helperText: fieldConfig.description,
              width: constraints.maxWidth,
              leadingIcon: Icon(fieldConfig.prefixIcon),
              dropdownMenuEntries: fieldConfig.options
                  .map(
                    (event) => DropdownMenuEntry(
                      value: event.value,
                      label: event.label,
                    ),
                  )
                  .toList(),
              onSelected: (event) {
                if (event != null) {
                  _callback(fieldConfig.fieldName, event);
                }
              },
            ),
          ),
        );
      case FieldType.dropdownMultiple:
        final value = item.getValue<List<String>>(fieldConfig.fieldName);
        // final optionsSelected = fieldConfig.options
        //     .where((option) => value?.contains(option.value) ?? false)
        //     .toList();
        // final hintText = optionsSelected.isNotEmpty
        //     ? optionsSelected.map((e) => e.label).join(', ')
        //     : fieldConfig.label;
        return LayoutBuilder(
          builder: (context, constraints) => SizedBox(
            width: double.infinity,
            child: DropdownMenu(
              enableSearch: false,
              label: Text(fieldConfig.label),
              helperText: fieldConfig.description,
              width: constraints.maxWidth,
              leadingIcon: Icon(fieldConfig.prefixIcon),
              dropdownMenuEntries: fieldConfig.options
                  .map(
                    (event) => DropdownMenuEntry(
                      value: event.value,
                      label: event.label,
                      labelWidget: CheckboxListTile(
                        title: Text(event.label),
                        dense: true,
                        value: value?.contains(event.value),
                        onChanged: (value) {
                          if (value != null) {
                            _callback(
                              fieldConfig.fieldName,
                              event.value,
                              concatenate: true,
                            );
                          }
                        },
                      ),
                    ),
                  )
                  .toList(),
              onSelected: (event) {
                if (event != null) {
                  _callback(fieldConfig.fieldName, event, concatenate: true);
                }
              },
            ),
          ),
        );
      case FieldType.date:
        return FormField<DateTime>(
          initialValue: item.getValue<DateTime>(fieldConfig.fieldName),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          // validator: fieldConfig.isRequired
          //     ? (value) => fieldConfig.validator?.call(
          //           context,
          //           isRequired: fieldConfig.isRequired,
          //           value: value,
          //         )
          //     : null,
          builder: (fieldstate) => InkWell(
            onTap: widget.enabled && fieldConfig.isEditable
                ? () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: fieldstate.value ?? DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      fieldstate.didChange(picked);
                      _callback(fieldConfig.fieldName, picked);
                    }
                  }
                : null,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: fieldConfig.label,
                helperText: fieldConfig.description,
                enabled: widget.enabled && fieldConfig.isEditable,
              ),
              child: Text(
                fieldstate.value != null
                    ? MaterialLocalizations.of(
                        context,
                      ).formatMediumDate(fieldstate.value!)
                    : 'Selecciona una fecha',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
        );

      case FieldType.time:
        return FormField<TimeOfDay>(
          initialValue: item.getValue<TimeOfDay>(fieldConfig.fieldName),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          // validator: fieldConfig.isRequired
          //     ? (value) => fieldConfig.validator?.call(
          //           context,
          //           isRequired: fieldConfig.isRequired,
          //           value: value,
          //         )
          //     : null,
          builder: (fieldstate) => InkWell(
            onTap: widget.enabled && fieldConfig.isEditable
                ? () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: fieldstate.value ?? TimeOfDay.now(),
                    );
                    if (picked != null) {
                      fieldstate.didChange(picked);
                      _callback(fieldConfig.fieldName, picked);
                    }
                  }
                : null,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: fieldConfig.label,
                helperText: fieldConfig.description,
                enabled: widget.enabled && fieldConfig.isEditable,
              ),
              child: Text(
                fieldstate.value != null
                    ? MaterialLocalizations.of(
                        context,
                      ).formatTimeOfDay(fieldstate.value!)
                    : 'Selecciona una hora',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
        );

      case FieldType.dateRange:
        return FormField<DateTimeRange>(
          initialValue: item.getValue<DateTimeRange>(fieldConfig.fieldName),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          // validator: fieldConfig.isRequired
          //     ? (value) => fieldConfig.validator?.call(
          //           context,
          //           isRequired: fieldConfig.isRequired,
          //           value: value,
          //         )
          //     : null,
          builder: (fieldstate) => InkWell(
            onTap: widget.enabled && fieldConfig.isEditable
                ? () async {
                    final picked = await showDateRangePicker(
                      context: context,
                      initialDateRange: fieldstate.value,
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      fieldstate.didChange(picked);
                      _callback(fieldConfig.fieldName, picked);
                    }
                  }
                : null,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: fieldConfig.label,
                helperText: fieldConfig.description,
                enabled: widget.enabled && fieldConfig.isEditable,
              ),
              child: Text(
                fieldstate.value != null
                    ? '${MaterialLocalizations.of(context).formatMediumDate(fieldstate.value!.start)} - ${MaterialLocalizations.of(context).formatMediumDate(fieldstate.value!.end)}'
                    : 'Selecciona un rango de fechas',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
        );
      case FieldType.html:
        return FormField<String>(
          initialValue: item.getValue<String>(fieldConfig.fieldName),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: fieldConfig.isRequired
              ? (value) => fieldConfig.validator?.call(
                  context,
                  isRequired: fieldConfig.isRequired,
                  value: value,
                )
              : null,
          builder: (fieldstate) => GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              // Quita el foco de cualquier otro campo antes de que el editor lo tome
              FocusScope.of(context).unfocus();
            },
            child: HtmlEditor(
              initialValue: item.getValue<String>(fieldConfig.fieldName) ?? '',
              title: fieldConfig.label,
              hintText: fieldConfig.label,
              enabled: widget.enabled && fieldConfig.isEditable,
              onTextChanged: (text) {
                _callback(fieldConfig.fieldName, text);
              },
            ),
          ),
        );
    }
  }

  void _callback(String fieldName, dynamic value, {bool concatenate = false}) {
    final updated = item.onChange(
      fieldName,
      value,
      fromJson: widget.fromJson,
      concatenate: concatenate,
    );

    setState(() {
      item = updated;
    });

    widget.onFormChanged(updated);
  }
}
