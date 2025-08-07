import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fl_chart/fl_chart.dart';

class GraphPage extends StatefulWidget {
  const GraphPage({super.key});

  @override
  State<GraphPage> createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  final TextEditingController _startYearController = TextEditingController();
  final TextEditingController _startMonthController = TextEditingController();
  final TextEditingController _endYearController = TextEditingController();
  final TextEditingController _endMonthController = TextEditingController();
  final List<int> _years = List.generate(100, (index) => 2000 + index);
  final List<int> _months = List.generate(12, (index) => index + 1);
  int _selectedStartYear = DateTime.now().year;
  int _selectedStartMonth = DateTime.now().month;
  int _selectedEndYear = DateTime.now().year;
  int _selectedEndMonth = DateTime.now().month;

  @override
  void initState() {
    super.initState();
    _startYearController.text = "$_selectedStartYear";
    _startMonthController.text = "$_selectedStartMonth";
    _endYearController.text = "$_selectedEndYear";
    _endMonthController.text = "$_selectedEndMonth";
  }

  @override
  void dispose() {
    _startYearController.dispose();
    _startMonthController.dispose();
    _endYearController.dispose();
    _endMonthController.dispose();
    super.dispose();
  }

  void _showDatePicker({
    required List<int> options,
    required int selectedYear,
    required void Function(int) onDateChanged,
  }) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 250,
        color: Colors.white,
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CupertinoButton(
                child: const Text("完了"),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                scrollController: FixedExtentScrollController(
                  initialItem: options.indexOf(selectedYear),
                ),
                itemExtent: 32.0,
                onSelectedItemChanged: (int index) {
                  setState(() {
                    onDateChanged(options[index]);
                  });
                },
                children: options
                    .map((option) => Center(child: Text('$option')))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Graph"),
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Flexible(
                  flex: 1,
                  child: TextFormField(
                    controller: _startYearController,
                    textAlign: TextAlign.center,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: "年",
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                    onTap: () => _showDatePicker(
                      options: _years,
                      selectedYear: _selectedStartYear,
                      onDateChanged: (int newYear) {
                        _selectedStartYear = newYear;
                        _startYearController.text = "$newYear";
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  flex: 1,
                  child: TextFormField(
                    controller: _startMonthController,
                    textAlign: TextAlign.center,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: "月",
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                    onTap: () => _showDatePicker(
                      options: _months,
                      selectedYear: _selectedStartMonth,
                      onDateChanged: (int newMonth) {
                        _selectedStartMonth = newMonth;
                        _startMonthController.text = "$newMonth";
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text("~"),
                const SizedBox(width: 8),
                Flexible(
                  flex: 1,
                  child: TextFormField(
                    controller: _endYearController,
                    textAlign: TextAlign.center,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: "年",
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                    onTap: () => _showDatePicker(
                      options: _years,
                      selectedYear: _selectedEndYear,
                      onDateChanged: (int newYear) {
                        _selectedEndYear = newYear;
                        _endYearController.text = "$newYear";
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  flex: 1,
                  child: TextFormField(
                    controller: _endMonthController,
                    textAlign: TextAlign.center,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: "月",
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                    onTap: () => _showDatePicker(
                      options: _months,
                      selectedYear: _selectedEndMonth,
                      onDateChanged: (int newMonth) {
                        _selectedEndMonth = newMonth;
                        _endMonthController.text = "$newMonth";
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 200, // 必要な高さを指定
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: 10,
                      color: Colors.white,
                      radius: 40,
                    ),
                    PieChartSectionData(
                      value: 10,
                      color: Colors.red,
                      radius: 40,
                    ),
                    PieChartSectionData(
                      value: 10,
                      color: Colors.green,
                      radius: 40,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
