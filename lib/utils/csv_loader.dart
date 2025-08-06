import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';

Future<List<List<dynamic>>> loadCsvFromAssets(String path) async {
  final rawData = await rootBundle.loadString(path);
  final csvData = const CsvToListConverter().convert(rawData);
  return csvData;
}
