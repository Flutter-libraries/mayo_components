import 'dart:html' as html;

import 'package:data_exporter/features/excel_helper.dart';

import 'csv_exporter.dart';

class ExcelExporter implements Exporter {
  @override
  Future<void> export(
    String filename,
    List<List<String>> dataList, {
    bool landscape = false,
  }) async {
    final bytes = buildExcelBytes(dataList);
    final blob = html.Blob(
      [bytes],
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    );
    final url = html.Url.createObjectUrlFromBlob(blob);

    html.AnchorElement(href: url)
      ..setAttribute('download', normalizeExcelFilename(filename))
      ..click();

    html.Url.revokeObjectUrl(url);
  }
}
