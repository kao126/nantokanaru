import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:nantokanaru/utils/csv_import.dart';
import 'package:nantokanaru/db/database_helper.dart';

class CsvPage extends StatefulWidget {
  const CsvPage({super.key});

  @override
  State<CsvPage> createState() => _CsvPageState();
}

class _CsvPageState extends State<CsvPage> {
  late List<String> _tableColumns;
  CsvData _csv = CsvData(headers: [], rows: []);

  @override
  void initState() {
    super.initState();
    _tableColumns = [];
    _fetchDBColumns();
  }

  // データベースのカラムを取得
  Future<void> _fetchDBColumns() async {
    List<String> columns =
        await DatabaseHelper.instance.getTableColumns("trade_records");
    setState(() {
      _tableColumns = columns;
    });
  }

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
            _csv.headers.isNotEmpty
                ? Column(
                    children: _csv.headers
                        .map((header) => Center(child: Text(header)))
                        .toList(),
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
    );
  }
}
