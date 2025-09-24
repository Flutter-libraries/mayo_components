abstract class Exporter {
  Future<void> export(String filename, List<List<String>> dataList, {bool landscape = false});
}
