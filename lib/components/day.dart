import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:nantokanaru/models/trade_record.dart';
import 'package:nantokanaru/db/database_helper.dart';

// Segmented control tabs
enum DaySegment { income, expense }

class DayPage extends StatefulWidget {
  const DayPage({super.key, required this.selectedDay});

  final DateTime selectedDay;

  @override
  State<DayPage> createState() => _DayPageState();
}

class _DayPageState extends State<DayPage> {
  late DateTime _selectedDay;
  late List<TradeRecord> _profitRecords;
  late List<TradeRecord> _lossRecords;
  final NumberFormat _numberFormat = NumberFormat('#,###');
  DaySegment _segment = DaySegment.income;

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.selectedDay;
    _profitRecords = [];
    _lossRecords = [];
    _fetchTradeRecords();
  }

  // データベースの内容をページに反映
  Future<void> _fetchTradeRecords() async {
    List<TradeRecord> tradeRecords = await DatabaseHelper.instance
        .getDayData(_selectedDay.year, _selectedDay.month, _selectedDay.day);
    setState(() {
      _profitRecords = tradeRecords
          .where((tradeRecord) => tradeRecord.profitLoss > 0)
          .toList();
      _lossRecords = tradeRecords
          .where((tradeRecord) => tradeRecord.profitLoss < 0)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "${_selectedDay.year}年${_selectedDay.month}月${_selectedDay.day}日(${DateFormat.E('ja_JP').format(_selectedDay)})"),
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: CupertinoSlidingSegmentedControl<DaySegment>(
              groupValue: _segment,
              backgroundColor: CupertinoColors.systemGrey5,
              onValueChanged: (DaySegment? value) {
                if (value == null) return;
                setState(() {
                  _segment = value;
                });
              },
              children: const {
                DaySegment.income: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text('収入'),
                ),
                DaySegment.expense: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text('支出'),
                ),
              },
            ),
          ),
        ),
      ),
      body: _segment == DaySegment.income
          ? (_profitRecords.isNotEmpty
              ? ListView(
                  children: _profitRecords
                      .map((tradeRecord) => ListTile(
                            title: Text(tradeRecord.issue),
                            subtitle: Text(tradeRecord.symbol),
                            trailing: Text(
                                "${_numberFormat.format(tradeRecord.profitLoss)}円"),
                          ))
                      .toList(),
                )
              : const Center(child: Text("データがありません")))
          : (_lossRecords.isNotEmpty
              ? ListView(
                  children: _lossRecords
                      .map((tradeRecord) => ListTile(
                            title: Text(tradeRecord.issue),
                            subtitle: Text(tradeRecord.symbol),
                            trailing: Text(
                                "${_numberFormat.format(tradeRecord.profitLoss)}円"),
                          ))
                      .toList(),
                )
              : const Center(child: Text("データがありません"))),
    );
  }
}
