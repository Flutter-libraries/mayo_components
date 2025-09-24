import 'package:dynamic_forms/dynamic_forms.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';

enum _SfRowAction { edit, remove }

class SfGenericDataGrid<T extends FormConfiguration2<S>,
    S extends ListableModel<S>> extends StatefulWidget {
  const SfGenericDataGrid({
    super.key,
    required this.configuration,
    required this.items,
    required this.columnCount,
    this.columns,
    this.onEditItemTap,
    this.onRemoveItemTap,
    this.customRowAction,
    this.rowBuilder,
    this.toolbarActions,
    this.setSelectedItems,
    this.rowsPerPage = 10,
    this.availableRowsPerPage = const [10, 25, 50, 100],
    this.showSearchField = true,
    this.allowSorting = true,
    this.allowMultiSelection = true,
  this.allowRowSelection = true,
    this.columnWidthMode = ColumnWidthMode.fill,
    this.columnWidths,
    this.headerBackgroundColor,
    this.headerTextStyle,
    this.rowTextStyle,
    this.gridLineColor,
    this.selectionColor,
    this.rowHoverColor,
    this.pagerItemColor,
    this.pagerSelectedItemColor,
    this.footerBackgroundColor,
    this.maxHeight,
    this.expanded = true,
    this.persistRowsPerPage = true,
    this.preferenceKey,
  });

  final T configuration;
  final List<S> items;
  final int columnCount;
  final List<GridColumn>? columns;

  final void Function(S item)? onEditItemTap;
  final void Function(S item)? onRemoveItemTap;
  final Widget Function(S item)? customRowAction;
  // Permite personalizar el contenido de las celdas de cada fila.
  // Debe devolver tantos widgets como columnas listables haya en configuration.
  final List<Widget> Function(S data)? rowBuilder;

  final List<Widget>? toolbarActions;
  final void Function(List<S> items)? setSelectedItems;

  final int rowsPerPage;
  final List<int> availableRowsPerPage;
  final bool showSearchField;
  final bool allowSorting;
  final bool allowMultiSelection;
  /// Si es false, se desactiva completamente la selección de filas (no highlight ni checkboxes).
  final bool allowRowSelection;
  final ColumnWidthMode columnWidthMode;
  final Map<String, double>? columnWidths;
  // Theming opcional (neutral)
  final Color? headerBackgroundColor;
  final TextStyle? headerTextStyle;
  final TextStyle? rowTextStyle;
  final Color? gridLineColor;
  final Color? selectionColor;
  final Color? rowHoverColor;
  final Color? pagerItemColor;
  final Color? pagerSelectedItemColor;
  // Fondo del footer (selector de filas + paginador)
  final Color? footerBackgroundColor;
  // Altura máxima opcional del grid. Si se establece, no se usará Expanded
  // aunque `expanded` sea true, para respetar la restricción.
  final double? maxHeight;
  // Si true, el grid se expande para ocupar el espacio disponible.
  // Si false, el grid no se envuelve en Expanded (el contenedor padre debe aportar las constraints necesarias).
  final bool expanded;
  /// Si es true (por defecto) se persiste el número de filas por página usando
  /// SharedPreferences para que se reaplique en todas las tablas.
  final bool persistRowsPerPage;
  /// Clave opcional para aislar persistencia entre distintos tipos de tablas.
  /// Si no se especifica se usa una clave genérica global.
  final String? preferenceKey;

  @override
  State<SfGenericDataGrid<T, S>> createState() =>
      _SfGenericDataGridState<T, S>();
}

