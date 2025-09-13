import 'package:nantokanaru/models/trade_record.dart';

int calcProfitLoss(DateTime day, List<TradeRecord> tradeRecords) {
  final localDayAtMidnight = DateTime(day.year, day.month, day.day);
  final totalProfitLoss = tradeRecords.where((record) {
    final recordDate =
        DateTime(record.date.year, record.date.month, record.date.day);
    return recordDate == localDayAtMidnight;
  }).fold<int>(0, (sum, record) => sum + record.profitLoss);

  return totalProfitLoss;
}
