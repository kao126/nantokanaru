import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:holiday_jp/holiday_jp.dart';
import 'package:nantokanaru/db/database_helper.dart';
import 'package:nantokanaru/models/trade_record.dart';
import 'package:nantokanaru/components/day.dart';

Color _textColor(DateTime day) {
  const defaultTextColor = Colors.black87;

  if (day.weekday == DateTime.sunday || isHoliday(day)) {
    return Colors.red;
  }
  if (day.weekday == DateTime.saturday) {
    return Colors.blue[600]!;
  }
  return defaultTextColor;
}

bool isSameMonth(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month;
}

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late List<TradeRecord> _tradeRecords;
  final NumberFormat _numberFormat = NumberFormat('#,###');
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _tradeRecords = [];
    _fetchTradeRecords();
  }

  // データベースの内容をページに反映
  Future<void> _fetchTradeRecords() async {
    List<TradeRecord> tradeRecords = await DatabaseHelper.instance
        .getMonthData(_focusedDay.year, _focusedDay.month);
    setState(() {
      _tradeRecords = tradeRecords;
    });
  }

  // データベースの内容を集計
  Map<DateTime, List<int>> _aggregateRecords(List<TradeRecord> tradeRecords) {
    final Map<DateTime, List<int>> datas = {};
    // 選択された月の範囲内のデータのみを処理
    for (var record in tradeRecords) {
      final recordDate =
          DateTime(record.date.year, record.date.month, record.date.day);
      final selectedMonthStart =
          DateTime(_focusedDay.year, _focusedDay.month, 1);
      final selectedMonthEnd =
          DateTime(_focusedDay.year, _focusedDay.month + 1, 0);

      // 選択された月の範囲内かチェック
      if (recordDate
              .isAfter(selectedMonthStart.subtract(const Duration(days: 1))) &&
          recordDate.isBefore(selectedMonthEnd.add(const Duration(days: 1)))) {
        datas.putIfAbsent(recordDate, () => []);
        datas[recordDate]!.add(record.profitLoss);
      }
    }

    final sortedEntries = datas.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Map.fromEntries(sortedEntries);
  }

  Widget _buildDayCell(DateTime day, Color bgColor, Color textColor) {
    final localDayAtMidnight = DateTime(day.year, day.month, day.day);
    final profitLossArr =
        _aggregateRecords(_tradeRecords)[localDayAtMidnight] ?? const <int>[];
    final total = profitLossArr.fold<int>(0, (s, v) => s + v);
    return AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.all(1.0),
        decoration: BoxDecoration(
          color: bgColor,
        ),
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            Text(
              '${day.day}',
              style: TextStyle(color: textColor),
            ),
            if (isHoliday(day))
              Text(
                getHoliday(day)!.name,
                style: TextStyle(fontSize: 8, color: textColor),
              ),
            if (profitLossArr.isNotEmpty)
              Text(
                _numberFormat.format(total),
                style: TextStyle(fontSize: 8, color: Colors.grey[600]),
              ),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TableCalendar(
          firstDay: DateTime.utc(2000, 1, 1),
          lastDay: DateTime.utc(2100, 12, 31),
          focusedDay: _focusedDay,
          shouldFillViewport: true,
          locale: 'ja_JP',
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) async {
            if (!isSameMonth(selectedDay, focusedDay)) return;
            if (isSameDay(_selectedDay, selectedDay)) {
              await Navigator.of(context).push<ThemeMode>(
                MaterialPageRoute(
                  builder: (context) => DayPage(selectedDay: selectedDay),
                ),
              );
            } else {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            }
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
            _fetchTradeRecords();
          },
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, focusedDay) {
              return _buildDayCell(day, Colors.white, _textColor(day));
            },
            todayBuilder: (context, day, focusedDay) {
              return _buildDayCell(day, Colors.orangeAccent, _textColor(day));
            },
            selectedBuilder: (context, day, focusedDay) {
              return _buildDayCell(day, Colors.purple[100]!, _textColor(day));
            },
            outsideBuilder: (context, day, focusedDay) {
              return _buildDayCell(
                  day, Colors.grey[100]!, Colors.grey[500]!); // 例：薄い色で表示
            },
            dowBuilder: (context, day) {
              return Text(
                DateFormat.E('ja_JP').format(day),
                textAlign: TextAlign.center,
                style: TextStyle(color: _textColor(day)),
              );
            },
          ),
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
          ),
          daysOfWeekStyle: const DaysOfWeekStyle(
            weekdayStyle: TextStyle(color: Colors.black), // 月〜金
            weekendStyle: TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }
}
