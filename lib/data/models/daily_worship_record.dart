/// Bir günün ibadet durumunu (namazlar, Kur'an sayfası, zikir, oruç) temsil eder.
/// SQLite'daki 'daily_worship' tablosunun karşılığıdır.
class DailyWorshipRecord {
  final DateTime date;
  final bool imsak;
  final bool ogle;
  final bool ikindi;
  final bool aksam;
  final bool yatsi;
  final int quranPages;
  final int dhikrCount;
  final bool isFasting;

  const DailyWorshipRecord({
    required this.date,
    this.imsak = false,
    this.ogle = false,
    this.ikindi = false,
    this.aksam = false,
    this.yatsi = false,
    this.quranPages = 0,
    this.dhikrCount = 0,
    this.isFasting = false,
  });

  /// Henüz hiç kayıt girilmemiş bir gün için boş/varsayılan kayıt üretir.
  factory DailyWorshipRecord.empty(DateTime date) => DailyWorshipRecord(date: date);

  int get completedPrayers =>
      [imsak, ogle, ikindi, aksam, yatsi].where((v) => v).length;

  /// 0.0 - 1.0 arası tamamlanma oranı, ilerleme çubuğu ve grafik barları için.
  double get progress => completedPrayers / 5;

  /// 'yyyy-MM-dd' formatında, SQLite'da PRIMARY KEY olarak kullanılan anahtar.
  static String formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String get dateKey => formatDate(date);

  Map<String, Object?> toMap() {
    return {
      'date': dateKey,
      'imsak': imsak ? 1 : 0,
      'ogle': ogle ? 1 : 0,
      'ikindi': ikindi ? 1 : 0,
      'aksam': aksam ? 1 : 0,
      'yatsi': yatsi ? 1 : 0,
      'quran_pages': quranPages,
      'dhikr_count': dhikrCount,
      'is_fasting': isFasting ? 1 : 0,
    };
  }

  factory DailyWorshipRecord.fromMap(Map<String, Object?> map) {
    final parts = (map['date'] as String).split('-');
    return DailyWorshipRecord(
      date: DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      ),
      imsak: (map['imsak'] as int) == 1,
      ogle: (map['ogle'] as int) == 1,
      ikindi: (map['ikindi'] as int) == 1,
      aksam: (map['aksam'] as int) == 1,
      yatsi: (map['yatsi'] as int) == 1,
      quranPages: map['quran_pages'] as int,
      dhikrCount: map['dhikr_count'] as int,
      isFasting: (map['is_fasting'] as int) == 1,
    );
  }

  DailyWorshipRecord copyWith({
    bool? imsak,
    bool? ogle,
    bool? ikindi,
    bool? aksam,
    bool? yatsi,
    int? quranPages,
    int? dhikrCount,
    bool? isFasting,
  }) {
    return DailyWorshipRecord(
      date: date,
      imsak: imsak ?? this.imsak,
      ogle: ogle ?? this.ogle,
      ikindi: ikindi ?? this.ikindi,
      aksam: aksam ?? this.aksam,
      yatsi: yatsi ?? this.yatsi,
      quranPages: quranPages ?? this.quranPages,
      dhikrCount: dhikrCount ?? this.dhikrCount,
      isFasting: isFasting ?? this.isFasting,
    );
  }
}