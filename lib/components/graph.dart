import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:nantokanaru/db/database_helper.dart';
import 'package:nantokanaru/models/trade_record.dart';
import 'package:nantokanaru/widgets/custom_app_bar.dart';

class GraphPage extends StatefulWidget {
  const GraphPage({super.key});

  @override
  State<GraphPage> createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  late List<TradeRecord> _tradeRecords;
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _monthController = TextEditingController();
  final List<int> _years =
      List.generate(DateTime.now().year - 2000 + 1, (index) => 2000 + index);
  final List<int> _months = List.generate(12, (index) => index + 1);
  final NumberFormat _yenFormat =
      NumberFormat.currency(locale: 'ja_JP', symbol: '¥', decimalDigits: 0);
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;

  @override
  void initState() {
    super.initState();
    _tradeRecords = [];
    _fetchTradeRecords();
    _yearController.text = "$_selectedYear";
    _monthController.text = "$_selectedMonth";
  }

  @override
  void dispose() {
    _yearController.dispose();
    _monthController.dispose();
    super.dispose();
  }

  // データベースの内容をページに反映
  Future<void> _fetchTradeRecords() async {
    List<TradeRecord> tradeRecords = await DatabaseHelper.instance
        .getMonthData(_selectedYear, _selectedMonth);
    setState(() {
      _tradeRecords = tradeRecords;
    });
  }

  // データベースの内容を集計
  Map<DateTime, List<double>> _aggregateRecords(
      List<TradeRecord> tradeRecords) {
    final Map<DateTime, List<double>> datas = {};

    void initializeMonthData(int year, int month) {
      final firstDay = DateTime(year, month, 1);
      final lastDay = DateTime(year, month + 1, 0); // 月末日を正確に取得

      for (var d = firstDay;
          !d.isAfter(lastDay);
          d = d.add(const Duration(days: 1))) {
        datas[d] = [0.0]; // 初期値0.0でセット
      }
    }

    initializeMonthData(_selectedYear, _selectedMonth);

    // 選択された月の範囲内のデータのみを処理
    for (var record in tradeRecords) {
      final recordDate =
          DateTime(record.date.year, record.date.month, record.date.day);
      final selectedMonthStart = DateTime(_selectedYear, _selectedMonth, 1);
      final selectedMonthEnd = DateTime(_selectedYear, _selectedMonth + 1, 0);

      // 選択された月の範囲内かチェック
      if (recordDate
              .isAfter(selectedMonthStart.subtract(const Duration(days: 1))) &&
          recordDate.isBefore(selectedMonthEnd.add(const Duration(days: 1)))) {
        datas.putIfAbsent(recordDate, () => []);
        datas[recordDate]!.add(record.profitLoss.toDouble());
      }
    }

    final sortedEntries = datas.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Map.fromEntries(sortedEntries);
  }

  List<DateTime> getDatesInMonth(int year, int month) {
    final lastDay = DateTime(year, month + 1, 0).day;

    List<DateTime> days = [];
    for (int i = 1; i <= lastDay; i++) {
      days.add(DateTime(year, month, i));
    }
    return days;
  }

  void _showDatePicker({
    required List<int> options,
    required int selectedValue,
    required void Function(int) onDateChanged,
  }) async {
    int tempSelectedValue = selectedValue;
    await showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 250,
        color: Colors.white,
        child: CupertinoPicker(
          scrollController: FixedExtentScrollController(
            initialItem: options.indexOf(selectedValue),
          ),
          itemExtent: 32.0,
          onSelectedItemChanged: (int index) {
            setState(() {
              tempSelectedValue = options[index];
            });
          },
          children:
              options.map((option) => Center(child: Text('$option'))).toList(),
        ),
      ),
    );
    setState(() {
      onDateChanged(tempSelectedValue);
    });
    _fetchTradeRecords();
  }

  Widget bottomTitles(double value, TitleMeta meta) {
    final dates = getDatesInMonth(_selectedYear, _selectedMonth);
    final int index = value.toInt();

    // インデックスの範囲チェック
    if (index < 0 || index >= dates.length) {
      return const SideTitleWidget(
        axisSide: AxisSide.bottom,
        child: Text(''),
      );
    }

    DateTime date = dates[index];
    if (index % 5 == 0 || index == 0) {
      return SideTitleWidget(
        axisSide: AxisSide.bottom,
        child: Text(
          index == 0 ? "${date.month}/${date.day}" : "${date.day}",
          style: const TextStyle(color: Colors.black, fontSize: 10),
        ),
      );
    } else {
      return const SideTitleWidget(
        axisSide: AxisSide.bottom,
        child: Text(''),
      );
    }
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

  BarChartGroupData generateGroup(int date, double sum) {
    final isTop = sum > 0;
    return BarChartGroupData(
      x: date,
      barRods: [
        BarChartRodData(
          toY: sum,
          width: 10,
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
      appBar: const CustomAppBar(
        title: "Graph",
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _yearController,
                    textAlign: TextAlign.center,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: "年",
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                    onTap: () => _showDatePicker(
                      options: _years,
                      selectedValue: _selectedYear,
                      onDateChanged: (int newYear) {
                        setState(() {
                          _selectedYear = newYear;
                          _yearController.text = "$newYear";
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _monthController,
                    textAlign: TextAlign.center,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: "月",
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                    onTap: () => _showDatePicker(
                      options: _months,
                      selectedValue: _selectedMonth,
                      onDateChanged: (int newMonth) {
                        setState(() {
                          _selectedMonth = newMonth;
                          _monthController.text = "$newMonth";
                        });
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
                        getTitlesWidget: bottomTitles,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: leftTitles,
                        reservedSize: 50,
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipPadding: const EdgeInsets.all(8.0),
                      tooltipBgColor: Colors.grey[700],
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final dates =
                            getDatesInMonth(_selectedYear, _selectedMonth);

                        return BarTooltipItem(
                          '${dates[groupIndex].month.toString()}/${dates[groupIndex].day.toString()}\n${_yenFormat.format(rod.toY.toInt())}',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
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
                  barGroups: _aggregateRecords(_tradeRecords)
                      .entries
                      .where((e) => e.value.isNotEmpty) // 空のデータを除外
                      .map(
                        (e) => generateGroup(
                          e.key.day - 1, // インデックスを0から開始
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
