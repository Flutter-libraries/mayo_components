import 'dart:io';
import 'package:data_exporter/features/list_to_csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'csv_exporter.dart';

class CSVExporter implements Exporter {
  @override
  Future<void> export(String filename, List<List<String>> dataList, {bool landscape = false}) async {
    try {

      final data = listToCsv(dataList);
      
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$filename');
      await file.writeAsString(data);

      // Compartimos el archivo
      await Share.shareXFiles([XFile(file.path)], text: "Descarga tu CSV");
    } catch (e) {
      print("Error al exportar CSV: $e");
    }
  }
}

