import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:nantokanaru/utils/csv_import.dart';
// import 'package:nantokanaru/db/database_helper.dart';
import 'package:nantokanaru/utils/csv_loader.dart';
import 'package:nantokanaru/utils/csv_format.dart';

class CsvPage extends StatefulWidget {
  const CsvPage({super.key});

  @override
  State<CsvPage> createState() => _CsvPageState();
}

class _CsvPageState extends State<CsvPage> {
  late List<String> _tableColumns;
  CsvData _csv = CsvData(headers: [], rows: []);
  List<String> _issueSymbolData = [];

  @override
  void initState() {
    super.initState();
    _tableColumns = ["日付", "種別", "銘柄名", "銘柄コード", "カテゴリ", "金額"];
    _loadData();
    // _fetchDBColumns();
  }

  Future<void> _loadData() async {
    final data = await loadCsvFromAssets('assets/data_j.csv');
    final formattedData = formatNameAndCode(data);
    setState(() {
      _issueSymbolData = formattedData;
    });
  }

  // 文字列から銘柄名とコードを分離
  Set<String> _setIssueAndSymbol(String issue) {
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
      final issue = match.group(1) ?? '';
      final symbol = match.group(2) ?? '';
      return {issue, symbol};
    } else {
      print(issue);
      return {};
    }
  }

  // // データベースのカラムを取得
  // Future<void> _fetchDBColumns() async {
  //   List<String> columns =
  //       await DatabaseHelper.instance.getTableColumns("trade_records");
  //   setState(() {
  //     _tableColumns = columns;
  //   });
  // }

  Future<void> pickCsvFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null && result.files.single.path != null) {
      String path = result.files.single.path!;
      final csvData = await importCsv(path);
      setState(() {
        _csv = csvData;
      });
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
              _csv.rows.isNotEmpty
                  ? Column(
                      children: _csv.rows.map((row) {
                        final data = _setIssueAndSymbol(row[3]);
                        return Center(child: Text(data.toString()));
                      }).toList(),
                    )
                  : const Center(child: Text("csv")),
              _tableColumns.isNotEmpty
                  ? Column(
                      children: _tableColumns
                          .map((column) => Center(child: Text(column)))
                          .toList(),
                    )
                  : const Center(child: Text("column")),
            ],
          ),
        ),
      ),
    );
  }
}
