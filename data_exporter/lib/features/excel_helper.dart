import 'dart:convert';

import 'package:archive/archive.dart';

List<int> buildExcelBytes(List<List<String>> dataList) {
  final sharedStrings = <String>[];
  final stringIndex = <String, int>{};

  int sharedStringIndex(String value) {
    final existing = stringIndex[value];
    if (existing != null) {
      return existing;
    }

    final index = sharedStrings.length;
    sharedStrings.add(value);
    stringIndex[value] = index;
    return index;
  }

  for (final row in dataList) {
    for (final cell in row) {
      sharedStringIndex(cell);
    }
  }

  final sheetData = StringBuffer();
  for (var rowIndex = 0; rowIndex < dataList.length; rowIndex++) {
    final rowNumber = rowIndex + 1;
    sheetData.write('<row r="$rowNumber">');
    final row = dataList[rowIndex];
    for (var columnIndex = 0; columnIndex < row.length; columnIndex++) {
      final cellRef = '${_columnName(columnIndex)}$rowNumber';
      final valueIndex = sharedStringIndex(row[columnIndex]);
      sheetData.write(
        '<c r="$cellRef" t="s"><v>$valueIndex</v></c>',
      );
    }
    sheetData.write('</row>');
  }

  final sharedStringsXml = StringBuffer(
    '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
    '<sst xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" '
    'count="${sharedStrings.length}" uniqueCount="${sharedStrings.length}">',
  );
  for (final value in sharedStrings) {
    sharedStringsXml.write('<si><t>${_escapeXml(value)}</t></si>');
  }
  sharedStringsXml.write('</sst>');

  final worksheetXml =
      '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">'
      '<sheetData>$sheetData</sheetData>'
      '</worksheet>';

  final workbookXml =
      '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" '
      'xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">'
      '<sheets><sheet name="Sheet1" sheetId="1" r:id="rId1"/></sheets>'
      '</workbook>';

  final stylesXml =
      '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"/>';

  final contentTypesXml =
      '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
      '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
      '<Default Extension="xml" ContentType="application/xml"/>'
      '<Override PartName="/xl/workbook.xml" '
      'ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>'
      '<Override PartName="/xl/worksheets/sheet1.xml" '
      'ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>'
      '<Override PartName="/xl/sharedStrings.xml" '
      'ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sharedStrings+xml"/>'
      '<Override PartName="/xl/styles.xml" '
      'ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"/>'
      '</Types>';

  final rootRelsXml =
      '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
      '<Relationship Id="rId1" '
      'Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" '
      'Target="xl/workbook.xml"/>'
      '</Relationships>';

  final workbookRelsXml =
      '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
      '<Relationship Id="rId1" '
      'Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" '
      'Target="worksheets/sheet1.xml"/>'
      '<Relationship Id="rId2" '
      'Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/sharedStrings" '
      'Target="sharedStrings.xml"/>'
      '<Relationship Id="rId3" '
      'Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" '
      'Target="styles.xml"/>'
      '</Relationships>';

  final archive = Archive()
    ..addFile(_textArchiveFile('[Content_Types].xml', contentTypesXml))
    ..addFile(_textArchiveFile('_rels/.rels', rootRelsXml))
    ..addFile(_textArchiveFile('xl/workbook.xml', workbookXml))
    ..addFile(_textArchiveFile('xl/_rels/workbook.xml.rels', workbookRelsXml))
    ..addFile(_textArchiveFile('xl/worksheets/sheet1.xml', worksheetXml))
    ..addFile(_textArchiveFile('xl/sharedStrings.xml', sharedStringsXml.toString()))
    ..addFile(_textArchiveFile('xl/styles.xml', stylesXml));

  final encoded = ZipEncoder().encode(archive);
  if (encoded == null) {
    throw StateError('Failed to encode Excel workbook');
  }

  return encoded;
}

ArchiveFile _textArchiveFile(String path, String content) {
  final bytes = utf8.encode(content);
  return ArchiveFile(path, bytes.length, bytes);
}

String _columnName(int index) {
  var value = index;
  final buffer = StringBuffer();
  while (value >= 0) {
    buffer.writeCharCode(65 + (value % 26));
    value = (value ~/ 26) - 1;
  }
  return buffer.toString().split('').reversed.join();
}

String _escapeXml(String value) {
  return value
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&apos;');
}

String normalizeExcelFilename(String filename) {
  if (filename.toLowerCase().endsWith('.xlsx')) {
    return filename;
  }
  return '$filename.xlsx';
}
