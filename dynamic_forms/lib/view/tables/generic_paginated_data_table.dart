import 'package:dynamic_forms/dynamic_forms.dart';
import 'package:flutter/material.dart';

class GenericPaginatedDataTable<
  T extends FormConfiguration2<S>,
  S extends ListableModel<S>
>
    extends StatefulWidget {
  const GenericPaginatedDataTable({
    required this.configuration,
    required this.comparableItems,
    required this.columnCount,
    this.columns,
    super.key,
    this.onEditItemTap,
    this.onRemoveItemTap,
    this.customRowAction,
    this.rowBuilder,
    this.setSelectedItems,
    this.actions,
    this.toolbarActions,
    this.initialSelectedItems,
    this.showSearchField = true,
    this.showEmptyRows = false,
    this.rowsMin = false,
    this.availableRowsPerPage = const [10, 25, 50, 100],
    this.maxColumnWidth = 100.0,
    this.maxActionColumnWidth = 80.0,
    this.initialSortColumn = 0,
    this.initialSortAscending = true,
    this.sort = true,
  });

  final T configuration;
  final List<S> comparableItems;
  final int columnCount;
  final List<DataColumn>? columns;

  final void Function(S item)? onEditItemTap;
  final void Function(S iitem)? onRemoveItemTap;
  final Widget Function(S item)? customRowAction;

  final List<Widget> Function(S data)? rowBuilder;

  final void Function(List<S> items)? setSelectedItems;

  final List<S>? initialSelectedItems;

  final List<Widget>? actions;
  final List<Widget>? toolbarActions;

  final bool showSearchField;
  final bool showEmptyRows;
  final bool rowsMin;
  final List<int> availableRowsPerPage;
  final double maxColumnWidth;
  final double maxActionColumnWidth;

  final int initialSortColumn;
  final bool initialSortAscending;
  final bool sort;

  @override
  _GenericPaginatedDataTableState<T, S> createState() =>
      _GenericPaginatedDataTableState<T, S>();
}

class _GenericPaginatedDataTableState<
  T extends FormConfiguration2<S>,
  S extends ListableModel<S>
>
    extends State<GenericPaginatedDataTable<T, S>> {
  int _columnIndex = 0;
  bool _columnAscending = true;
  int? _rowsPerPage;
  bool _initialized = false;

  late GenericDataTableSource2<T, S> dataSource;
  late List<S> comparableItems;

  void _sort(int columnIndex, bool ascending) {
    setState(() {
      _columnIndex = columnIndex;
      _columnAscending = ascending;
      dataSource.setData(
        comparableItems,
        sortColumn: widget.sort ? _columnIndex : null,
        sortAscending: widget.sort ? _columnAscending : null,
      );
    });
  }

  @override
  void didUpdateWidget(covariant GenericPaginatedDataTable<T, S> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.comparableItems != widget.comparableItems) {
      comparableItems = widget.comparableItems;

      _columnIndex = 0;
      _columnAscending = true;

      _createDataSource();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    comparableItems = widget.comparableItems;

    if (!_initialized) {
      _rowsPerPage = null;
      _initialized = true;
      _createDataSource();
    } else {
      dataSource.setData(
        comparableItems,
        sortColumn: widget.sort ? _columnIndex : null,
        sortAscending: widget.sort ? _columnAscending : null,
      );
    }
  }

  @override
  void dispose() {
    dataSource
      ..dispose()
      ..removeListener(() {
        widget.setSelectedItems?.call(dataSource.selected);
      });
    super.dispose();
  }

  void _createDataSource() {
    dataSource = GenericDataTableSource2(
      configuration: widget.configuration,
      context: context,
      displayIndexToRawIndex: const [0, 1],
      columnCount: widget.comparableItems.isEmpty
          ? 1
          : widget.columnCount +
                (widget.onEditItemTap != null ||
                        widget.onRemoveItemTap != null ||
                        widget.customRowAction != null
                    ? 1
                    : 0),
      onEditItemTap: widget.onEditItemTap,
      onRemoveItemTap: widget.onRemoveItemTap,
      customRowAction: widget.customRowAction,
      rowBuilder: widget.rowBuilder,
      maxColumnWidth: widget.maxColumnWidth,
    );

    dataSource.setData(
      comparableItems,
      sortColumn: widget.sort ? 0 : null,
      sortAscending: widget.sort ? true : null,
    );

    if (widget.initialSelectedItems != null) {
      dataSource.setSelected(widget.initialSelectedItems!);
    }

    dataSource.addListener(() {
      widget.setSelectedItems?.call(dataSource.selected);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 600),
        child: PaginatedDataTable(
          key: ValueKey(
            'paginated_table_${widget.availableRowsPerPage.join('_')}',
          ),
          sortColumnIndex: _columnIndex,
          sortAscending: _columnAscending,
          source: dataSource,
          onSelectAll: (value) {
            dataSource.setSelectedAll(value ?? false);
          },
          header: widget.showSearchField
              ? TextField(
                  decoration: const InputDecoration(hintText: 'Buscar...'),
                  onChanged: (data) {
                    final filter = comparableItems
                        .where((item) => item.contains(data.toLowerCase()))
                        .toList();
                    dataSource.setData(
                      filter,
                      sortColumn: widget.sort ? _columnIndex : null,
                      sortAscending: widget.sort ? _columnAscending : null,
                    );
                  },
                )
              : null,
          actions: widget.toolbarActions,
          columns: _buildColumns,
          showCheckboxColumn: widget.setSelectedItems != null,
          showEmptyRows: widget.showEmptyRows,
          rowsPerPage: widget.rowsMin
              ? widget.comparableItems.isNotEmpty
                    ? widget.comparableItems.length
                    : 1
              : () {
                  final validOptions = widget.availableRowsPerPage
                      .where(
                        (value) =>
                            value <= widget.comparableItems.length ||
                            widget.comparableItems.isEmpty,
                      )
                      .toList();
                  final currentValue =
                      _rowsPerPage ?? widget.availableRowsPerPage.first;

                  if (validOptions.contains(currentValue)) {
                    return currentValue;
                  } else {
                    return validOptions.isNotEmpty
                        ? validOptions.first
                        : widget.availableRowsPerPage.first;
                  }
                }(),
          availableRowsPerPage: widget.rowsMin
              ? [
                  if (widget.comparableItems.isNotEmpty)
                    widget.comparableItems.length
                  else
                    1,
                ]
              : widget.availableRowsPerPage,
          onRowsPerPageChanged: widget.rowsMin
              ? null
              : (value) {
                  setState(() {
                    _rowsPerPage = value;
                  });
                },
        ),
      ),
    );
  }

  List<DataColumn> get _buildColumns => [
    if (widget.columns != null)
      ...widget.columns!.map(
        (column) => DataColumn(
          label: column.label,
          onSort: column.onSort,
          numeric: column.numeric,
          tooltip: column.tooltip,
        ),
      )
    else
      ...widget.configuration.fields
          .where((e) => e.isListable)
          .map((e) => DataColumn(label: Text(e.label), onSort: _sort)),
    if (widget.onEditItemTap != null ||
        widget.onRemoveItemTap != null ||
        widget.customRowAction != null)
      const DataColumn(label: Text('')),
  ];
}
