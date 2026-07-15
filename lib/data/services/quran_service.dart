import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/quran_models.dart';

/// Kur'an verisini (assets/quran/quran_tr_full.json) yükleyip
/// uygulama boyunca RAM'de önbellekte tutan basit bir servis.
///
/// Kullanım:
///   final surahs = await QuranService.instance.loadSurahs();
class QuranService {
  QuranService._();
  static final QuranService instance = QuranService._();

  static const String _assetPath = 'assets/quran/quran_tr_full.json';

  List<Surah>? _cache;
  Future<List<Surah>>? _loadingFuture;

  /// Tüm sureleri (Arapça metin + Türkçe meal + okunuş) döndürür.
  /// İlk çağrıda asset'ten okuyup parse eder, sonrasında önbellekten döner.
  Future<List<Surah>> loadSurahs() {
    if (_cache != null) return Future.value(_cache);
    // Aynı anda birden fazla çağrı gelirse tek seferde yüklemeyi garanti et.
    return _loadingFuture ??= _load();
  }

  Future<List<Surah>> _load() async {
    final raw = await rootBundle.loadString(_assetPath);
    final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
    final surahs = decoded
        .map((e) => Surah.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
    _cache = surahs;
    return surahs;
  }

  /// Belirli bir sureyi numarasına (1-114) göre döndürür.
  Future<Surah> getSurah(int number) async {
    final surahs = await loadSurahs();
    return surahs.firstWhere((s) => s.number == number);
  }

  /// Sure adına (Arapça, Türkçe veya Latin okunuş) göre basit arama yapar.
  Future<List<Surah>> searchSurahs(String query) async {
    final surahs = await loadSurahs();
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return surahs;
    return surahs
        .where((s) =>
            s.turkishName.toLowerCase().contains(q) ||
            s.transliteration.toLowerCase().contains(q) ||
            s.name.contains(query.trim()) ||
            s.number.toString() == q)
        .toList();
  }
}
