import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nantokanaru/models/trade_record.dart';

class DayListView extends StatelessWidget {
  final List<TradeRecord> records;
  final NumberFormat _numberFormat = NumberFormat('#,###');

  DayListView({
    super.key,
    required this.records,
  });

  @override
  Widget build(BuildContext context) {
    return (records.isNotEmpty
        ? ListView(
            children: records
                .map(
                  (tradeRecord) => Column(
                    children: [
                      ListTile(
                        title: Text(tradeRecord.issue),
                        subtitle: Text(tradeRecord.symbol),
                        trailing: Text(
                            "${_numberFormat.format(tradeRecord.profitLoss)}円"),
                        dense: true,
                      ),
                      const Divider(height: 1),
                    ],
                  ),
                )
                .toList(),
          )
        : const Center(child: Text("データがありません")));
  }
}
