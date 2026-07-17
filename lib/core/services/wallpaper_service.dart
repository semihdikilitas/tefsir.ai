import 'dart:io';
import 'package:flutter/services.dart';

/// Platform koprusu: Telefonun duvar kagidini degistirir.
///
/// Android: `WallpaperManager.setBitmap()` ile dogrudan duvar kagidi ayarlar.
/// iOS: Programatik duvar kagidi mumkun olmadigi icin fotografi albume kaydeder.
class WallpaperService {
  static const _channel = MethodChannel('com.ahmetsemih.islamic_ai_app/wallpaper');

  WallpaperService._();

  /// Verilen asset yolundaki gorseli telefonun duvar kagidi yapar.
  /// [assetPath]: "assets/kabe1.png" formatinda
  /// Donus: basarili ise true
  static Future<bool> setWallpaper(String assetPath) async {
    try {
      if (Platform.isAndroid) {
        final result = await _channel.invokeMethod('setWallpaper', {
          'assetPath': assetPath,
        });
        return result == true;
      } else if (Platform.isIOS) {
        return await _saveToPhotosIOS(assetPath);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Verilen dosya yolundaki gorseli (composite image) duvar kagidi yapar.
  /// [filePath]: gecici dosyanin tam yolu
  static Future<bool> setWallpaperFile(String filePath) async {
    try {
      if (Platform.isAndroid) {
        final result = await _channel.invokeMethod('setWallpaperFromFile', {
          'filePath': filePath,
        });
        return result == true;
      } else if (Platform.isIOS) {
        return await saveToGallery(filePath);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Gorseli galeriye / fotograflara kaydeder.
  static Future<bool> saveToGallery(String filePath) async {
    try {
      final result = await _channel.invokeMethod('saveToGallery', {
        'filePath': filePath,
      });
      return result == true;
    } catch (e) {
      return false;
    }
  }

  /// iOS: Fotografi albume kaydetmek icin native kanali cagirir.
  static Future<bool> _saveToPhotosIOS(String assetPath) async {
    try {
      final result = await _channel.invokeMethod('saveToPhotos', {
        'assetPath': assetPath,
      });
      return result == true;
    } catch (e) {
      return false;
    }
  }

  /// Cihazin wallpaper degistirmeyi destekleyip desteklemedigini kontrol eder.
  /// Android destekler, iOS desteklemez (sadece fotograf kaydeder).
  static bool get supportsDirectWallpaper => Platform.isAndroid;
}
