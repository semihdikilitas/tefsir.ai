import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'api_service.dart';

/// Tek bir gunun namaz vakitleri.
class PrayerDay {
  final DateTime date;
  final String imsak;
  final String gunes;
  final String ogle;
  final String ikindi;
  final String aksam;
  final String yatsi;
  final String kusluk;
  final String teheccud;
  final String hijriDate;

  const PrayerDay({
    required this.date,
    required this.imsak,
    required this.gunes,
    required this.ogle,
    required this.ikindi,
    required this.aksam,
    required this.yatsi,
    required this.kusluk,
    required this.teheccud,
    required this.hijriDate,
  });
}

/// Namaz vakitlerini kendi sunucumuz uzerinden ceker.
class PrayerTimesService {
  PrayerTimesService._();

  static Future<PrayerDay> fetch({
    required double lat,
    required double lng,
    DateTime? date,
  }) async {
    final d = date ?? DateTime.now();
    final dateStr = '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';

    final url = '${ApiService.baseUrl}/api/prayer-times?latitude=$lat&longitude=$lng&method=13&date=$dateStr';

    final client = HttpClient();
    // Debug modda SSL hatalarini gormezden gel (emulator icin)
    if (kDebugMode) {
      client.badCertificateCallback = (cert, host, port) => true;
    }
    client.connectionTimeout = const Duration(seconds: 15);

    try {
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      client.close();

      final json = jsonDecode(body) as Map<String, dynamic>;
      final data = json['data'] as Map<String, dynamic>;
      final timings = data['timings'] as Map<String, dynamic>;
      final hijri = data['date']['hijri'] as Map<String, dynamic>;

      final imsak = _extract(timings, 'Fajr');
      final gunes = _extract(timings, 'Sunrise');
      final ogle = _extract(timings, 'Dhuhr');
      final ikindi = _extract(timings, 'Asr');
      final aksam = _extract(timings, 'Maghrib');
      final yatsi = _extract(timings, 'Isha');

      final kusluk = _addMinutes(gunes, 45);
      final teheccud = _nightMiddle(yatsi, imsak);

      final hijriMonthEn = hijri['month']['en'] as String? ?? '';
      final hijriMonthTr = _hijriMonthsTr[hijriMonthEn] ?? hijriMonthEn;
      final hijriText = '${hijri['day']} $hijriMonthTr ${hijri['year']}';

      return PrayerDay(
        date: d,
        imsak: imsak,
        gunes: gunes,
        ogle: ogle,
        ikindi: ikindi,
        aksam: aksam,
        yatsi: yatsi,
        kusluk: kusluk,
        teheccud: teheccud,
        hijriDate: hijriText,
      );
    } catch (e) {
      client.close();
      rethrow;
    }
  }

  static String _extract(Map<String, dynamic> timings, String key) {
    final raw = timings[key] as String? ?? '00:00';
    return raw.split(' ').first;
  }

  static String _addMinutes(String time, int minutes) {
    final parts = time.split(':');
    final h = int.parse(parts[0]);
    final m = int.parse(parts[1]);
    final total = h * 60 + m + minutes;
    final newH = (total ~/ 60) % 24;
    final newM = total % 60;
    return '${newH.toString().padLeft(2, '0')}:${newM.toString().padLeft(2, '0')}';
  }

  static const Map<String, String> _hijriMonthsTr = {
    'Muharram': 'Muharrem', 'Muḥarram': 'Muharrem',
    'Safar': 'Safer', 'Ṣafar': 'Safer',
    'Rabi al-Awwal': 'Rebiülevvel', 'Rabīʿ al-Awwal': 'Rebiülevvel',
    'Rabi al-Thani': 'Rebiülahir', 'Rabīʿ al-Thānī': 'Rebiülahir',
    'Jumada al-Awwal': 'Cemaziyelevvel', 'Jumādā al-Ūlā': 'Cemaziyelevvel',
    'Jumada al-Thani': 'Cemaziyelahir', 'Jumādā al-Thānī': 'Cemaziyelahir',
    'Rajab': 'Recep',
    'Sha\'ban': 'Şaban', 'Shaʿbān': 'Şaban', 'Shaban': 'Şaban',
    'Ramadan': 'Ramazan', 'Ramaḍān': 'Ramazan',
    'Shawwal': 'Şevval', 'Shawwāl': 'Şevval',
    'Dhu al-Qi\'dah': 'Zilkade', 'Dhū al-Qiʿdah': 'Zilkade',
    'Dhu al-Hijjah': 'Zilhicce', 'Dhū al-Ḥijjah': 'Zilhicce',
  };

  static String _nightMiddle(String isha, String fajr) {
    final iParts = isha.split(':');
    final fParts = fajr.split(':');
    final iMin = int.parse(iParts[0]) * 60 + int.parse(iParts[1]);
    int fMin = int.parse(fParts[0]) * 60 + int.parse(fParts[1]);
    if (fMin < iMin) fMin += 24 * 60;
    final mid = iMin + (fMin - iMin) ~/ 2;
    final h = (mid ~/ 60) % 24;
    final m = mid % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }
}
