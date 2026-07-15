import 'package:flutter/material.dart';

/// AdMob reklam servisi — Banner + Interstitial + Rewarded.
///
/// google_mobile_ads SPM çakışması çözüldüğünde paketi ekleyip
/// aşağıdaki yorum satırlarını aktif et.
///
/// import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  AdService._();

  // ─── TEST ID'leri ───
  static const testAppId = 'ca-app-pub-3940256099942544~3347511713';
  static const testBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const testInterstitialId = 'ca-app-pub-3940256099942544/1033173712';
  static const testRewardedId = 'ca-app-pub-3940256099942544/5224354917';

  // ─── GERÇEK ID'ler ───
  static const appIdAndroid = 'ca-app-pub-XXXXXXXXXX~XXXXXXXXXX';
  static const appIdIOS = 'ca-app-pub-XXXXXXXXXX~XXXXXXXXXX';
  static const bannerAndroid = 'ca-app-pub-XXXXXXXXXX/XXXXXXXXXX';
  static const bannerIOS = 'ca-app-pub-XXXXXXXXXX/XXXXXXXXXX';
  static const interstitialAndroid = 'ca-app-pub-XXXXXXXXXX/XXXXXXXXXX';
  static const interstitialIOS = 'ca-app-pub-XXXXXXXXXX/XXXXXXXXXX';
  static const rewardedAndroid = 'ca-app-pub-XXXXXXXXXX/XXXXXXXXXX';
  static const rewardedIOS = 'ca-app-pub-XXXXXXXXXX/XXXXXXXXXX';

  static bool get isTest => true;

  // ─── INTERSTITIAL ZAMANLAYICI ───
  static DateTime _lastInterstitial = DateTime(2020);
  static DateTime _lastDailyInterstitial = DateTime(2020);

  /// 10 dakika kuralı: son interstitial'dan beri 10 dk geçti mi?
  static bool get canShowInterstitial {
    final elapsed = DateTime.now().difference(_lastInterstitial);
    return elapsed.inSeconds >= 600;
  }

  /// Günde bir kuralı: bugün hiç gösterildi mi?
  static bool get canShowDailyInterstitial {
    final now = DateTime.now();
    return _lastDailyInterstitial.day != now.day ||
        _lastDailyInterstitial.month != now.month ||
        _lastDailyInterstitial.year != now.year;
  }

  /// Interstitial gösterimini kaydet.
  static void markInterstitialShown() {
    final now = DateTime.now();
    _lastInterstitial = now;
    _lastDailyInterstitial = now;
  }

  // ─── BAŞLATMA ───
  /// ```dart
  /// static Future<void> init() async {
  ///   final config = RequestConfiguration(
  ///     maxAdContentRating: MaxAdContentRating.g,
  ///     tagForChildDirectedTreatment: TagForChildDirectedTreatment.yes,
  ///     tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.yes,
  ///   );
  ///   await MobileAds.instance.updateRequestConfiguration(config);
  ///   await MobileAds.instance.initialize();
  /// }
  /// ```
  static Future<void> init() async {}

  static String get bannerUnitId => isTest ? testBannerId : bannerAndroid;
  static String get interstitialUnitId => isTest ? testInterstitialId : interstitialAndroid;
  static String get rewardedUnitId => isTest ? testRewardedId : rewardedAndroid;
}

/// Interstitial reklam simülasyonu widget'ı.
///
/// google_mobile_ads aktif olduğunda bu widget gerçek InterstitialAd
/// ile değiştirilecek. Şu an 10 dk kuralına uyan bir placeholder gösterir.
class InterstitialAd {
  /// Interstitial göster.
  /// [daily]: true = günde bir kere, false = 10 dk'da bir (varsayılan)
  static Future<bool> show(BuildContext context, {bool daily = false}) async {
    if (daily && !AdService.canShowDailyInterstitial) return false;
    if (!daily && !AdService.canShowInterstitial) return false;

    // TODO google_mobile_ads: Gerçek InterstitialAd.load() + show()
    // final ad = InterstitialAd(
    //   adUnitId: AdService.interstitialUnitId,
    //   request: const AdRequest(),
    //   listener: FullScreenContentCallback(
    //     onAdDismissedFullScreenContent: (ad) { ad.dispose(); },
    //     onAdFailedToShowFullScreenContent: (ad, error) { ad.dispose(); },
    //   ),
    // );
    // await ad.load();
    // if (ad.responseInfo != null) ad.show();

    AdService.markInterstitialShown();

    // Placeholder gösterimi (gerçek reklam yerine geçici)
    if (context.mounted) {
      showDialog(
        context: context,
        barrierColor: Colors.black.withValues(alpha: 0.7),
        builder: (_) => const _InterstitialPlaceholder(),
      );
    }
    return true;
  }
}

/// Placeholder — gerçek reklam yokken gösterilen simülasyon.
class _InterstitialPlaceholder extends StatelessWidget {
  const _InterstitialPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.3)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.ad_units_rounded, color: Color(0xFFD4AF37), size: 40),
          const SizedBox(height: 16),
          const Text('Reklam', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Bu alan gerçek reklam gösterimi içindir.\nYayında Google AdMob interstitial\ngösterilecek.',
              textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13, height: 1.5)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Kapat ✕', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }
}
