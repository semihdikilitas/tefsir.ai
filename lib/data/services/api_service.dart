import 'package:dio/dio.dart';

/// Tefsir AI icerik API'sine erisim.
/// Sunucu adresi: .env veya ayarlardan alinabilir.
class ApiService {
  static final ApiService _instance = ApiService._();
  factory ApiService() => _instance;
  ApiService._();

  // TODO: Yayinda gercek sunucu adresiyle degistir
  // Ornek: 'https://api.tefsir.ai'
  // Yerel test icin Android emulator: 'http://10.0.2.2:3000'
  // iOS simulator: 'http://localhost:3000'
  static String baseUrl = 'http://10.0.2.2:3000';

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  /// Tum duvar kagitlarini getir
  Future<List<Map<String, dynamic>>> getWallpapers() async {
    return _getList('/api/wallpapers');
  }

  /// Gunun ayetlerini getir
  Future<List<Map<String, dynamic>>> getVerses() async {
    return _getList('/api/verses');
  }

  /// Hadisleri getir
  Future<List<Map<String, dynamic>>> getHadiths() async {
    return _getList('/api/hadiths');
  }

  /// Dualari getir
  Future<List<Map<String, dynamic>>> getPrayers() async {
    return _getList('/api/prayers');
  }

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
