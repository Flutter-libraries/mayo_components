import 'dart:async';

import 'package:dynamic_forms/dynamic_forms.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';

enum DataGridSearchMode {
  /// Default. Filter rows locally based on `contains(query)`.
  local,

  /// No local filtering. Only `onSearchChanged` is called.
  /// Useful when filtering happens on the server.
  external,
}

class ServerPaginationConfig {
  const ServerPaginationConfig({
    required this.currentPage,
    required this.totalPages,
    required this.totalElements,
    required this.isFirstPage,
    required this.isLastPage,
    required this.onPageChange,
    this.isLoading = false,
    this.labelBuilder,
    this.rowsPerPage,
    this.availableRowsPerPage,
    this.onRowsPerPageChanged,
  });

  final int currentPage;
  final int totalPages;
  final int totalElements;
  final bool isFirstPage;
  final bool isLastPage;
  final ValueChanged<int> onPageChange;
  final bool isLoading;
  final String Function(ServerPaginationConfig config)? labelBuilder;
  final int? rowsPerPage;
  final List<int>? availableRowsPerPage;
  final ValueChanged<int>? onRowsPerPageChanged;
}

class SfGenericDataGrid<T extends FormConfiguration2<S>,
    S extends ListableModel<S>> extends StatefulWidget {
  const SfGenericDataGrid({
    super.key,
    required this.configuration,
    required this.items,
    required this.columnCount,
    this.selectedItems,
    this.columns,
    this.onEditItemTap,
    this.onRemoveItemTap,
    this.customRowAction,
    this.rowMenuActions,
    this.rowBuilder,
    this.toolbarActions,
    this.filtersWidget,
    this.setSelectedItems,
    this.actionsColumnName,
    this.rowsPerPage = 10,
    this.availableRowsPerPage = const [10, 25, 50, 100],
    this.showSearchField = true,
    this.searchValue,
    this.onSearchChanged,
    this.searchMode = DataGridSearchMode.local,
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
    this.showPager = true,
    this.initialSort,
    this.serverPagination,
    this.onSortChanged,
  }) : assert(
          searchMode == DataGridSearchMode.local || onSearchChanged != null,
          'If searchMode is external, onSearchChanged must be provided.',
        );

  final T configuration;
  final List<S> items;
  final int columnCount;

  /// Lista opcional de ítems que deben aparecer seleccionados al inicio
  /// (pre-selección). No fuerza selección controlada continua; se usa para
  /// inicializar el estado interno cuando cambia.
  final List<S>? selectedItems;
  final List<GridColumn>? columns;

  final void Function(S item)? onEditItemTap;
  final void Function(S item)? onRemoveItemTap;
  final Widget Function(S item)? customRowAction;
  // Acciones adicionales para el menú contextual de la última columna.
  final List<RowMenuAction<S>>? rowMenuActions;
  // Permite personalizar el contenido de las celdas de cada fila.
  // Debe devolver tantos widgets como columnas listables haya en configuration.
  final List<Widget> Function(S data)? rowBuilder;

  final List<Widget>? toolbarActions;
  final Widget? filtersWidget;
  final void Function(List<S> items)? setSelectedItems;

  /// Nombre opcional para la columna de acciones. Si no se especifica,
  /// la columna no tendrá header visible.
  final String? actionsColumnName;

  final int rowsPerPage;
  final List<int> availableRowsPerPage;
  final bool showSearchField;
  final String? searchValue;
  final ValueChanged<String>? onSearchChanged;
  final DataGridSearchMode searchMode;
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

  final bool showPager;
  final ServerPaginationConfig? serverPagination;

  /// Ordenamiento inicial aplicado al cargar los datos.
  /// Mapa de nombre de campo (fieldName) a dirección de ordenamiento.
  final Map<String, DataGridSortDirection>? initialSort;

  /// Callback invocado al ordenar columnas. Si se proporciona junto con
  /// [serverPagination], el grid delega el ordenamiento al servidor en lugar
  /// de ordenar localmente la página actual.
  final void Function(Map<String, DataGridSortDirection> sortMap)? onSortChanged;

  @override
  State<SfGenericDataGrid<T, S>> createState() =>
      _SfGenericDataGridState<T, S>();
}

