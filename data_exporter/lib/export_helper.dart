import 'features/csv_exporter_mobile.dart'
  if (dart.library.html) 'features/csv_exporter_web.dart';
import 'features/pdf_exporter_mobile.dart' if (dart.library.html) 'features/pdf_exporter_web.dart';
import 'features/csv_exporter.dart';

/// Formatos soportados.
enum DataExportFormat { csv, pdf }

/// Servicio fachada para exportar datos tabulares.
/// dataList: primera fila = cabecera.
class DataExporterService {
  DataExporterService({Exporter? csvExporter, Exporter? pdfExporter})
      : _csv = csvExporter ?? CSVExporter(),
        _pdf = pdfExporter ?? PDFExporter();

  final Exporter _csv;
  final Exporter _pdf;

  Future<void> export({
    required DataExportFormat format,
    required String filename,
    required List<List<String>> data,
    bool landscape = false,
  }) async {
    if (data.isEmpty) {
      throw ArgumentError('data no puede estar vacío');
    }
    switch (format) {
      case DataExportFormat.csv:
        final name = filename.toLowerCase().endsWith('.csv')
            ? filename
            : '$filename.csv';
  await _csv.export(name, data, landscape: landscape);
        break;
      case DataExportFormat.pdf:
        final name = filename.toLowerCase().endsWith('.pdf')
            ? filename
            : '$filename.pdf';
  await _pdf.export(name, data, landscape: landscape);
        break;
    }
  }
}
