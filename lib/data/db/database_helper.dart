import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Uygulama boyunca tek bir veritabanı bağlantısı tutan singleton yardımcı sınıf.
class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbDirectory = await getDatabasesPath();
    final dbPath = join(dbDirectory, 'worship_tracker.db');

    return openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE daily_worship (
            date TEXT PRIMARY KEY,
            imsak INTEGER NOT NULL DEFAULT 0,
            ogle INTEGER NOT NULL DEFAULT 0,
            ikindi INTEGER NOT NULL DEFAULT 0,
            aksam INTEGER NOT NULL DEFAULT 0,
            yatsi INTEGER NOT NULL DEFAULT 0,
            quran_pages INTEGER NOT NULL DEFAULT 0,
            dhikr_count INTEGER NOT NULL DEFAULT 0,
            is_fasting INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );
  }
}