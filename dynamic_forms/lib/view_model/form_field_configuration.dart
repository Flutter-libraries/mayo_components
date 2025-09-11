import 'package:flutter/widgets.dart';
import '../dynamic_forms.dart';

abstract class FormConfiguration2<T> {
  FormConfiguration2({required this.context});

  final BuildContext context;

  int get columnsCount => fields.where((f) => f.isListable).length;

  // bool contains(String a, String b);

  List<FormFieldDefinition> get fields => const [];
  List<FormSection> get sections => const [];
  // T onChange(String field, dynamic value, {bool concatenate = false});
  // U? getValue<U>(String fieldName);

  Map<String, List<DropdownOption>> get remoteOptions => const {};

  List<DropdownOption> getOptions(String fieldName) {
    return remoteOptions[fieldName] ?? [];
  }

  DropdownOption? getOption(String fieldName, String value) {
    return getOptions(fieldName).firstWhere(
      (option) => option.value == value,
      orElse: () => DropdownOption(value: value, label: value),
    );
  }
}

abstract class ListableModel<T> implements Comparable<T> {
  bool contains(String value);

  // T onChange(
  //   String field,
  //   dynamic value, {
  //   bool concatenate = false,
  // });

  // T? getValue<T>(
  //   String field,
  // );
}

extension JsonModelExtension<T> on T {
  /// Devuelve una copia del modelo con el campo cambiado.
  T onChange(
    String field,
    dynamic value, {
    required T Function(Map<String, dynamic>) fromJson,
    bool concatenate = false,
  }) {
    final json = (this as dynamic).toJson() as Map<String, dynamic>;
    final keys = field.split('.');

    Map<String, dynamic> current = json;
    for (int i = 0; i < keys.length - 1; i++) {
      current = current[keys[i]] as Map<String, dynamic>;
    }
    final lastKey = keys.last;

    if (concatenate && current[lastKey] is List) {
      current[lastKey] = [...(current[lastKey] as List), value];
    } else if (current[lastKey] is List && value is List) {
      // current[lastKey] = [...(current[lastKey] as List), ...value];
      current[lastKey] = value;
    } else {
      current[lastKey] = value;
    }

    return fromJson(json);
  }

  /// Obtiene el valor de un campo del modelo, soportando claves anidadas.
  U? getValue<U>(String field) {
    final json = (this as dynamic).toJson() as Map<String, dynamic>;
    final keys = field.split('.');

    dynamic current = json;
    for (final key in keys) {
      if (current is Map<String, dynamic> && current.containsKey(key)) {
        current = current[key];
      } else {
        return null;
      }
    }

    if (U.toString() == 'DateTime' && current != null) {
      return DateTime.tryParse(current) as U?;
    }

    return current as U?;
  }

  /// Obtiene una lista de valores de un campo del modelo, soportando claves anidadas.
  List<U>? getListValue<U>(String field, String key) {
    final json = (this as dynamic).toJson() as Map<String, dynamic>;
    final keys = field.split('.');

    dynamic current = json;
    for (final key in keys) {
      if (current is Map<String, dynamic> && current.containsKey(key)) {
        current = current[key];
      } else {
        return null;
      }
    }
    if (current is List<Map<String, dynamic>>) {
      return List<U>.from(current.map((e) => e[key] as U));
    } else if (current is List<U>) {
      return current;
    }
    return <U>[];
  }
}
