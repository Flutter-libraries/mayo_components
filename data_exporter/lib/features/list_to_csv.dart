import 'package:csv/csv.dart';

String listToCsv(List<List<String>> data) {
  return csv.encode(data);
}
