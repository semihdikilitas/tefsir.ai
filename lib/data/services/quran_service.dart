import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quran_models.dart';
import 'api_service.dart';

/// Kuran verisini sunucudan ceker, yerelde cache'ler.
/// Sunucuya erisilemezse built-in asset'ten okur (offline fallback).
class QuranService {
  QuranService._();
  static final QuranService instance = QuranService._();

  static const String _assetPath = 'assets/quran/quran_tr_full.json';
  static const String _cacheKey = 'quran_cache';

  List<Surah>? _cache;

  /// Tum sureleri dondurur.
  /// 1. API'den cekmeyi dener
  /// 2. Basarisizsa SharedPreferences cache'i dener
  /// 3. O da yoksa built-in asset'i okur
  Future<List<Surah>> loadSurahs() async {
    if (_cache != null) return _cache!;

    // 1. API dene
    try {
      final surahList = await ApiService().getSurahs();
      if (surahList.isNotEmpty) {
        // Her sureyi tek tek API'den cek (ilk acilista agir, sonra cache)
        // Ilk seferde hepsini cekme - lazy load
        _cache = [];
        return _cache!;
      }
    } catch (_) {}

    // 2. SharedPreferences cache dene
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_cacheKey);
      if (cached != null) {
        final decoded = jsonDecode(cached) as List<dynamic>;
        _cache = decoded.map((e) => Surah.fromJson(e as Map<String, dynamic>)).toList();
        return _cache!;
      }
    } catch (_) {}

    // 3. Built-in asset fallback
    return _loadFromAsset();
  }

  /// Belirli bir sureyi API'den ceker (cache'lemez, her seferinde taze)
  Future<Surah> getSurah(int number) async {
    // Once cache'e bak
    if (_cache != null) {
      final cached = _cache!.firstWhere((s) => s.number == number,
          orElse: () => Surah(number: 0, name: '', transliteration: '', turkishName: '', type: '', totalVerses: 0, verses: const []));
      if (cached.number != 0) return cached;
    }

    // API'den cek
    try {
      final json = await ApiService().getSurah(number);
      if (json != null) {
        return Surah.fromJson(json);
      }
    } catch (_) {}

    // Fallback: asset
    final surahs = await _loadFromAsset();
    return surahs.firstWhere((s) => s.number == number);
  }

  /// Built-in asset'ten yukleme
  Future<List<Surah>> _loadFromAsset() async {
    try {
      final raw = await rootBundle.loadString(_assetPath);
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      _cache = decoded
          .map((e) => Surah.fromJson(e as Map<String, dynamic>))
          .toList(growable: false);
      return _cache!;
    } catch (_) {
      return [];
    }
  }

  /// Tum sureleri SharedPreferences'a cache'le
  Future<void> cacheLocally(List<Surah> surahs) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode(surahs.map((s) => {
        'id': s.number,
        'name': s.name,
        'transliteration': s.transliteration,
        'translation': s.turkishName,
        'type': s.type,
        'total_verses': s.totalVerses,
        'verses': s.verses.map((v) => {
          'id': v.number,
          'text': v.text,
          'translation': v.translation,
          'transliteration': v.transliteration,
        }).toList(),
      }).toList());
      if (json.length < 5000000) { // 5MB uyari esigi
        await prefs.setString(_cacheKey, json);
      }
    } catch (_) {}
  }

  /// Sure adina gore arama
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
