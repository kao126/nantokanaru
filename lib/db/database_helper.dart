import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:nantokanaru/models/trade_record.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), "nantokanaru.db");
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE trade_records(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT,
            issue TEXT,
            symbol TEXT,
            type TEXT,
            profit_loss INTEGER,
            notes TEXT,
            created_at TEXT,
            updated_at TEXT
          )
        ''');
      },
    );
  }

  Future<void> getDatabasePath() async {
    final path = await getDatabasesPath();
    print('データベースの保存パス: $path');
  }

  Future<void> insertData(TradeRecord data) async {
    final db = await database;
    await db.insert(
      'trade_records',
      data.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<TradeRecord>> getDatas() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('trade_records');
    return List.generate(maps.length, (i) {
      return TradeRecord(
        id: maps[i]['id'],
        date: DateTime.parse(maps[i]['date']),
        issue: maps[i]['issue'],
        symbol: maps[i]['symbol'],
        type: maps[i]['type'],
        profitLoss: maps[i]['profit_loss'],
        notes: maps[i]['notes'],
        createdAt: DateTime.parse(maps[i]['created_at']),
        updatedAt: DateTime.parse(maps[i]['updated_at']),
      );
    });
  }
}