class _SfGenericDataGridState<T extends FormConfiguration2<S>,
    S extends ListableModel<S>> extends State<SfGenericDataGrid<T, S>> {
  static const _searchDebounceDuration = Duration(milliseconds: 500);
  late _SfGenericDataSource<T, S> dataSource;
  late int _rowsPerPage;
  final DataGridController _controller = DataGridController();
  late List<S> _allItems;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  // Selección acumulada (a través de páginas y filtros)
  final List<S> _selected = <S>[];
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _rowsPerPage = widget.rowsPerPage;
    _allItems = widget.items;
    _searchQuery = widget.searchValue ?? '';
    _searchController.text = _searchQuery;
    // Pre-selección externa inicial
    if (widget.selectedItems != null && widget.selectedItems!.isNotEmpty) {
      _selected.clear();
      for (final s in widget.selectedItems!) {
        if (!_selected.contains(s)) _selected.add(s);
      }
    }
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
      rowMenuActions: widget.rowMenuActions,
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
      initialSort: widget.initialSort,
      onSortChanged: widget.serverPagination != null ? widget.onSortChanged : null,
    );
    // Aplicar ordenamiento inicial si está configurado
    if (widget.initialSort != null && widget.initialSort!.isNotEmpty) {
      dataSource.applyInitialSort();
    }
    // Only apply initial filter if local mode or if we need to sync UI
    if (widget.searchMode == DataGridSearchMode.local) {
      if (widget.onSearchChanged == null && _searchQuery.isNotEmpty) {
        _applyFilter(_searchQuery);
      }
    }
  }

  void _restoreRowsPerPagePreference() {
    final key = widget.preferenceKey ?? 'global_rows_per_page';
    // Cargamos async tras primer frame para no bloquear initState.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final prefs = await SharedPreferences.getInstance();
        final stored = prefs.getInt(key);
        if (stored != null &&
            stored != _rowsPerPage &&
            widget.availableRowsPerPage.contains(stored)) {
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
    if (oldWidget.rowMenuActions != widget.rowMenuActions) {
      dataSource.setRowMenuActions(widget.rowMenuActions);
    }
    if (oldWidget.items != widget.items ||
        oldWidget.configuration != widget.configuration) {
      _allItems = widget.items;
      if (widget.searchMode == DataGridSearchMode.local) {
        if (widget.onSearchChanged == null) {
          _searchDebounce?.cancel();
          _applyFilter(_searchQuery);
        } else {
          dataSource.setItems(_allItems);
        }
      } else {
        // In external mode, items are already filtered by parent
        dataSource.setItems(_allItems);
      }
      // Reaplicar ordenamiento inicial si está configurado
      if (widget.initialSort != null && widget.initialSort!.isNotEmpty) {
        dataSource.applyInitialSort();
      }
    }
    // Sincronizar pre-selección externa si cambia la referencia de la lista
    if (oldWidget.selectedItems != widget.selectedItems) {
      _selected.clear();
      if (widget.selectedItems != null) {
        _selected.addAll(widget.selectedItems!);
      }
      dataSource.notifySelectionChanged();
      widget.setSelectedItems?.call(List<S>.unmodifiable(_selected));
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
    if (oldWidget.searchValue != widget.searchValue &&
        widget.searchValue != _searchController.text) {
      final newValue = widget.searchValue ?? '';
      _searchQuery = newValue;
      _searchController.text = newValue;
      if (widget.searchMode == DataGridSearchMode.local) {
        if (widget.onSearchChanged == null) {
          _searchDebounce?.cancel();
          _applyFilter(newValue);
        }
      }
    }
    if (oldWidget.rowsPerPage != widget.rowsPerPage) {
      setState(() {
        _rowsPerPage = widget.rowsPerPage;
        dataSource.updatePageSize(_rowsPerPage);
      });
    }
  }

  void _applyFilter(String query) {
    _searchQuery = query;
    if (widget.searchMode == DataGridSearchMode.external) {
      // Should not be called in external mode, but safe guard
      return;
    }
    if (query.isEmpty) {
      dataSource.setItems(_allItems);
      return;
    }
    final q = query.toLowerCase();
    final filtered = _allItems.where((e) => e.contains(q)).toList();
    dataSource.setItems(filtered);
  }

  void _handleSearchChanged(String value) {
    _searchQuery = value;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(_searchDebounceDuration, () {
      if (!mounted) return;
      if (widget.onSearchChanged != null) {
        widget.onSearchChanged!(_searchQuery);
      } else if (widget.searchMode == DataGridSearchMode.local) {
        _applyFilter(_searchQuery);
      }
    });
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

    // Detectar si estamos en una pantalla móvil
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    final children = <Widget>[];
    final hasTopBarContent = widget.showSearchField ||
        widget.toolbarActions != null ||
        widget.filtersWidget != null;
    if (hasTopBarContent) {
      children.add(
        isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.filtersWidget != null) ...[
                    SizedBox(
                      width: double.infinity,
                      child: widget.filtersWidget!,
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (widget.showSearchField)
                    SizedBox(
                      width: double.infinity,
                      child: TextField(
                        controller: _searchController,
                        decoration:
                            const InputDecoration(hintText: 'Buscar...'),
                        onChanged: _handleSearchChanged,
                      ),
                    ),
                  if (widget.toolbarActions != null) ...[
                    const SizedBox(height: 8),
                    Row(children: widget.toolbarActions!),
                  ],
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.filtersWidget != null) ...[
                    Flexible(child: widget.filtersWidget!),
                    const SizedBox(width: 16),
                  ],
                  if (widget.toolbarActions != null) ...[
                    Row(children: widget.toolbarActions!),
                    if (widget.showSearchField) const SizedBox(width: 16),
                  ],
                  if (widget.showSearchField) ...[
                    const Spacer(),
                    SizedBox(
                      width: 320,
                      child: TextField(
                        controller: _searchController,
                        decoration:
                            const InputDecoration(hintText: 'Buscar...'),
                        onChanged: _handleSearchChanged,
                      ),
                    ),
                  ],
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
      if (widget.serverPagination != null) {
        children.add(
          _buildServerPaginationFooter(
            context: context,
            pager: widget.serverPagination!,
            footerBg: footerBg,
            gridLine: gridLine,
          ),
        );
      }
      return Column(children: children);
    }
    // Construimos el grid una vez y lo envolvemos condicionalmente en Expanded cuando hay datos.
    children.add(
      (() {
        final gridChild = Builder(
          builder: (context) {
            Widget grid = SfDataGrid(
              source: dataSource,
              isScrollbarAlwaysShown: true,
              controller: _controller,
              allowSorting: widget.allowSorting,
              selectionMode: widget.allowRowSelection
                  ? (widget.allowMultiSelection
                      ? SelectionMode.multiple
                      : SelectionMode.single)
                  : SelectionMode.none,
              columnWidthMode: isMobile
                  ? ColumnWidthMode.fitByColumnName
                  : widget.columnWidthMode,
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
                widget.setSelectedItems?.call(List<S>.unmodifiable(_selected));
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
            // Envolver en SingleChildScrollView si es necesario para scroll horizontal
            // if (isMobile) {
            //   return SingleChildScrollView(
            //     scrollDirection: Axis.horizontal,
            //     child: grid,
            //   );
            // }
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
    final hasServerPager = widget.serverPagination != null;
    if (hasServerPager) {
      children.add(
        _buildServerPaginationFooter(
          context: context,
          pager: widget.serverPagination!,
          footerBg: footerBg,
          gridLine: gridLine,
        ),
      );
    } else if (widget.items.isNotEmpty && widget.showPager) {
      children.add(
        Container(
          // height: 56,
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
          child: isMobile
              ? Column(
                  children: [
                    // Selector de filas por página
                    Row(
                      children: [
                        Text(
                          'Filas por página:',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(width: 8),
                        DropdownButton<int>(
                          value: _rowsPerPage,
                          items: widget.availableRowsPerPage
                              .map((v) => DropdownMenuItem<int>(
                                    value: v,
                                    child: Text(
                                      '$v',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
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
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Paginador centrado
                    Center(
                      child: Builder(
                        builder: (context) {
                          Widget pager = SfDataPager(
                            delegate: dataSource,
                            pageCount: (dataSource.rowCount / _rowsPerPage)
                                .ceilToDouble(),
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
                    ),
                  ],
                )
              : Row(
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
                          pageCount: (dataSource.rowCount / _rowsPerPage)
                              .ceilToDouble(),
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
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildServerPaginationFooter({
    required BuildContext context,
    required ServerPaginationConfig pager,
    required Color? footerBg,
    required Color? gridLine,
  }) {
    final int displayTotalPages = pager.totalPages <= 0 ? 1 : pager.totalPages;
    final int displayCurrentPage = pager.totalPages <= 0
        ? 0
        : ((pager.currentPage + 1).clamp(1, displayTotalPages)).toInt();
    final label = pager.labelBuilder?.call(pager) ??
        'Total: ${pager.totalElements} | Page $displayCurrentPage of $displayTotalPages';
    final rowsPerPage = pager.rowsPerPage ?? _rowsPerPage;
    final rawOptions =
        pager.availableRowsPerPage ?? widget.availableRowsPerPage;
    final options = List<int>.from(rawOptions);
    if (options.isEmpty) {
      options.add(rowsPerPage);
    } else if (!options.contains(rowsPerPage)) {
      options.add(rowsPerPage);
      options.sort();
    }
    final normalizedRowsPerPage =
        options.contains(rowsPerPage) ? rowsPerPage : options.first;
    final dropdownDisabled =
        pager.isLoading || pager.onRowsPerPageChanged == null;
    return Container(
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 720;
          final selector = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Filas por página:',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: normalizedRowsPerPage,
                items: options
                    .map(
                      (v) => DropdownMenuItem<int>(
                        value: v,
                        child: Text(
                          '$v',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: dropdownDisabled
                    ? null
                    : (value) {
                        if (value == null ||
                            value == normalizedRowsPerPage ||
                            pager.onRowsPerPageChanged == null) {
                          return;
                        }
                        pager.onRowsPerPageChanged!(value);
                      },
              ),
            ],
          );
          final pagerButtons = Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: pager.isFirstPage || pager.isLoading
                    ? null
                    : () => pager.onPageChange(pager.currentPage - 1),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: pager.isLastPage || pager.isLoading
                    ? null
                    : () => pager.onPageChange(pager.currentPage + 1),
              ),
            ],
          );
          final labelWidget = Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          );
          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                labelWidget,
                const SizedBox(height: 12),
                selector,
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: pagerButtons,
                ),
              ],
            );
          }
          return Row(
            children: [
              labelWidget,
              selector,
              const SizedBox(width: 16),
              pagerButtons,
            ],
          );
        },
      ),
    );
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
        widget.customRowAction != null ||
        (widget.rowMenuActions != null && widget.rowMenuActions!.isNotEmpty)) {
      // Si hay customRowAction, necesitamos más ancho para evitar desbordes.
      final actionsWidthOverride = widget.columnWidths?['__actions__'];
      // final hasMenu =
      //     widget.rowMenuActions != null && widget.rowMenuActions!.isNotEmpty;
      final defaultActionsWidth = 80.0;
      cols.add(
        GridColumn(
          columnName: '__actions__',
          width: actionsWidthOverride ?? defaultActionsWidth,
          allowSorting: false,
          label: widget.actionsColumnName != null
              ? labeler(widget.actionsColumnName!)
              : const SizedBox.shrink(),
        ),
      );
    }
    return cols;
  }
}

/// Representa una acción que se muestra dentro del menú contextual (PopupMenu)
/// de cada fila en la columna de acciones.
class RowMenuAction<S> {
  const RowMenuAction({
    required this.icon,
    this.label,
    this.labelBuilder,
    required this.onTap,
    this.enabled = true,
    this.enabledBuilder,
  }) : assert(label != null || labelBuilder != null,
            'Debes proporcionar label o labelBuilder');
  final IconData icon;

  /// Etiqueta estática. Si se necesita dinámica usar [labelBuilder].
  final String? label;

  /// Función para generar la etiqueta a partir del item de la fila.
  final String Function(S item)? labelBuilder;
  final void Function(S item) onTap;

  /// Enabled estático. Para lógica por fila usar [enabledBuilder].
  final bool enabled;

  /// Permite habilitar/deshabilitar por fila.
  final bool Function(S item)? enabledBuilder;
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
    this.rowMenuActions,
    this.rowBuilder,
    this.rowTextStyle,
    this.showSelectionColumn = false,
    bool Function(U item)? isItemSelected,
    void Function(U item, bool checked)? onRowCheckboxChanged,
    this.onSyncSelection,
    this.initialSort,
    this.onSortChanged,
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
  List<RowMenuAction<U>>? rowMenuActions;
  List<Widget> Function(U data)? rowBuilder;
  final TextStyle? rowTextStyle;
  bool showSelectionColumn;
  late bool Function(U item) _isItemSelected;
  late void Function(U item, bool checked) _onRowCheckboxChanged;
  final void Function(List<DataGridRow> selectedRows)? onSyncSelection;
  final Map<String, DataGridSortDirection>? initialSort;
  final void Function(Map<String, DataGridSortDirection> sortMap)? onSortChanged;

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
            customRowAction != null ||
            (rowMenuActions != null && rowMenuActions!.isNotEmpty))
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

  void _applySort(Map<String, DataGridSortDirection> sortMap) {
    if (sortMap.isEmpty) return;

    int compare(dynamic a, dynamic b) {
      if (a == null || b == null) {
        if (a == null && b == null) return 0;
        return a == null ? -1 : 1;
      }
      if (a is num && b is num) return a.compareTo(b);
      if (a is bool && b is bool) return (a == b) ? 0 : (a ? 1 : -1);
      if (a is DateTime && b is DateTime) return a.compareTo(b);
      // Handle date strings (ISO8601 format)
      if (a is String && b is String) {
        final dateA = DateTime.tryParse(a);
        final dateB = DateTime.tryParse(b);
        if (dateA != null && dateB != null) {
          return dateA.compareTo(dateB);
        }
        // Fallback to string comparison if not dates
        return a.compareTo(b);
      }
      return 0;
    }

    _items.sort((a, b) {
      // Aplicar ordenamiento por cada columna en orden de prioridad
      for (final entry in sortMap.entries) {
        final fieldName = entry.key;
        final direction = entry.value;
        final va = a.getValue<dynamic>(fieldName);
        final vb = b.getValue<dynamic>(fieldName);
        final r = compare(va, vb);
        if (r != 0) {
          // Si hay diferencia, aplicar dirección y retornar
          return direction == DataGridSortDirection.ascending ? r : -r;
        }
        // Si son iguales, continuar con el siguiente criterio
      }
      return 0; // Todos los criterios son iguales
    });

    _buildRows();
    notifyListeners();
    _syncControllerSelection();
  }

  @override
  Future<void> sort() async {
    if (sortedColumns.isEmpty) return;

    // Construir mapa de ordenamiento desde sortedColumns
    final sortMap = <String, DataGridSortDirection>{};
    for (final sortCol in sortedColumns) {
      sortMap[sortCol.name] = sortCol.sortDirection;
    }

    if (onSortChanged != null) {
      onSortChanged!(sortMap);
      return;
    }

    _applySort(sortMap);
  }

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final fields = configuration.fields.where((f) => f.isListable).toList();
    int index = 0; // Se usa para mapear columnas listables
    // Obtiene el item real para que rowBuilder pueda usarlo si está definido.
    final U item = row
        .getCells()
        .firstWhere((c) => c.columnName == '__index__')
        .value as U;
    final customCells = rowBuilder?.call(item);
    final bool canUseCustom =
        customCells != null && customCells.length == fields.length;
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((cell) {
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
          final item = row
              .getCells()
              .firstWhere((c) => c.columnName == '__index__')
              .value as U;
          final hasEdit = onEditItemTap != null;
          final hasRemove = onRemoveItemTap != null;
          final hasCustom = customRowAction != null;
          final hasExtraMenuActions =
              rowMenuActions != null && rowMenuActions!.isNotEmpty;
          final showPopup = hasEdit || hasRemove || hasExtraMenuActions;

          final children = <Widget>[];
          if (hasCustom) {
            children.add(customRowAction!(item));
          }
          if (showPopup) {
            // Construimos lista combinada: primero Edit, luego Remove, luego acciones dinámicas existentes.
            children.add(
              PopupMenuButton<int>(
                icon: const Icon(Icons.more_vert, size: 18),
                onSelected: (index) {
                  int cursor = 0;
                  // Edit
                  if (hasEdit) {
                    if (index == cursor) {
                      onEditItemTap?.call(item);
                      return;
                    }
                    cursor++;
                  }
                  // Remove
                  if (hasRemove) {
                    if (index == cursor) {
                      onRemoveItemTap?.call(item);
                      return;
                    }
                    cursor++;
                  }
                  // Resto de acciones configuradas
                  if (hasExtraMenuActions) {
                    final rmIndex =
                        index - cursor; // índice relativo en rowMenuActions
                    if (rmIndex >= 0 && rmIndex < rowMenuActions!.length) {
                      final action = rowMenuActions![rmIndex];
                      final enabled = action.enabledBuilder != null
                          ? action.enabledBuilder!(item)
                          : action.enabled;
                      if (enabled) action.onTap(item);
                    }
                  }
                },
                itemBuilder: (context) {
                  final entries = <PopupMenuEntry<int>>[];
                  int nextIndex = 0;
                  if (hasEdit) {
                    entries.add(
                      PopupMenuItem<int>(
                        value: nextIndex++,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Flexible(child: Text('Edit')),
                          ],
                        ),
                      ),
                    );
                  }
                  if (hasRemove) {
                    entries.add(
                      PopupMenuItem<int>(
                        value: nextIndex++,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.delete_outline, size: 18),
                            SizedBox(width: 8),
                            Flexible(child: Text('Remove')),
                          ],
                        ),
                      ),
                    );
                  }
                  if (hasExtraMenuActions) {
                    for (var i = 0; i < rowMenuActions!.length; i++) {
                      final action = rowMenuActions![i];
                      final enabled = action.enabledBuilder != null
                          ? action.enabledBuilder!(item)
                          : action.enabled;
                      final text = action.labelBuilder != null
                          ? action.labelBuilder!(item)
                          : (action.label ?? '');
                      entries.add(
                        PopupMenuItem<int>(
                          enabled: enabled,
                          value: nextIndex++,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(action.icon, size: 18),
                              const SizedBox(width: 8),
                              Flexible(child: Text(text)),
                            ],
                          ),
                        ),
                      );
                    }
                  }
                  return entries;
                },
              ),
            );
          }
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: children,
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
              final localized = opt.label.isNotEmpty ? opt.label : (v ?? '');
              return localized;
            case FieldType.dropdownMultiple:
              final v = cell.value as List<String>?;
              if (v == null || v.isEmpty) return '';
              // Mapear cada valor a su DropdownOption para obtener el label localizado.
              final mappedOptions = v.map((val) {
                return field.options.firstWhere(
                  (o) => o.value == val,
                  orElse: () => DropdownOption(label: val, value: val),
                );
              }).toList();
              return mappedOptions.join(', ');
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

              // Caso especial para dropdownMultiple con iconos
              if (field.fieldType == FieldType.dropdownMultiple) {
                final v = cell.value as List<String>?;
                if (v != null && v.isNotEmpty) {
                  final mappedOptions = v.map((val) {
                    return field.options.firstWhere(
                      (o) => o.value == val,
                      orElse: () => DropdownOption(label: val, value: val),
                    );
                  }).toList();

                  return Wrap(
                    spacing: 4,
                    runSpacing: 2,
                    children: mappedOptions.map((opt) {
                      return Chip(
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        labelPadding: EdgeInsets.zero,
                        avatar: opt.emoji != null
                            ? Text(
                                opt.emoji!,
                                style: const TextStyle(fontSize: 14),
                              )
                            : opt.icon != null
                                ? Icon(
                                    opt.icon,
                                    size: 14,
                                    color: effectiveStyle.color,
                                  )
                                : null,
                        label: Text(
                          opt.label,
                          style: effectiveStyle.copyWith(fontSize: 12),
                        ),
                        backgroundColor:
                            opt.backgroundColor ?? cellBackgroundColor,
                        side: BorderSide.none,
                      );
                    }).toList(),
                  );
                }
              }

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

  void setRowMenuActions(List<RowMenuAction<U>>? actions) {
    if (rowMenuActions == actions) return;
    rowMenuActions = actions;
    _buildRows();
    notifyListeners();
  }

  void applyInitialSort() {
    if (initialSort != null && initialSort!.isNotEmpty) {
      _applySort(initialSort!);
    }
  }
}