class _SfGenericDataGridState<T extends FormConfiguration2<S>,
    S extends ListableModel<S>> extends State<SfGenericDataGrid<T, S>> {
  late _SfGenericDataSource<T, S> dataSource;
  late int _rowsPerPage;
  final DataGridController _controller = DataGridController();
  late List<S> _allItems;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  // Selección acumulada (a través de páginas y filtros)
  final List<S> _selected = <S>[];

  @override
  void initState() {
    super.initState();
    _rowsPerPage = widget.rowsPerPage;
    _allItems = widget.items;
    if (widget.persistRowsPerPage) {
      _restoreRowsPerPagePreference();
    }
    dataSource = _SfGenericDataSource<T, S>(
      configuration: widget.configuration,
      items: _allItems,
      pageSize: _rowsPerPage,
      onEditItemTap: widget.onEditItemTap,
      onRemoveItemTap: widget.onRemoveItemTap,
      customRowAction: widget.customRowAction,
      rowBuilder: widget.rowBuilder,
      rowTextStyle: widget.rowTextStyle,
      showSelectionColumn:
          widget.allowRowSelection && widget.setSelectedItems != null,
      isItemSelected: (item) =>
          widget.allowRowSelection && _selected.contains(item),
      onRowCheckboxChanged: (item, checked) {
        if (!widget.allowRowSelection) return;
        setState(() {
          if (checked) {
            if (!_selected.contains(item)) _selected.add(item);
          } else {
            _selected.remove(item);
          }
        });
        if (widget.allowRowSelection) {
          widget.setSelectedItems?.call(List<S>.unmodifiable(_selected));
          dataSource.notifySelectionChanged();
        }
      },
      onSyncSelection: (selectedRows) {
        if (!widget.allowRowSelection) return;
        _controller.selectedRows = selectedRows; // sincroniza visual
      },
    );
  }
  void _restoreRowsPerPagePreference() {
    final key = widget.preferenceKey ?? 'global_rows_per_page';
    // Cargamos async tras primer frame para no bloquear initState.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final prefs = await SharedPreferences.getInstance();
        final stored = prefs.getInt(key);
        if (stored != null && stored != _rowsPerPage && widget.availableRowsPerPage.contains(stored)) {
          setState(() {
            _rowsPerPage = stored;
            dataSource.updatePageSize(_rowsPerPage);
          });
        }
      } catch (_) {
        // Silencioso: si falla seguimos con valor por defecto
      }
    });
  }

  Future<void> _persistRowsPerPage(int value) async {
    if (!widget.persistRowsPerPage) return;
    final key = widget.preferenceKey ?? 'global_rows_per_page';
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(key, value);
    } catch (_) {
      // Ignorar errores de persistencia
    }
  }

  @override
  void didUpdateWidget(covariant SfGenericDataGrid<T, S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rowBuilder != widget.rowBuilder) {
      dataSource.setRowBuilder(widget.rowBuilder);
    }
    if (oldWidget.items != widget.items ||
        oldWidget.configuration != widget.configuration) {
      _allItems = widget.items;
      _applyFilter(_searchQuery);
    }
    if ((oldWidget.setSelectedItems != null) !=
        (widget.setSelectedItems != null)) {
      dataSource.setShowSelectionColumn(
          widget.allowRowSelection && widget.setSelectedItems != null);
    }
    if (oldWidget.allowRowSelection != widget.allowRowSelection) {
      // Ocultamos/mostramos columna de selección y limpiamos selección si se desactiva
      if (!widget.allowRowSelection) {
        _selected.clear();
        _controller.selectedRows = [];
      }
      dataSource.setShowSelectionColumn(
          widget.allowRowSelection && widget.setSelectedItems != null);
    }
  }

  void _applyFilter(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      dataSource.setItems(_allItems);
      return;
    }
    final q = query.toLowerCase();
    final filtered = _allItems.where((e) => e.contains(q)).toList();
    dataSource.setItems(filtered);
  }

  @override
  Widget build(BuildContext context) {
    final theme = DynamicFormsTheme.maybeOf(context);
    final headerBg =
        widget.headerBackgroundColor ?? theme?.headerBackgroundColor;
    final gridLine = widget.gridLineColor ?? theme?.gridLineColor;
    final selection = widget.selectionColor ?? theme?.selectionColor;
    final hover = widget.rowHoverColor ?? theme?.rowHoverColor;
    final pagerItem = widget.pagerItemColor ?? theme?.pagerItemColor;
    final pagerSelected =
        widget.pagerSelectedItemColor ?? theme?.pagerSelectedItemColor;
    final footerBg =
        widget.footerBackgroundColor ?? theme?.footerBackgroundColor;
    final columns = widget.columns ?? _buildColumns();
    final children = <Widget>[];
    if (widget.showSearchField || widget.toolbarActions != null) {
      children.add(
        Row(
          children: [
            if (widget.showSearchField)
              SizedBox(
                width: 320,
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(hintText: 'Buscar...'),
                  onChanged: (value) => _applyFilter(value),
                ),
              ),
            const Spacer(),
            if (widget.toolbarActions != null) ...widget.toolbarActions!,
          ],
        ),
      );
      children.add(const SizedBox(height: 8));
    }
    if (widget.items.isEmpty) {
      children.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('No hay resultados',
                style: Theme.of(context).textTheme.bodyMedium),
          ),
        ),
      );
      return Column(children: children);
    }
    // Construimos el grid una vez y lo envolvemos condicionalmente en Expanded cuando hay datos.
    children.add(
      (() {
          final gridChild = Builder(
            builder: (context) {
              Widget grid = SfDataGrid(
                source: dataSource,
                controller: _controller,
                allowSorting: widget.allowSorting,
                selectionMode: widget.allowRowSelection
                    ? (widget.allowMultiSelection
                        ? SelectionMode.multiple
                        : SelectionMode.single)
                    : SelectionMode.none,
                columnWidthMode: widget.columnWidthMode,
                columns: columns,
                onSelectionChanged: (added, removed) {
                  if (!widget.allowRowSelection) return;
                  // Actualiza la lista acumulada en base a filas añadidas/eliminadas
                  List<S> mapRows(List<DataGridRow> rows) => rows
                      .map((r) => (r
                          .getCells()
                          .firstWhere((c) => c.columnName == '__index__')
                          .value) as S)
                      .toList();
                  final addedItems = mapRows(added);
                  final removedItems = mapRows(removed);

                  setState(() {
                    for (final it in addedItems) {
                      if (!_selected.contains(it)) _selected.add(it);
                    }
                    for (final it in removedItems) {
                      _selected.remove(it);
                    }
                  });
                  widget.setSelectedItems
                      ?.call(List<S>.unmodifiable(_selected));
                  // Fuerza refresco para que los checkboxes reflejen el highlight manual
                  dataSource.notifySelectionChanged();
                },
              );
              // Aplica tema de grid si hay colores definidos
              final hasGridTheme = headerBg != null ||
                  gridLine != null ||
                  selection != null ||
                  hover != null;
              if (hasGridTheme) {
                grid = SfDataGridTheme(
                  data: SfDataGridThemeData(
                    headerColor: headerBg,
                    gridLineColor: gridLine,
                    selectionColor: selection,
                    rowHoverColor: hover,
                  ),
                  child: grid,
                );
              }
              return grid;
            },
          );
          // Si se especifica una altura máxima, envolvemos en ConstrainedBox
          // y evitamos Expanded para respetar la restricción.
          Widget result = gridChild;
          if (widget.maxHeight != null) {
            result = ConstrainedBox(
              constraints: BoxConstraints(maxHeight: widget.maxHeight!),
              child: result,
            );
            return result; // No usar Expanded si hay maxHeight
          }
          return widget.expanded ? Expanded(child: result) : result;
        })(),
    );
    if (widget.items.isNotEmpty) {
      children.add(
        Container(
            height: 56,
            decoration: BoxDecoration(
              color: footerBg,
              border: Border(
                top: BorderSide(
                  color: (gridLine ?? Theme.of(context).dividerColor)
                      .withValues(alpha: 0.6),
                  width: 0.5,
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                // Selector de filas por página
                Text(
                  'Filas por página:',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(width: 8),
                DropdownButton<int>(
                  value: _rowsPerPage,
                  items: widget.availableRowsPerPage
                      .map((v) => DropdownMenuItem<int>(
                            value: v,
                            child: Text(
                              '$v',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v == null || v == _rowsPerPage) return;
                    setState(() {
                      _rowsPerPage = v;
                      dataSource.updatePageSize(v);
                    });
                    _persistRowsPerPage(v);
                  },
                ),
                const Spacer(),
                // Paginador
                Builder(
                  builder: (context) {
                    Widget pager = SfDataPager(
                      delegate: dataSource,
                      pageCount:
                          (dataSource.rowCount / _rowsPerPage).ceilToDouble(),
                    );
                    final hasPagerTheme =
                        pagerItem != null || pagerSelected != null;
                    if (hasPagerTheme) {
                      pager = SfDataPagerTheme(
                        data: SfDataPagerThemeData(
                          itemColor: pagerItem,
                          selectedItemColor: pagerSelected,
                        ),
                        child: pager,
                      );
                    }
                    return pager;
                  },
                ),
              ],
            ),
          ),
      );
    }
    return Column(children: children);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<GridColumn> _buildColumns() {
    final labeler = (String text) => Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.centerLeft,
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: widget.headerTextStyle ??
                DynamicFormsTheme.maybeOf(context)?.headerTextStyle ??
                Theme.of(context).textTheme.titleMedium,
          ),
        );

    final listable =
        widget.configuration.fields.where((f) => f.isListable).toList();
    final cols = <GridColumn>[
      // Columna oculta para guardar el item
      GridColumn(
        columnName: '__index__',
        width: 0,
        visible: false,
        label: const SizedBox.shrink(),
      ),
      if (widget.setSelectedItems != null)
        GridColumn(
          columnName: '__select__',
          width: 52,
          allowSorting: false,
          label: Align(
            alignment: Alignment.center,
            child: StatefulBuilder(
              builder: (context, setStateHeader) {
                final items = dataSource.items;
                final total = items.length;
                final selectedOnFilter = items.where(_selected.contains).length;
                bool? value;
                if (total == 0 || selectedOnFilter == 0) {
                  value = false;
                } else if (selectedOnFilter == total) {
                  value = true;
                } else {
                  value = null; // indeterminado
                }
                return Checkbox(
                  tristate: true,
                  value: value,
                  onChanged: (v) {
                    final wantSelectAll =
                        v == true || (v == null && selectedOnFilter < total);
                    setState(() {
                      if (wantSelectAll) {
                        for (final it in items) {
                          if (!_selected.contains(it)) _selected.add(it);
                        }
                      } else {
                        for (final it in items) {
                          _selected.remove(it);
                        }
                      }
                    });
                    // Avisar a consumidores y refrescar grid
                    widget.setSelectedItems
                        ?.call(List<S>.unmodifiable(_selected));
                    dataSource.notifySelectionChanged();
                    // Forzar redibujo del header para actualizar su estado
                    setStateHeader(() {});
                    setState(() {});
                  },
                );
              },
            ),
          ),
        ),
      ...listable.map((f) {
        final w = widget.columnWidths?[f.fieldName];
        return GridColumn(
          columnName: f.fieldName,
          label: labeler(f.label),
          width: w ?? double.nan,
        );
      }),
    ];

    if (widget.onEditItemTap != null ||
        widget.onRemoveItemTap != null ||
        widget.customRowAction != null) {
      // Si hay customRowAction, necesitamos más ancho para evitar desbordes.
      final actionsWidthOverride = widget.columnWidths?['__actions__'];
      final defaultActionsWidth = widget.customRowAction != null ? 120.0 : 80.0;
      cols.add(
        GridColumn(
          columnName: '__actions__',
          width: actionsWidthOverride ?? defaultActionsWidth,
          allowSorting: false,
          label: const SizedBox.shrink(),
        ),
      );
    }
    return cols;
  }
}

