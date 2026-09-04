import 'dart:io';

import 'package:data_exporter/features/excel_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'csv_exporter.dart';

class ExcelExporter implements Exporter {
  @override
  Future<void> export(
    String filename,
    List<List<String>> dataList, {
    bool landscape = false,
  }) async {
    final bytes = buildExcelBytes(dataList);
    final normalizedFilename = normalizeExcelFilename(filename);
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$normalizedFilename');
    await file.writeAsBytes(bytes, flush: true);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Descarga tu Excel',
    );
  }
}
