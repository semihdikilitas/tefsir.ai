import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// Reklam banner widget'ı.
///
/// Şu an placeholder olarak çalışıyor. AdMob entegrasyonu için:
/// 1. pubspec.yaml'a `google_mobile_ads: ^5.2.0` ekle
/// 2. ios/Podfile'a `ENV['COCOAPODS_DISABLE_SWIFT_PACKAGE_MANAGER'] = '1'` ekle
/// 3. Bu widget'ı gerçek BannerAd ile değiştir
class AdBanner extends StatelessWidget {
  const AdBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.ad_units_rounded, color: AppColors.gold.withValues(alpha: 0.35), size: 18),
          const SizedBox(width: 10),
          Text(
            'Reklam Alanı',
            style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.25), fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text('AdMob', style: TextStyle(color: AppColors.gold, fontSize: 10, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
