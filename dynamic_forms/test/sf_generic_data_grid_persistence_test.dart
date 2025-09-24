import 'package:dynamic_forms/dynamic_forms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Modelo simple
class _Item extends ListableModel<_Item> {
  _Item(this.id, this.name);
  final int id;
  final String name;
  @override
  bool contains(String value) => name.toLowerCase().contains(value.toLowerCase());
  Map<String, dynamic> toJson() => {'id': id, 'name': name};
  @override
  int compareTo(_Item other) => id.compareTo(other.id);
}

class _Config extends FormConfiguration2<_Item> {
  _Config({required super.context});
  @override
  List<FormFieldDefinition> get fields => [
        FormFieldDefinition(
          fieldName: 'name',
          label: 'Name',
          fieldType: FieldType.text,
          isListable: true,
        ),
      ];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SfGenericDataGrid rowsPerPage persistence', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    Widget _wrapGrid(Widget child) => MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 800,
                height: 600,
                child: child,
              ),
            ),
          ),
        );

    Future<void> _pumpGrid(
      WidgetTester tester, {
      int? mockInitialValue,
      bool persist = true,
      int? rowsPerPage,
    }) async {
      if (mockInitialValue != null) {
        SharedPreferences.setMockInitialValues({'global_rows_per_page': mockInitialValue});
      }
      await tester.pumpWidget(_wrapGrid(
        Builder(builder: (context) {
          return SfGenericDataGrid<_Config, _Item>(
            configuration: _Config(context: context),
            items: List.generate(40, (i) => _Item(i, 'Item $i')),
            columnCount: _Config(context: context).columnsCount,
            persistRowsPerPage: persist,
            rowsPerPage: rowsPerPage ?? 10,
          );
        }),
      ));
      // Primer frame
      await tester.pump();
      // Post frame callback + async SharedPreferences
      await tester.pump(const Duration(milliseconds: 50));
    }

    testWidgets('restaura valor persistido', (tester) async {
      await _pumpGrid(tester, mockInitialValue: 25);

      // Verifica que el Dropdown muestra 25
      final dropdown = tester.widget<DropdownButton<int>>(find.byType(DropdownButton<int>));
      expect(dropdown.value, 25);
    });

    testWidgets('cambia y persiste nuevo valor', (tester) async {
      await _pumpGrid(tester);

      // Abre el dropdown y selecciona 25
      await tester.tap(find.byType(DropdownButton<int>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('25').last);
      await tester.pumpAndSettle();

      // Verifica que el valor cambió
      DropdownButton<int> dropdown = tester.widget(find.byType(DropdownButton<int>));
      expect(dropdown.value, 25);

      // Ahora simula reconstrucción (nuevo widget) y que restaura 25
      await _pumpGrid(tester);
      dropdown = tester.widget(find.byType(DropdownButton<int>));
      expect(dropdown.value, 25);
    });

    testWidgets('desactivado no persiste', (tester) async {
      await _pumpGrid(tester, mockInitialValue: 50, persist: false, rowsPerPage: 10);

      final dropdown = tester.widget<DropdownButton<int>>(find.byType(DropdownButton<int>));
      expect(dropdown.value, 10); // Ignora preferencia porque está desactivado
    });
  });
}
