import 'package:dio/dio.dart';

/// Tek bir günün namaz vakitleri.
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

/// Aladhan API üzerinden namaz vakitlerini çeken servis.
///
/// Endpoint: https://api.aladhan.com/v1/timings/{timestamp}?latitude={lat}&longitude={lng}&method=13
/// Method 13 = Diyanet İşleri Başkanlığı hesaplama yöntemi.
class PrayerTimesService {
  PrayerTimesService._();

  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 8),
    receiveTimeout: const Duration(seconds: 10),
  ));

  /// Belirtilen koordinat ve tarih için namaz vakitlerini getirir.
  static Future<PrayerDay> fetch({
    required double lat,
    required double lng,
    DateTime? date,
  }) async {
    final d = date ?? DateTime.now();
    // Gün/ay/yıl formatında istek — timezone sorunu olmaz
    final dateStr = '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';

    final resp = await _dio.get(
      'https://api.aladhan.com/v1/timings/$dateStr',
      queryParameters: {
        'latitude': lat,
        'longitude': lng,
        'method': 13, // Diyanet
      },
    );

    final data = resp.data['data'];
    final timings = data['timings'] as Map<String, dynamic>;
    final hijri = data['date']['hijri'];

    // İmsak = Fajr
    final imsak = _extract(timings, 'Fajr');
    final gunes = _extract(timings, 'Sunrise');
    final ogle = _extract(timings, 'Dhuhr');
    final ikindi = _extract(timings, 'Asr');
    final aksam = _extract(timings, 'Maghrib');
    final yatsi = _extract(timings, 'Isha');

    // Kuşluk ≈ Güneş + 45 dk (işrak sonrası)
    final kusluk = _addMinutes(gunes, 45);
    // Teheccüd ≈ Yatsı ile İmsak arası orta nokta, gece yarısına yakın
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
  }

  /// "HH:MM" formatındaki saati parse eder.
  static String _extract(Map<String, dynamic> timings, String key) {
    final raw = timings[key] as String? ?? '00:00';
    // "03:45 (EEST)" gibi timezone'lu formatı temizle
    return raw.split(' ').first;
  }

  /// "HH:MM" saatine [minutes] dakika ekler.
  static String _addMinutes(String time, int minutes) {
    final parts = time.split(':');
    final h = int.parse(parts[0]);
    final m = int.parse(parts[1]);
    final total = h * 60 + m + minutes;
    final newH = (total ~/ 60) % 24;
    final newM = total % 60;
    return '${newH.toString().padLeft(2, '0')}:${newM.toString().padLeft(2, '0')}';
  }

  /// Hicri ayların API'den gelen İngilizce isim → Türkçe karşılıkları.
  /// API bazen özel karakterli (Ṣafar, Rabīʿ) dönebilir.
  static const Map<String, String> _hijriMonthsTr = {
    'Muharram': 'Muharrem', 'Muḥarram': 'Muharrem',
    'Safar': 'Safer', 'Ṣafar': 'Safer',
    'Rabi al-Awwal': 'Rebiülevvel', 'Rabīʿ al-Awwal': 'Rebiülevvel', 'Rabi al-awwal': 'Rebiülevvel',
    'Rabi al-Thani': 'Rebiülahir', 'Rabīʿ al-Thānī': 'Rebiülahir', 'Rabi al-thani': 'Rebiülahir',
    'Jumada al-Awwal': 'Cemaziyelevvel', 'Jumādā al-Ūlā': 'Cemaziyelevvel', 'Jumada al-awwal': 'Cemaziyelevvel',
    'Jumada al-Thani': 'Cemaziyelahir', 'Jumādā al-Thānī': 'Cemaziyelahir', 'Jumada al-thani': 'Cemaziyelahir',
    'Rajab': 'Recep',
    'Sha\'ban': 'Şaban', 'Shaʿbān': 'Şaban', 'Shaban': 'Şaban',
    'Ramadan': 'Ramazan', 'Ramaḍān': 'Ramazan',
    'Shawwal': 'Şevval', 'Shawwāl': 'Şevval',
    'Dhu al-Qi\'dah': 'Zilkade', 'Dhū al-Qiʿdah': 'Zilkade', 'Dhu al-Qidah': 'Zilkade',
    'Dhu al-Hijjah': 'Zilhicce', 'Dhū al-Ḥijjah': 'Zilhicce',
  };

  /// "HH:MM" iki saat arasındaki gecenin son üçte birlik dilimini hesaplar.
  static String _nightMiddle(String isha, String fajr) {
    final iParts = isha.split(':');
    final fParts = fajr.split(':');
    final iMin = int.parse(iParts[0]) * 60 + int.parse(iParts[1]);
    int fMin = int.parse(fParts[0]) * 60 + int.parse(fParts[1]);
    // İmsak ertesi günün sabahı olduğu için 24*60 ekle
    if (fMin < iMin) fMin += 24 * 60;
    final mid = iMin + (fMin - iMin) ~/ 2;
    final h = (mid ~/ 60) % 24;
    final m = mid % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }
}
