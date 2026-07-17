import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import '../../core/constants/wallpapers.dart';

/// Ana ekran widget yonetimi.
/// Duvar kagidi resmini direkt widget arka planinda gosterir,
/// uzerine ayet metnini yerlestirir.
class WidgetService {
  static const _androidProvider = 'TefsirWidgetProvider';
  static const _iosName = 'TefsirWidget';

  WidgetService._();

  /// Widget'i gunceller: duvar kagidi resmi + ayet metni.
  static Future<void> updateWidget(int wallpaperIndex) async {
    try {
      final wallpaper = WallpaperRegistry.all[wallpaperIndex];

      // Ayet metin verilerini kaydet
      await HomeWidget.saveWidgetData<String>(
        'widget_verse_text',
        '"${wallpaper.verseText}"',
      );
      await HomeWidget.saveWidgetData<String>(
        'widget_surah_name',
        '${wallpaper.surahName}, ${wallpaper.verseNumbers}',
      );

      // Asset'teki duvar kagidi resmini widget'in erisebilecegi yere kaydet
      await _saveWallpaperImage(wallpaper.asset);

      await HomeWidget.updateWidget(
        androidName: _androidProvider,
        iOSName: _iosName,
      );
    } catch (_) {
      // Widget henuz eklenmemis olabilir
    }
  }

  /// Asset'teki resmi home_widget uzerinden widget'a gonderir.
  static Future<void> _saveWallpaperImage(String assetName) async {
    try {
      // AssetImage ile home_widget'a resim olarak kaydet
      await HomeWidget.saveImage(
        'widget_bg',
        AssetImage('assets/$assetName'),
      );
    } catch (_) {
      // Resim kopyalanamazsa metin yine de gorunur
    }
  }

  static Future<bool> isWidgetSupported() async {
    try {
      final result = await HomeWidget.isRequestPinWidgetSupported();
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> requestPinWidget() async {
    try {
      await HomeWidget.requestPinWidget(
        androidName: _androidProvider,
      );
    } catch (_) {
      // Kullanici iptal etti
    }
  }
}
