import 'package:data_exporter/features/excel_helper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('buildExcelBytes', () {
    test('generates non-empty xlsx bytes with header and rows', () {
      final bytes = buildExcelBytes([
        ['ID', 'Name', 'Hits'],
        ['1', 'Route A', '100'],
        ['2', 'Route B', '50'],
      ]);

      expect(bytes, isNotEmpty);
      expect(bytes.length, greaterThan(100));
      // XLSX files are ZIP archives starting with PK
      expect(bytes[0], equals(0x50));
      expect(bytes[1], equals(0x4B));
    });

    test('handles empty data list', () {
      final bytes = buildExcelBytes([]);

      expect(bytes, isNotEmpty);
    });
  });

  group('normalizeExcelFilename', () {
    test('appends xlsx extension when missing', () {
      expect(normalizeExcelFilename('top_routes'), 'top_routes.xlsx');
    });

    test('keeps existing xlsx extension', () {
      expect(normalizeExcelFilename('top_routes.xlsx'), 'top_routes.xlsx');
    });
  });
}
