import 'package:shared_preferences/shared_preferences.dart';

/// Premium abonelik servisi.
/// Gercek IAP entegrasyonu yapilana kadar SharedPreferences uzerinden calisir.
/// Yayinda in_app_purchase paketi ile degistirilecek.
class PremiumService {
  static const _premiumKey = 'is_premium';
  static const _premiumExpiryKey = 'premium_expiry_date';

  PremiumService._();

  /// Premium durumu
  static Future<bool> get isPremium async {
    final prefs = await SharedPreferences.getInstance();
    final premium = prefs.getBool(_premiumKey) ?? false;

    // Suresi dolmus mu kontrol et
    if (premium) {
      final expiry = prefs.getString(_premiumExpiryKey);
      if (expiry != null) {
        final expiryDate = DateTime.tryParse(expiry);
        if (expiryDate != null && DateTime.now().isAfter(expiryDate)) {
          // Suresi dolmus, premium'u kapat
          await prefs.setBool(_premiumKey, false);
          return false;
        }
      }
    }

    return premium;
  }

  /// Premium'u ac (test/gelistirme icin)
  static Future<void> activate({int days = 365}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_premiumKey, true);
    final expiry = DateTime.now().add(Duration(days: days));
    await prefs.setString(_premiumExpiryKey, expiry.toIso8601String());
  }

  /// Premium'u kapat
  static Future<void> deactivate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_premiumKey, false);
    await prefs.remove(_premiumExpiryKey);
  }

  /// Premium bitis tarihi
  static Future<DateTime?> get expiryDate async {
    final prefs = await SharedPreferences.getInstance();
    final expiry = prefs.getString(_premiumExpiryKey);
    if (expiry == null) return null;
    return DateTime.tryParse(expiry);
  }

  /// Premium'un gercek satin alma ile mi alindigi
  /// Simdilik false, IAP entegrasyonu sonrasi true donecek
  static Future<bool> get isRealPurchase async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('premium_real_purchase') ?? false;
  }
}
