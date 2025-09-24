import 'csv_exporter.dart';

class PDFExporter implements Exporter {
  @override
  Future<void> export(String filename, List<List<String>> dataList, {bool landscape = false}) async {
    throw UnimplementedError('Exportación PDF no soportada en esta plataforma');
  }
}
