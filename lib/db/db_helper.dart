import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  static Future<Database> initDB() async {
    final path = join(await getDatabasesPath(), 'app_data.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE dados (
            id INTEGER PRIMARY KEY,
            nome TEXT,
            valor TEXT
          )
        ''');
      },
    );
  }

  static Future<void> insertDados(Map<String, dynamic> data) async {
    final db = await database;
    await db.insert('dados', data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<Map<String, dynamic>>> getDados() async {
    final db = await database;
    return await db.query('dados');
  }

  static Future<void> clearTable() async {
    final db = await database;
    await db.delete('dados');
  }
}
