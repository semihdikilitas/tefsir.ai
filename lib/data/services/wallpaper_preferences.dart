import 'package:shared_preferences/shared_preferences.dart';
import '../../features/wallpapers/data/wallpaper_models.dart';

/// Duvar kağıdı tercihlerini SharedPreferences üzerinden yönetir.
/// Pattern: language_service.dart'taki SharedPreferences kullanımıyla aynı.
class WallpaperPreferences {
  static const _keyLastIndex = 'wallpaper_last_index';
  static const _keyLastDate = 'wallpaper_last_date';
  static const _keyAutoChange = 'wallpaper_auto_change_enabled';
  static const _keyInterval = 'wallpaper_interval_days';
  static const _keyIsPremium = 'is_premium';

  WallpaperPreferences._();

  /// Kullanıcının duvar kağıdı tercihlerini yükler.
  /// İlk kez çalıştırılıyorsa varsayılan değerlerle döner.
  static Future<WallpaperUserPrefs> load() async {
    final prefs = await SharedPreferences.getInstance();
    final lastIndex = prefs.getInt(_keyLastIndex) ?? 0;
    final lastDateStr = prefs.getString(_keyLastDate);
    final lastDate = lastDateStr != null ? DateTime.tryParse(lastDateStr) : null;
    final autoChange = prefs.getBool(_keyAutoChange) ?? true;
    final interval = prefs.getInt(_keyInterval) ?? 3;

    return WallpaperUserPrefs(
      lastWallpaperIndex: lastIndex,
      lastChangeDate: lastDate ?? DateTime.now(),
      autoChangeEnabled: autoChange,
      changeIntervalDays: interval,
    );
  }

  /// Duvar kağıdı indeksini kaydeder.
  static Future<void> saveWallpaperIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLastIndex, index);
  }

  /// Son değişim tarihini bugün olarak kaydeder.
  static Future<void> saveLastChangeDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastDate, date.toIso8601String());
  }

  /// Otomatik değişim ayarını kaydeder.
  static Future<void> saveAutoChange({required bool enabled, required int intervalDays}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoChange, enabled);
    await prefs.setInt(_keyInterval, intervalDays);
  }

  /// Premium durumunu kontrol eder.
  static Future<bool> get isPremium async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsPremium) ?? false;
  }

  /// Premium durumunu kaydeder (gerçek IAP entegrasyonu geldiğinde değişecek).
  static Future<void> setPremium(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsPremium, value);
  }
}
