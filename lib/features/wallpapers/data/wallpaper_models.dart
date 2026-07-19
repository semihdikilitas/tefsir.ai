// Duvar kağıdı ve ayet eşleşmesi için model sınıfları.

class WallpaperItem {
  final String asset; // örn: 'pexels-xxx.jpg'
  final String category;
  final String verseText;
  final String surahName;
  final String verseNumbers;
  final bool isPremium;
  final String? imageUrl; // Sunucudaki resim URL'i (null ise local asset)

  const WallpaperItem({
    required this.asset,
    required this.category,
    required this.verseText,
    required this.surahName,
    required this.verseNumbers,
    this.isPremium = false,
    this.imageUrl,
  });

  String get assetPath => 'assets/$asset';

  /// Once sunucudan yuklemeyi dener, yoksa local asset'e duser
  bool get hasRemoteImage => imageUrl != null && imageUrl!.isNotEmpty;
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
