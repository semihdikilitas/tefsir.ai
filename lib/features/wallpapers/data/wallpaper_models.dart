// Duvar kağıdı ve ayet eşleşmesi için model sınıfları.

class WallpaperItem {
  final String asset; // örn: 'kabe1.png'
  final String category; // örn: 'kaabe', 'medine', 'doga'
  final String verseText; // ayet metni
  final String surahName; // sure adı
  final String verseNumbers; // ayet numaraları
  final bool isPremium; // premium duvar kağıdı mı?

  const WallpaperItem({
    required this.asset,
    required this.category,
    required this.verseText,
    required this.surahName,
    required this.verseNumbers,
    this.isPremium = false,
  });

  String get assetPath => 'assets/$asset';
}

class WallpaperUserPrefs {
  final int lastWallpaperIndex;
  final DateTime lastChangeDate;
  final bool autoChangeEnabled;
  final int changeIntervalDays; // varsayılan 3

  const WallpaperUserPrefs({
    required this.lastWallpaperIndex,
    required this.lastChangeDate,
    this.autoChangeEnabled = true,
    this.changeIntervalDays = 3,
  });

  WallpaperUserPrefs copyWith({
    int? lastWallpaperIndex,
    DateTime? lastChangeDate,
    bool? autoChangeEnabled,
    int? changeIntervalDays,
  }) {
    return WallpaperUserPrefs(
      lastWallpaperIndex: lastWallpaperIndex ?? this.lastWallpaperIndex,
      lastChangeDate: lastChangeDate ?? this.lastChangeDate,
      autoChangeEnabled: autoChangeEnabled ?? this.autoChangeEnabled,
      changeIntervalDays: changeIntervalDays ?? this.changeIntervalDays,
    );
  }
}
