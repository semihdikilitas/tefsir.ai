import 'package:sqflite/sqflite.dart';
import '../db/database_helper.dart';
import '../models/daily_worship_record.dart';

/// İbadet takibi ile ilgili tüm veritabanı işlemlerinin tek giriş noktası.
/// UI katmanı doğrudan sqflite ile konuşmaz, hep bu sınıf üzerinden geçer.
class WorshipRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<DailyWorshipRecord> getRecordForDate(DateTime date) async {
    final db = await _dbHelper.database;
    final key = DailyWorshipRecord.formatDate(date);
    final result = await db.query(
      'daily_worship',
      where: 'date = ?',
      whereArgs: [key],
    );
    if (result.isEmpty) {
      return DailyWorshipRecord.empty(date);
    }
    return DailyWorshipRecord.fromMap(result.first);
  }

  Future<void> upsertRecord(DailyWorshipRecord record) async {
    final db = await _dbHelper.database;
    await db.insert(
      'daily_worship',
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// [start] - [end] arasındaki (dahil) tüm günleri döner.
  /// Veritabanında kaydı olmayan günler için boş/varsayılan kayıt üretir,
  /// böylece grafikte "0 vakit kılınmış gün" ile "hiç kayıt yok" karışmaz.
  Future<List<DailyWorshipRecord>> getRecordsInRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await _dbHelper.database;
    final startKey = DailyWorshipRecord.formatDate(start);
    final endKey = DailyWorshipRecord.formatDate(end);

    final result = await db.query(
      'daily_worship',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startKey, endKey],
    );

    final Map<String, DailyWorshipRecord> byDate = {
      for (final row in result)
        row['date'] as String: DailyWorshipRecord.fromMap(row),
    };

    final List<DailyWorshipRecord> records = [];
    var cursor = DateTime(start.year, start.month, start.day);
    final endDay = DateTime(end.year, end.month, end.day);
    while (!cursor.isAfter(endDay)) {
      final key = DailyWorshipRecord.formatDate(cursor);
      records.add(byDate[key] ?? DailyWorshipRecord.empty(cursor));
      cursor = cursor.add(const Duration(days: 1));
    }
    return records;
  }

  /// Bugünden (ya da verilen tarihten) geriye doğru, kesintisiz
  /// "5 vaktin de kılındığı" gün sayısını hesaplar.
  Future<int> getStreak({DateTime? referenceDate}) async {
    final now = referenceDate ?? DateTime.now();
    int streak = 0;
    var cursor = DateTime(now.year, now.month, now.day);

    while (true) {
      final record = await getRecordForDate(cursor);
      if (record.completedPrayers == 5) {
        streak++;
        cursor = cursor.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  /// Sadece veritabanında gerçekten kaydı olan günleri döner.
  /// Boş gün üretmez — kaza hesaplaması için kullanılır.
  Future<List<DailyWorshipRecord>> getExistingRecordsInRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await _dbHelper.database;
    final startKey = DailyWorshipRecord.formatDate(start);
    final endKey = DailyWorshipRecord.formatDate(end);
    final result = await db.query(
      'daily_worship',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startKey, endKey],
    );
    return result.map((row) => DailyWorshipRecord.fromMap(row)).toList();
  }

  /// Verilen tarihin ait olduğu ayda, o aya kadar kılınmış toplam vakit sayısı.
  Future<int> getMonthTotal(DateTime monthDate) async {
    final start = DateTime(monthDate.year, monthDate.month, 1);
    final end = DateTime(monthDate.year, monthDate.month + 1, 0);
    final records = await getRecordsInRange(start, end);
    return records.fold<int>(0, (sum, r) => sum + r.completedPrayers);
  }
}