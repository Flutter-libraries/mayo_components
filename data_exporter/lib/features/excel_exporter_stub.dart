import 'csv_exporter.dart';

class ExcelExporter implements Exporter {
  @override
  Future<void> export(
    String filename,
    List<List<String>> dataList, {
    bool landscape = false,
  }) async {
    throw UnimplementedError('Exportación Excel no soportada en esta plataforma');
  }
}
