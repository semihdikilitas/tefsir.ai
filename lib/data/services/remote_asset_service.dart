import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// Sunucudan resim/varlık indirip yerel diskte önbellekleyen servis.
///
/// ```dart
/// // Kuran sayfası
/// final path = await RemoteAssetService.quranPage(1);
///
/// // Şehir arka planı
/// final path = await RemoteAssetService.cityBackground('istanbul');
/// ```
///
/// Çalışma mantığı:
/// 1. Yerel önbellekte var mı? → hemen döndür
/// 2. Yoksa sunucudan indir → diske kaydet → yolu döndür
/// 3. İnternet yoksa / sunucu cevap vermezse → `null` dön
class RemoteAssetService {
  RemoteAssetService._();

  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 8),
    receiveTimeout: const Duration(seconds: 15),
  ));

  // ─── AYARLANABİLİR SUNUCU URL'İ ───
  // Gerçek sunucuya geçince burayı değiştirmen yeterli.
  // Örnek: 'https://cdn.islamiapp.com'
  static String _baseUrl = 'https://cdn.islamiapp.com';

  /// Sunucu adresini değiştir (Ayarlar'dan çağrılabilir).
  static void setBaseUrl(String url) {
    _baseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  static String get baseUrl => _baseUrl;

  // ─── ÖNBELLEK DİZİNİ ───
  static Future<Directory> get _cacheDir async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(appDir.path, 'asset_cache'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  // ─── GENEL İNDİRME ───
  /// Uzaktaki bir URL'den dosyayı indirip önbelleğe alır.
  /// [remotePath]: '/quran/pages/001.png' gibi.
  /// [cacheKey]:  'quran_001.png' gibi benzersiz anahtar.
  static Future<String?> _fetchAndCache(String remotePath, String cacheKey) async {
    try {
      final dir = await _cacheDir;
      final file = File(p.join(dir.path, cacheKey));
      if (await file.exists()) return file.path;

      final url = '$_baseUrl$remotePath';
      await _dio.download(url, file.path);
      return file.path;
    } on DioException {
      return null; // ağ hatası → null
    }
  }

  // ─── KURAN SAYFALARI ───
  /// [page]: 1..604 arası mushaf sayfa numarası.
  /// Dönen: yerel dosya yolu (indirilmiş / önbellekte), ya da null.
  ///
  /// Sunucu yapısı örneği:
  ///   /quran/pages/001.png
  ///   /quran/pages/002.png … 604.png
  static Future<String?> quranPage(int page) {
    final padded = page.toString().padLeft(3, '0');
    return _fetchAndCache('/quran/pages/$padded.png', 'quran_$padded.png');
  }

  // ─── ŞEHİR ARKA PLANLARI ───
  /// [citySlug]: 'istanbul', 'ankara', 'konya' gibi küçük harf, boşluksuz.
  ///
  /// Sunucu yapısı örneği:
  ///   /cities/istanbul.jpg
  ///   /cities/ankara.jpg
  static Future<String?> cityBackground(String citySlug) {
    return _fetchAndCache('/cities/$citySlug.jpg', 'city_$citySlug.jpg');
  }

  // ─── ÖNBELLEK TEMİZLEME ───
  static Future<void> clearCache() async {
    final dir = await _cacheDir;
    if (await dir.exists()) await dir.delete(recursive: true);
  }

  /// Önbellek boyutu (byte).
  static Future<int> cacheSize() async {
    final dir = await _cacheDir;
    if (!await dir.exists()) return 0;
    int total = 0;
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File) total += await entity.length();
    }
    return total;
  }
}
