import 'package:data_exporter/features/csv_exporter.dart';

class StubExporter implements Exporter {
  @override
  Future<void> export(String filename, List<List<String>> dataList) async {
    throw UnimplementedError("Exportación no soportada en esta plataforma");
  }
}
