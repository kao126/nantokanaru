import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:holiday_jp/holiday_jp.dart';

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

Widget _buildDayCell(DateTime day, Color bgColor, Color textColor) {
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
              getHoliday(day)!.name, // 山の日など
              style: TextStyle(fontSize: 10, color: textColor),
            ),
        ],
      ));
}

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

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
        padding: const EdgeInsets.all(16.0),
        child: TableCalendar(
          firstDay: DateTime.utc(2000, 1, 1),
          lastDay: DateTime.utc(2100, 12, 31),
          focusedDay: _focusedDay,
          shouldFillViewport: true,
          locale: 'ja_JP',
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            if (!isSameMonth(selectedDay, focusedDay)) return;
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
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
