import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:share_plus/share_plus.dart';
import 'csv_exporter.dart';

/// Exporta una tabla (dataList) a un PDF simple.
class PDFExporter implements Exporter {
  @override
  Future<void> export(String filename, List<List<String>> dataList, {bool landscape = false}) async {
    if (!filename.toLowerCase().endsWith('.pdf')) {
      filename = '$filename.pdf';
    }
    final pdf = pw.Document();

    if (dataList.isEmpty) {
      pdf.addPage(pw.Page(
        build: (_) => pw.Center(child: pw.Text('Sin datos')),
      ));
    } else {
      final headers = dataList.first;
      final rows = dataList.skip(1).toList();
      pdf.addPage(
        pw.MultiPage(
          pageFormat: landscape ? PdfPageFormat.a4.landscape : PdfPageFormat.a4,
          build: (context) => [
            pw.Table.fromTextArray(
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headers: headers,
              data: rows,
              cellAlignment: pw.Alignment.centerLeft,
              headerDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFE0E0E0)),
              cellStyle: const pw.TextStyle(fontSize: 9),
            ),
          ],
        ),
      );
    }

    final bytes = await pdf.save();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes, flush: true);

    await Share.shareXFiles([XFile(file.path)], text: 'Descarga tu PDF');
  }
}
