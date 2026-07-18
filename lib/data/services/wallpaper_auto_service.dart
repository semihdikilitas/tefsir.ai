import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/wallpapers.dart';
import '../../core/services/wallpaper_service.dart';

/// Premium kullanicilar icin otomatik duvar kagidi degisimi.
/// Uygulama her acildiginda gunluk degisim kontrolu yapar.
class WallpaperAutoService {
  static const _enabledKey = 'auto_wallpaper_premium';
  static const _lastAppliedDateKey = 'auto_wallpaper_last_date';

  WallpaperAutoService._();

  /// Otomatik duvar kagidi acik mi?
  static Future<bool> get isEnabled async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_enabledKey) ?? false;
  }

  /// Ac/kapat
  static Future<void> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, value);
  }

  /// Uygulama acildiginda cagrilir.
  /// Premium ve otomatik degisim aciksa, yeni gune gecildiyse duvar kagidini gunceller.
  static Future<void> checkAndApply() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_enabledKey) ?? false;
    if (!enabled) return;

    // Bugun daha once uygulandi mi kontrol et
    final today = DateTime.now().toIso8601String().substring(0, 10); // YYYY-MM-DD
    final lastApplied = prefs.getString(_lastAppliedDateKey) ?? '';
    if (lastApplied == today) return; // Bugun zaten uygulandi

    // Gunluk degisim araligini al
    final interval = prefs.getInt('wallpaper_interval_days') ?? 1;

    // Duvar kagidi indeksini hesapla
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    final index = (dayOfYear ~/ interval) % WallpaperRegistry.all.length;
    final wallpaper = WallpaperRegistry.all[index];

    // Uygula
    final success = await WallpaperService.setWallpaper(wallpaper.assetPath);
    if (success) {
      await prefs.setString(_lastAppliedDateKey, today);
    }
  }
}
