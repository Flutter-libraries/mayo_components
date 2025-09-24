import 'dart:convert';
import 'dart:html' as html;

import 'package:data_exporter/features/list_to_csv.dart';

import 'csv_exporter.dart';

class CSVExporter implements Exporter {
  @override
  Future<void> export(String filename, List<List<String>> dataList, {bool landscape = false}) async {
    final data = listToCsv(dataList);
    final bytes = utf8.encode(data);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);

    html.AnchorElement(href: url)
      ..setAttribute("download", filename)
      ..click();

    html.Url.revokeObjectUrl(url);
  }
}
