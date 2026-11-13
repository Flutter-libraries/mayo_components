import 'package:flutter_test/flutter_test.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

/// Mirrors [_SfGenericDataSource.performSorting] remote-sort behavior.
class _RemoteSortProbe extends DataGridSource {
  _RemoteSortProbe({this.onSortChanged});

  final void Function(Map<String, DataGridSortDirection> sortMap)? onSortChanged;

  final List<DataGridRow> _rows = [
    DataGridRow(cells: [
      DataGridCell<num>(columnName: 'n', value: 10),
    ]),
    DataGridRow(cells: [
      DataGridCell<num>(columnName: 'n', value: 2),
    ]),
  ];

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) => null;

  @override
  Future<void> performSorting(List<DataGridRow> rows) async {
    if (onSortChanged != null) {
      return;
    }
    await super.performSorting(rows);
  }
}

class _LocalSortProbe extends _RemoteSortProbe {
  _LocalSortProbe() : super(onSortChanged: null);
}

void main() {
  group('server-side sort delegation', () {
    test('performSorting is no-op when onSortChanged is set', () async {
      final source = _RemoteSortProbe(onSortChanged: (_) {});
      source.sortedColumns.add(
        const SortColumnDetails(
          name: 'n',
          sortDirection: DataGridSortDirection.ascending,
        ),
      );

      final rows = source.rows.toList();
      await source.performSorting(rows);

      expect(
        rows.first.getCells().first.value,
        10,
        reason: 'remote mode must not reorder rows locally',
      );
    });

    test('performSorting still runs locally when onSortChanged is null', () async {
      final source = _LocalSortProbe();
      source.sortedColumns.add(
        const SortColumnDetails(
          name: 'n',
          sortDirection: DataGridSortDirection.ascending,
        ),
      );

      final rows = source.rows.toList();
      await source.performSorting(rows);

      expect(rows.first.getCells().first.value, 2);
    });
  });
}
