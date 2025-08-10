class TradeRecord {
  final int? id;
  final DateTime date; // 取引日
  final String issue; // 銘柄名
  final String symbol; // 銘柄コード（例：7203.T）
  final String type; // 'spot', 'margin' など
  final int profitLoss; // 損益（利益はプラス、損失はマイナス）
  final String? notes; // メモ
  final DateTime createdAt; // データ作成日
  final DateTime updatedAt; // データ更新日

  TradeRecord({
    this.id,
    required this.date,
    required this.issue,
    required this.symbol,
    required this.type,
    required this.profitLoss,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  // Map形式に変換（SQLite保存用）
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'issue': issue,
      'symbol': symbol,
      'type': type,
      'profit_loss': profitLoss,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Mapからモデルを復元
  factory TradeRecord.fromMap(Map<String, dynamic> map) {
    return TradeRecord(
      id: map['id'],
      date: DateTime.parse(map['date']),
      issue: map['issue'],
      symbol: map['symbol'],
      type: map['type'],
      profitLoss: map['profit_loss'],
      notes: map['notes'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}
