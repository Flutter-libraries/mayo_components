import 'dart:html' as html;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'csv_exporter.dart';

class PDFExporter implements Exporter {
  @override
  Future<void> export(String filename, List<List<String>> dataList, {bool landscape = false}) async {
    if (!filename.toLowerCase().endsWith('.pdf')) {
      filename = '$filename.pdf';
    }

    final pdf = pw.Document();
    if (dataList.isEmpty) {
      pdf.addPage(pw.Page(build: (_) => pw.Center(child: pw.Text('Sin datos'))));
    } else {
      final headers = dataList.first;
      final rows = dataList.skip(1).toList();
      pdf.addPage(
        pw.MultiPage(
          pageFormat: landscape ? PdfPageFormat.a4.landscape : PdfPageFormat.a4,
          build: (_) => [
            pw.Table.fromTextArray(
              headers: headers,
              data: rows,
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFE0E0E0)),
              cellStyle: const pw.TextStyle(fontSize: 9),
              cellAlignment: pw.Alignment.centerLeft,
            ),
          ],
        ),
      );
    }

    final bytes = await pdf.save();
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();
    html.Url.revokeObjectUrl(url);
  }
}
