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
  final List<int> _years =
      List.generate(DateTime.now().year - 2000 + 1, (index) => 2000 + index);
  final List<int> _months = List.generate(12, (index) => index + 1);
  int _selectedStartYear = DateTime.now().year;
  int _selectedStartMonth = DateTime.now().month;
  int _selectedEndYear = DateTime.now().year;
  int _selectedEndMonth = DateTime.now().month;

  final _datas = <int, List<double>>{
    DateTime(2025, 8, 1).day: [1, 2, 3, 4],
    DateTime(2025, 8, 2).day: [-1, -2, -3, -4],
    DateTime(2025, 8, 3).day: [1.5, 2, 3.5, 6],
    DateTime(2025, 8, 4).day: [1.5, 1.5, 4, 6.5],
    DateTime(2025, 8, 5).day: [-2, -2, -5, -9],
    DateTime(2025, 8, 6).day: [-1.2, -1.5, -4.3, -10],
    DateTime(2025, 8, 7).day: [1.2, 4.8, 5, 5],
  };

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
          children:
              options.map((option) => Center(child: Text('$option'))).toList(),
        ),
      ),
    );
  }

  Widget bottomTitles(double date, TitleMeta meta) {
    return SideTitleWidget(
      axisSide: AxisSide.bottom,
      child: Text('$_selectedStartMonth/${date.toInt()}',
          style: const TextStyle(color: Colors.black, fontSize: 10)),
    );
  }

  Widget leftTitles(double value, TitleMeta meta) {
    return SideTitleWidget(
      axisSide: AxisSide.left,
      space: 4,
      child: Text(
        value == 0 ? "0" : '${value.toInt()}',
        style: const TextStyle(color: Colors.black, fontSize: 10),
        textAlign: TextAlign.center,
      ),
    );
  }

  BarChartGroupData generateGroup(
    int date,
    double sum,
  ) {
    final isTop = sum > 0;
    return BarChartGroupData(
      x: date,
      // groupVertically: true,
      // showingTooltipIndicators: [],
      barRods: [
        BarChartRodData(
          toY: sum,
          width: 22,
          color: Colors.amber,
          borderRadius: isTop
              ? const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                )
              : const BorderRadius.only(
                  bottomLeft: Radius.circular(6),
                  bottomRight: Radius.circular(6),
                ),
        ),
      ],
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
            const SizedBox(height: 30),
            SizedBox(
              height: 200, // 必要な高さを指定
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.center,
                  groupsSpace: 12,
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        // reservedSize: 32,
                        getTitlesWidget: bottomTitles,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: leftTitles,
                        // interval: 5,
                        // reservedSize: 42,
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    checkToShowHorizontalLine: (value) => value % 5 == 0,
                    getDrawingHorizontalLine: (value) {
                      if (value == 0) {
                        return const FlLine(
                          color: Colors.orange,
                          strokeWidth: 1.5,
                        );
                      }
                      return const FlLine(
                        color: Colors.amber,
                        strokeWidth: 0.8,
                      );
                    },
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  barGroups: _datas.entries
                      .map(
                        (e) => generateGroup(
                          e.key,
                          e.value.reduce((a, b) => a + b),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
