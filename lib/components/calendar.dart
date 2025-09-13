import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:holiday_jp/holiday_jp.dart';
import 'package:nantokanaru/db/database_helper.dart';
import 'package:nantokanaru/models/trade_record.dart';
import 'package:nantokanaru/widgets/custom_app_bar.dart';
import 'package:nantokanaru/widgets/custom_container.dart';
import 'package:nantokanaru/components/day.dart';
import 'package:nantokanaru/utils/calc_profit_loss.dart';

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

  Widget _buildDayCell(DateTime day, Color bgColor, Color textColor) {
    final totalProfitLoss = calcProfitLoss(day, _tradeRecords);
    return Container(
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
          if (totalProfitLoss != 0)
            Text(
              _numberFormat.format(totalProfitLoss),
              style: TextStyle(fontSize: 8, color: Colors.grey[600]),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Calendar',
      ),
      body: CustomContainer(
        height: 550,
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
              return _buildDayCell(day, Colors.white, _textColor(day));
            },
            selectedBuilder: (context, day, focusedDay) {
              return _buildDayCell(
                day,
                const Color(0xFFFAD689), // USUKI
                _textColor(day),
              );
            },
            outsideBuilder: (context, day, focusedDay) {
              return _buildDayCell(
                  day, Colors.grey[100]!, Colors.grey[500]!);
            },
            dowBuilder: (context, day) {
              return Text(
                DateFormat.E('ja_JP').format(day),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _textColor(day),
                  fontSize: 12,
                ),
              );
            },
          ),
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            headerPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }
}
