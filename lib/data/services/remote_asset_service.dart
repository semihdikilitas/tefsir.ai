import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// Sunucudan resim indirip yerel diskte onbellekleyen servis.
class RemoteAssetService {
  RemoteAssetService._();

  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 8),
    receiveTimeout: const Duration(seconds: 15),
  ));

  static String _baseUrl = 'https://tefsir-ai-api.fly.dev';

  static void setBaseUrl(String url) {
    _baseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  static String get baseUrl => _baseUrl;

  static Future<Directory> get _cacheDir async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(appDir.path, 'asset_cache'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  static Future<String?> _fetchAndCache(String remoteUrl, String cacheKey) async {
    try {
      final dir = await _cacheDir;
      final file = File(p.join(dir.path, cacheKey));
      if (await file.exists()) return file.path;
      await _dio.download(remoteUrl, file.path);
      return file.path;
    } on DioException {
      return null;
    }
  }

  /// [page]: 1..604 arasi mushaf sayfa numarasi.
  /// Sunucudan sayfa URL'ini alir, indirip cache'ler.
  static Future<String?> quranPage(int page) async {
    try {
      final padded = page.toString().padLeft(3, '0');
      final cacheKey = 'quran_$padded.png';

      final dir = await _cacheDir;
      final file = File(p.join(dir.path, cacheKey));
      if (await file.exists()) return file.path;

      final resp = await _dio.get('$_baseUrl/api/quran/page/$page');
      final pageUrl = resp.data['url'] as String?;
      if (pageUrl == null) return null;

      return _fetchAndCache(pageUrl, cacheKey);
    } on DioException {
      return null;
    }
  }

  static Future<String?> cityBackground(String citySlug) {
    return _fetchAndCache('$_baseUrl/uploads/cities/$citySlug.jpg', 'city_$citySlug.jpg');
  }

  static Future<void> clearCache() async {
    final dir = await _cacheDir;
    if (await dir.exists()) await dir.delete(recursive: true);
  }

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
