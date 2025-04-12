import 'package:csv/csv.dart';

String listToCsv(List<List<String>> data) {
  return const ListToCsvConverter().convert(data);
}
