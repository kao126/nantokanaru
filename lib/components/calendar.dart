import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

Color _textColor(DateTime day) {
  const defaultTextColor = Colors.black87;

  if (day.weekday == DateTime.sunday) {
    return Colors.red;
  }
  if (day.weekday == DateTime.saturday) {
    return Colors.blue[600]!;
  }
  return defaultTextColor;
}

Widget _buildDayCell(DateTime day, Color bgColor, Color textColor) {
  return AnimatedContainer(
    duration: const Duration(milliseconds: 250),
    margin: const EdgeInsets.all(1.0),
    decoration: BoxDecoration(
      color: bgColor,
    ),
    alignment: Alignment.topCenter,
    child: Text(
      day.day.toString(),
      style: TextStyle(color: textColor),
    ),
  );
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
        title: const Text('Calendar App'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TableCalendar(
          firstDay: DateTime.utc(2000, 1, 1),
          lastDay: DateTime.utc(2100, 12, 31),
          focusedDay: _focusedDay,
          // shouldFillViewport: true,
          locale: 'ja_JP',
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, focusedDay) {
              return _buildDayCell(day, Colors.white, _textColor(day));
            },
            todayBuilder: (context, day, focusedDay) {
              return _buildDayCell(day, Colors.orangeAccent, Colors.white);
            },
            selectedBuilder: (context, day, focusedDay) {
              return _buildDayCell(day, Colors.purple[100]!, Colors.white);
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
