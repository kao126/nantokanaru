import 'dart:io';
import 'dart:convert';
import 'package:csv/csv.dart';

class CsvData {
  final List<String> headers;
  final List<List<dynamic>> rows;

  CsvData({required this.headers, required this.rows});

  // bool get present => headers.isNotEmpty || rows.isNotEmpty;
}

Future<CsvData> importCsv(String path) async {
  final input = File(path).openRead();
  final inputString = await input.transform(utf8.decoder).join();
  final fields = const CsvToListConverter(eol: '\n').convert(inputString);

  final headers = fields.first.cast<String>();
  final dataRows = fields.sublist(1);

  return CsvData(headers: headers, rows: dataRows);
}
