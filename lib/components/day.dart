import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:nantokanaru/db/database_helper.dart';
import 'package:nantokanaru/models/trade_record.dart';
import 'package:nantokanaru/utils/calc_profit_loss.dart';
import 'package:nantokanaru/widgets/custom_app_bar.dart';
import 'package:nantokanaru/widgets/custom_container.dart';
import 'package:nantokanaru/widgets/day_list_view.dart';

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
  int _totalProfitLoss = 0;
  int _totalProfit = 0;
  int _totalLoss = 0;
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
    final profitRecords = tradeRecords
        .where((tradeRecord) => tradeRecord.profitLoss > 0)
        .toList();
    final lossRecords = tradeRecords
        .where((tradeRecord) => tradeRecord.profitLoss < 0)
        .toList();
    final totalProfitLoss = calcProfitLoss(_selectedDay, tradeRecords);
    final totalProfit = calcProfitLoss(_selectedDay, profitRecords);
    final totalLoss = calcProfitLoss(_selectedDay, lossRecords);
    setState(() {
      _profitRecords = profitRecords;
      _lossRecords = lossRecords;
      _totalProfitLoss = totalProfitLoss;
      _totalProfit = totalProfit;
      _totalLoss = totalLoss;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title:
            "${_selectedDay.year}年${_selectedDay.month}月${_selectedDay.day}日(${DateFormat.E('ja_JP').format(_selectedDay)})",
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(45),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              children: [
                Text(
                  "収支: ${_numberFormat.format(_totalProfitLoss)}円",
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                CupertinoSlidingSegmentedControl<DaySegment>(
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
              ],
            ),
          ),
        ),
      ),
      body: CustomContainer(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              // color: const Color(0xFF897D55), // RIKYUCHA
              color: const Color(0xFF877F6C), // AKU
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("銘柄", style: TextStyle(color: Colors.white)),
                  Text(
                    "計 ${_numberFormat.format(_segment == DaySegment.income ? _totalProfit : _totalLoss)}円",
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _segment == DaySegment.income
                  ? DayListView(records: _profitRecords)
                  : DayListView(records: _lossRecords),
            ),
          ],
        ),
      ),
    );
  }
}