class _SfGenericDataSource<T extends FormConfiguration2<U>,
    U extends ListableModel<U>> extends DataGridSource {
  _SfGenericDataSource({
    required this.configuration,
    required List<U> items,
    required this.pageSize,
    this.onEditItemTap,
    this.onRemoveItemTap,
    this.customRowAction,
    this.rowBuilder,
    this.rowTextStyle,
    this.showSelectionColumn = false,
    bool Function(U item)? isItemSelected,
    void Function(U item, bool checked)? onRowCheckboxChanged,
    this.onSyncSelection,
  }) {
    // Asegura que trabajamos con una lista mutable
    _items = List<U>.from(items);
    _currentPage = 0;
    _isItemSelected = isItemSelected ?? ((_) => false);
    _onRowCheckboxChanged = onRowCheckboxChanged ?? (_, __) {};
    _buildRows();
    _syncControllerSelection();
  }

  T configuration;

  late List<U> _items;
  late List<DataGridRow> _rows;
  late int pageSize;
  int _currentPage = 0;

  final void Function(U item)? onEditItemTap;
  final void Function(U item)? onRemoveItemTap;
  final Widget Function(U item)? customRowAction;
  List<Widget> Function(U data)? rowBuilder;
  final TextStyle? rowTextStyle;
  bool showSelectionColumn;
  late bool Function(U item) _isItemSelected;
  late void Function(U item, bool checked) _onRowCheckboxChanged;
  final void Function(List<DataGridRow> selectedRows)? onSyncSelection;

  // Exponer elementos filtrados actuales
  List<U> get items => List<U>.unmodifiable(_items);

  void setItems(List<U> items) {
    // Copiamos para evitar listas inmodificables al ordenar
    _items = List<U>.from(items);
    _currentPage = 0;
    _buildRows();
    notifyListeners();
    _syncControllerSelection();
  }

  void _buildRows() {
    final fields = configuration.fields.where((f) => f.isListable).toList();
    final start = _currentPage * pageSize;
    final end =
        (_items.length - start) >= pageSize ? start + pageSize : _items.length;
    final slice = (start < _items.length && start < end)
        ? _items.sublist(start, end)
        : <U>[];

    _rows = slice.map((item) {
      final cells = <DataGridCell>[
        DataGridCell<U>(columnName: '__index__', value: item),
        if (showSelectionColumn)
          DataGridCell<bool>(
            columnName: '__select__',
            value: _isItemSelected(item),
          ),
        ...fields.map((f) {
          switch (f.fieldType) {
            case FieldType.number:
              final v = item.getValue<num>(f.fieldName);
              return DataGridCell<num?>(columnName: f.fieldName, value: v);
            case FieldType.toggle:
            case FieldType.checkbox:
              final v = item.getValue<bool>(f.fieldName);
              return DataGridCell<bool?>(columnName: f.fieldName, value: v);
            case FieldType.date:
              final v = item.getValue<String>(f.fieldName);
              if (f.formatter != null) {
                return DataGridCell<String?>(
                    columnName: f.fieldName, value: f.formatter!(v));
              }

              if (v == null || v.isEmpty) {
                return DataGridCell<String?>(
                    columnName: f.fieldName, value: '');
              }

              final date = DateTime.tryParse(v);
              final dateText = date?.toIso8601String() ?? '';
              return DataGridCell<String?>(
                  columnName: f.fieldName, value: dateText);
            case FieldType.dropdown:
              return DataGridCell<String?>(
                  columnName: f.fieldName,
                  value: item.getValue<String>(f.fieldName));
            case FieldType.dropdownMultiple:
              final v = item.getListValue<String>(
                f.fieldName,
                f.previewKey ?? 'name',
              );
              return DataGridCell<List<String>?>(
                  columnName: f.fieldName, value: v);

            default:
              final v = item.getValue<String>(f.fieldName);
              return DataGridCell<String?>(columnName: f.fieldName, value: v);
          }
        }),
        if (onEditItemTap != null ||
            onRemoveItemTap != null ||
            customRowAction != null)
          DataGridCell<String>(columnName: '__actions__', value: ''),
      ];
      return DataGridRow(cells: cells);
    }).toList();
  }

  void _syncControllerSelection() {
    if (onSyncSelection == null) return;
    // Construye las filas seleccionadas de la página actual
    final selectedRows = _rows.where((row) {
      final item = row
          .getCells()
          .firstWhere((c) => c.columnName == '__index__')
          .value as U;
      return _isItemSelected(item);
    }).toList();
    onSyncSelection!(selectedRows);
  }

  @override
  @override
  Future<void> sort() async {
    if (sortedColumns.isEmpty) return;
    final sortCol = sortedColumns.first;
    final name = sortCol.name;
    final asc = sortCol.sortDirection == DataGridSortDirection.ascending;

    int compare(dynamic a, dynamic b) {
      if (a == null || b == null) return 0;
      if (a is num && b is num) return a.compareTo(b);
      if (a is String && b is String) return a.compareTo(b);
      if (a is bool && b is bool) return (a == b) ? 0 : (a ? 1 : -1);
      if (a is DateTime && b is DateTime) return a.compareTo(b);
      return 0;
    }

    _items.sort((a, b) {
      final va = a.getValue<dynamic>(name);
      final vb = b.getValue<dynamic>(name);
      final r = compare(va, vb);
      return asc ? r : -r;
    });

    _buildRows();
    notifyListeners();
    _syncControllerSelection();
    return;
  }

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final fields = configuration.fields.where((f) => f.isListable).toList();
    int index = 0;
    // Obtiene el item real para que rowBuilder pueda usarlo si está definido.
    final U item = row
        .getCells()
        .firstWhere((c) => c.columnName == '__index__')
        .value as U;
    final customCells = rowBuilder?.call(item);
    final canUseCustom =
        customCells != null && customCells.length == fields.length;
    return DataGridRowAdapter(
      cells: row.getCells().map((cell) {
        final name = cell.columnName;
        if (name == '__index__') {
          return const SizedBox.shrink();
        }
        if (name == '__select__') {
          final checked = _isItemSelected(item);
          return Center(
            child: Checkbox(
              value: checked,
              onChanged: (v) {
                _onRowCheckboxChanged(item, v ?? false);
                // Refrescar solo esta fila
                notifyListeners();
              },
            ),
          );
        }
        if (name == '__actions__') {
          final hasEdit = onEditItemTap != null;
          final hasRemove = onRemoveItemTap != null;

          return Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              PopupMenuButton<_SfRowAction>(
                icon: const Icon(Icons.more_vert),
                onSelected: (action) {
                  switch (action) {
                    case _SfRowAction.edit:
                      if (hasEdit) onEditItemTap!.call(item);
                      break;
                    case _SfRowAction.remove:
                      if (hasRemove) onRemoveItemTap!.call(item);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  if (hasEdit)
                    PopupMenuItem<_SfRowAction>(
                      value: _SfRowAction.edit,
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 18),
                          SizedBox(width: 8),
                          Text('Editar'),
                        ],
                      ),
                    ),
                  if (hasRemove)
                    PopupMenuItem<_SfRowAction>(
                      value: _SfRowAction.remove,
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, size: 18),
                          SizedBox(width: 8),
                          Text('Eliminar'),
                        ],
                      ),
                    ),
                ],
              ),
              if (customRowAction != null) ...[
                const SizedBox(width: 4),
                customRowAction!(item),
              ],
            ],
          );
        }

        final field = fields[index++];
        if (canUseCustom) {
          // Usa el widget personalizado correspondiente a esta columna.
          final widget = customCells[index - 1];
          return Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: widget,
          );
        }

        // Determinar texto, colores e icono basados en la definición del campo
        Color? cellTextColor = field.color;
        Color? cellBackgroundColor = field.backgroundColor;
        IconData? leadingIcon = field.prefixIcon;
        final text = () {
          switch (field.fieldType) {
            case FieldType.number:
              final v = cell.value as num?;
              if (field.formatter != null) {
                return field.formatter!(v)?.toString() ?? '';
              }
              return v?.toString() ?? '';
            case FieldType.toggle:
            case FieldType.checkbox:
              final v = cell.value as bool?;
              return v == true ? 'Sí' : 'No';
            case FieldType.dropdown:
              final v = cell.value as String?;
              final opt = field.options.firstWhere(
                (o) => o.value == v,
                orElse: () => DropdownOption(label: v ?? '', value: v ?? ''),
              );
              // Si la opción define color/fondo, tiene prioridad
              cellTextColor = opt.color ?? cellTextColor;
              cellBackgroundColor = opt.backgroundColor ?? cellBackgroundColor;
              return opt.label;
            case FieldType.dropdownMultiple:
              final v = cell.value as List<String>?;
              // Para múltiples mostramos texto plano; colores a nivel de campo
              return v?.join(', ') ?? '';
            default:
              return (cell.value as String?) ?? '';
          }
        }();

        return Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          // Dejamos de pintar el background en toda la celda; si hay icono y fondo, usamos un Chip.
          child: Builder(
            builder: (context) {
              final baseStyle = rowTextStyle ??
                  DynamicFormsTheme.maybeOf(context)?.rowTextStyle ??
                  Theme.of(context).textTheme.bodyMedium;
              final effectiveStyle = (baseStyle ?? const TextStyle()).copyWith(
                color: cellTextColor ?? baseStyle?.color,
              );

              final bool showChip =
                  leadingIcon != null && cellBackgroundColor != null;
              if (showChip) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Chip(
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    labelPadding: EdgeInsets.zero,
                    avatar: Icon(leadingIcon,
                        size: 16, color: effectiveStyle.color),
                    label: Text(
                      text,
                      overflow: TextOverflow.ellipsis,
                      style: effectiveStyle,
                    ),
                    backgroundColor: cellBackgroundColor,
                    side: BorderSide.none,
                  ),
                );
              }

              // Fallback: texto (y opcionalmente icono) sin colorear todo el fondo.
              final children = <Widget>[];
              if (leadingIcon != null) {
                children.add(
                    Icon(leadingIcon, size: 18, color: effectiveStyle.color));
                children.add(const SizedBox(width: 6));
              }
              children.add(
                Expanded(
                  child: Text(
                    text,
                    overflow: TextOverflow.ellipsis,
                    style: effectiveStyle,
                  ),
                ),
              );
              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: children,
              );
            },
          ),
        );
      }).toList(),
    );
  }

  int get rowCount => _items.length;

  @override
  Future<bool> handlePageChange(int oldPageIndex, int newPageIndex) async {
    _currentPage = newPageIndex;
    _buildRows();
    notifyListeners();
    _syncControllerSelection();
    return true;
  }

  void updatePageSize(int newSize) {
    pageSize = newSize;
    _currentPage = 0;
    _buildRows();
    notifyListeners();
    _syncControllerSelection();
  }

  void setRowBuilder(List<Widget> Function(U data)? builder) {
    rowBuilder = builder;
    // No requiere reconstruir filas calculadas, solo la representación.
    notifyListeners();
  }

  void setShowSelectionColumn(bool show) {
    if (showSelectionColumn == show) return;
    showSelectionColumn = show;
    _buildRows();
    notifyListeners();
  }

  void notifySelectionChanged() {
    // Útil para refrescar cuando cambian selecciones externas (header checkbox)
    _buildRows();
    notifyListeners();
    _syncControllerSelection();
  }
}
