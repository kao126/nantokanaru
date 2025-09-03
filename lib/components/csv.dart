import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:nantokanaru/models/trade_record.dart';
import 'package:nantokanaru/db/database_helper.dart';
import 'package:nantokanaru/utils/csv_import.dart';
import 'package:nantokanaru/utils/csv_loader.dart';
import 'package:nantokanaru/utils/csv_format.dart';

class CsvPage extends StatefulWidget {
  const CsvPage({super.key});

  @override
  State<CsvPage> createState() => _CsvPageState();
}

class _CsvPageState extends State<CsvPage> {
  List<String> _issueSymbolData = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await loadCsvFromAssets('assets/data_j.csv');
    final formattedData = formatNameAndCode(data);
    setState(() {
      _issueSymbolData = formattedData;
    });
  }

  // 文字列から銘柄名とコードを分離
  List<String> _extractIssueAndSymbol(String issue) {
    final data = _issueSymbolData.firstWhere((option) => option.contains(issue),
        orElse: () => '');
    final regex = RegExp(r'^(.*)\((.*)\)$'); // "銘柄名(コード)"形式
    RegExpMatch? match;
    if (issue == "DeNA") {
      match = regex.firstMatch("ディー・エヌ・エー(2432)");
    } else {
      match = regex.firstMatch(data);
    }
    if (match != null) {
      final String issue = match.group(1) ?? '';
      final String symbol = match.group(2) ?? '';
      return [issue, symbol];
    } else {
      print(issue);
      return ['', ''];
    }
  }

  // 日本語日付 "YYYY年MM月DD日(曜)" を DateTime に変換
  DateTime _parseJapaneseDate(String input) {
    final trimmed = input.trim();
    final reg = RegExp(r'^(\d{4})年(\d{1,2})月(\d{1,2})日[\(（][^\)）]+[\)）]$');
    final match = reg.firstMatch(trimmed);
    if (match == null) return DateTime.now();
    final year = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final day = int.parse(match.group(3)!);
    return DateTime(year, month, day);
  }

  Future<void> pickCsvFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null && result.files.single.path != null) {
      String path = result.files.single.path!;
      final csvData = await importCsv(path);
      if (csvData.rows.isNotEmpty) {
        for (final row in csvData.rows) {
          final List<String> extractedData = _extractIssueAndSymbol(row[3]);
          final String extractedIssue = extractedData[0];
          final String symbol = extractedData[1];
          final DateTime parsed = _parseJapaneseDate(row[0]);
          TradeRecord data = TradeRecord(
            date: parsed,
            issue: extractedIssue,
            symbol: symbol,
            type: row[2] == "株式投資(現物)" ? "spot" : "margin",
            profitLoss: row[1] == "収入" ? row[4].toInt() : -row[4].toInt(),
            notes: null,
            createdAt: parsed,
            updatedAt: parsed,
          );
          await DatabaseHelper.instance.insertData(data);
        }
      }
    } else {
      print("ファイル選択がキャンセルされました");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              ListTile(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              ListTile(
                leading: IconButton(
                  icon: const Icon(Icons.import_export),
                  onPressed: () => pickCsvFile(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
