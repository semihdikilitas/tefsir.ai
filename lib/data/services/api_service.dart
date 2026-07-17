import 'package:dio/dio.dart';

/// Tefsir AI icerik API'sine erisim.
class ApiService {
  static final ApiService _instance = ApiService._();
  factory ApiService() => _instance;
  ApiService._();

  static String baseUrl = 'https://tefsir-ai-api.fly.dev';

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  // ─── Duvar Kagitlari, Ayetler, Hadisler, Dualar ───

  Future<List<Map<String, dynamic>>> getWallpapers() async {
    return _getList('/api/wallpapers');
  }

  Future<List<Map<String, dynamic>>> getVerses() async {
    return _getList('/api/verses');
  }

  Future<List<Map<String, dynamic>>> getHadiths() async {
    return _getList('/api/hadiths');
  }

  Future<List<Map<String, dynamic>>> getPrayers() async {
    return _getList('/api/prayers');
  }

  // ─── Kuran ───

  Future<List<Map<String, dynamic>>> getSurahs() async {
    return _getList('/api/quran/surahs');
  }

  Future<Map<String, dynamic>?> getSurah(int id) async {
    try {
      final response = await _dio.get('$baseUrl/api/quran/surah/$id');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getAyahs(int surahId, int start, int end) async {
    try {
      final response = await _dio.get('$baseUrl/api/quran/ayahs/$surahId/$start-$end');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> searchQuran(String query) async {
    try {
      final response = await _dio.get('$baseUrl/api/quran/search', queryParameters: {'q': query});
      return (response.data as List).cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  // ─── Helper ───

  Future<List<Map<String, dynamic>>> _getList(String endpoint) async {
    try {
      final response = await _dio.get('$baseUrl$endpoint');
      final list = response.data as List;
      return list.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }
}

/// API'den gelen wallpaper verisini Dart modeline donusturur.
class ApiWallpaper {
  final String id;
  final String asset;
  final String imageUrl;
  final String category;
  final String verseText;
  final String surahName;
  final String verseNumbers;
  final bool isPremium;

  const ApiWallpaper({
    required this.id,
    required this.asset,
    required this.imageUrl,
    required this.category,
    required this.verseText,
    required this.surahName,
    required this.verseNumbers,
    this.isPremium = false,
  });

  factory ApiWallpaper.fromJson(Map<String, dynamic> json) {
    return ApiWallpaper(
      id: json['id']?.toString() ?? '',
      asset: json['asset'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      category: json['category'] ?? 'Duvar Kagitlari',
      verseText: json['verseText'] ?? '',
      surahName: json['surahName'] ?? '',
      verseNumbers: json['verseNumbers'] ?? '',
      isPremium: json['isPremium'] == true,
    );
  }
}
