import 'package:dynamic_forms/dynamic_forms.dart';
import 'package:flutter/material.dart';

class GenericDataTableSource2<
  T extends FormConfiguration2<U>,
  U extends ListableModel<U>
>
    extends DataTableSource {
  GenericDataTableSource2({
    required this.context,
    required this.columnCount,
    required this.configuration,
    this.rowBuilder,
    @Deprecated('Use onEditItemTap instead') this.onEditTap,
    @Deprecated('Use onRemoveItemTap instead') this.onRemoveTap,
    this.onCellTap,
    this.displayIndexToRawIndex = const <int>[0, 1],
    this.onEditItemTap,
    this.onRemoveItemTap,
    this.customRowAction,
    this.maxColumnWidth = 200.0,
  });
  final BuildContext context;
  final List<Widget> Function(U)? rowBuilder;
  final void Function(int index)? onCellTap;
  final double maxColumnWidth;

  @Deprecated('Use onEditItemTap instead')
  final void Function(int index)? onEditTap;
  final void Function(U item)? onEditItemTap;
  @Deprecated('Use onRemoveItemTap instead')
  final void Function(int index)? onRemoveTap;
  final void Function(U iitem)? onRemoveItemTap;
  final Widget Function(U item)? customRowAction;
  // final void Function(List<T> items)? onSelectChange;
  final int columnCount;

  final List<int> displayIndexToRawIndex;

  List<U> data = [];

  List<U> selected = [];
  T configuration;

  bool empty = true;

  List<U> setData(
    List<U> rawData, {
    int? sortColumn,
    bool? sortAscending,
    String? query,
  }) {
    if (rawData.isEmpty) {
      empty = true;

      data = [];
      notifyListeners();
      return [];
    }

    if (sortColumn == null || sortAscending == null) {
      data = rawData;
    } else {
      data = rawData.toList()
        ..sort((a, b) {
          final cellA =
              configuration.fields[displayIndexToRawIndex[sortColumn]];
          final cellB =
              configuration.fields[displayIndexToRawIndex[sortColumn]];

          final valueA = a.getValue<dynamic>(cellA.fieldName);
          final valueB = b.getValue<dynamic>(cellB.fieldName);

          if (valueA == null || valueB == null) {
            return 0;
          }
          if (valueA is DateTime && valueB is DateTime) {
            return valueA.compareTo(valueB) * (sortAscending ? 1 : -1);
          } else if (valueA is String && valueB is String) {
            return valueA.compareTo(valueB) * (sortAscending ? 1 : -1);
          } else if (valueA is num && valueB is num) {
            return valueA.compareTo(valueB) * (sortAscending ? 1 : -1);
          } else if (valueA is bool && valueB is bool) {
            return valueA == valueB
                ? 0
                : (valueA ? 1 : -1) * (sortAscending ? 1 : -1);
          } else {
            return 0; // Si los tipos no coinciden, no se ordena
          }
        });
    }

    empty = false;

    notifyListeners();

    return data;
  }

  void setSelectedAll(bool value) {
    if (value) {
      selected = [...data];
    } else {
      selected = [];
    }
    notifyListeners();
  }

  void setSelected(List<U> items) {
    selected = items;
    notifyListeners();
    return;
  }

  @override
  DataRow? getRow(int index) {
    if (empty) {
      return DataRow.byIndex(
        index: index,
        cells: const [DataCell(Text('No hay datos disponibles'))],
      );
    }

    final cells = <DataCell>[];
    if (rowBuilder != null) {
      final cellsInRow = rowBuilder!(data[index]).map(DataCell.new);
      cells.addAll(cellsInRow);
    } else {
      _generateCellByFieldType(cells, data[index]);
    }

    if (onEditTap != null ||
        onRemoveTap != null ||
        onEditItemTap != null ||
        onRemoveItemTap != null ||
        customRowAction != null) {
      cells.add(
        DataCell(
          placeholder: true,
          Row(
            children: [
              if (onEditTap != null || onEditItemTap != null)
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () {
                    onEditTap?.call(index);
                    onEditItemTap?.call(data[index]);
                  },
                ),
              if (onRemoveTap != null || onRemoveItemTap != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    onRemoveTap?.call(index);
                    onRemoveItemTap?.call(data[index]);
                  },
                ),
              if (customRowAction != null) customRowAction!(data[index]),
            ],
          ),
        ),
      );
    }

    return DataRow.byIndex(
      index: index,
      selected: selected.contains(data[index]),
      onSelectChanged: (bool? value) {
        if (value != null && value) {
          selected.add(data[index]);
        } else {
          selected.remove(data[index]);
        }

        notifyListeners();
      },
      cells: cells,
    );
  }

  @override
  int get rowCount => data.isEmpty ? 1 : data.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => selected.length;

  void _generateCellByFieldType(List<DataCell> cells, U sortedData) {
    final fields = configuration.fields.where((f) => f.isListable).toList();
    for (final field in fields) {
      switch (field.fieldType) {
        case FieldType.text:
        case FieldType.textarea:
          final value = sortedData.getValue<String>(field.fieldName);
          cells.add(DataCell(Text(value ?? '')));
          break;
        case FieldType.number:
          final value = sortedData.getValue<num>(field.fieldName);

          final formatted = field.formatter != null
              ? field.formatter!(value)
              : value?.toString() ?? '';
          cells.add(DataCell(Text('$formatted')));
          break;

        case FieldType.date:
          final value = sortedData.getValue<String>(field.fieldName);

          if (value == null || value.isEmpty) {
            cells.add(const DataCell(Text('')));
            break;
          }

          if (field.formatter != null) {
            final formatted = field.formatter!(DateTime.tryParse(value));
            cells.add(DataCell(Text(formatted ?? '')));
            break;
          }

          final date = DateTime.tryParse(value);
          final dateText = date?.toIso8601String() ?? '';

          cells.add(DataCell(Text(dateText)));
          break;
        case FieldType.dropdown:
          final value = sortedData.getValue<String>(field.fieldName) ?? '';

          if (field.options.isEmpty) {
            cells.add(DataCell(Text(value.isEmpty ? 'No definido' : value)));
            break;
          } else {
            final option = field.options.firstWhere(
              (e) => e.value == value,
              orElse: () => DropdownOption(label: value, value: value),
            );
            cells.add(DataCell(Text(option.label)));
          }
          break;

        case FieldType.dropdownMultiple:
          final value = sortedData.getListValue<String>(
            field.fieldName,
            field.previewKey ?? 'name',
          );
          if (value != null && value.isNotEmpty) {
            cells.add(DataCell(Text(value.join(', '))));
          } else {
            cells.add(const DataCell(Text('')));
          }
          break;

        case FieldType.toggle:
        case FieldType.checkbox:
          final value = sortedData.getValue<bool>(field.fieldName);
          cells.add(DataCell(Text(value == true ? 'Sí' : 'No')));
          break;
        case FieldType.html:
          cells.add(const DataCell(Text('Código html')));
          break;
        default:
          final value = sortedData.getValue<String>(field.fieldName);
          cells.add(DataCell(Text(value ?? '')));
      }
    }
  }
}
