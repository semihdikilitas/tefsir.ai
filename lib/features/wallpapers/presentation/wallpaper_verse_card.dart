import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/wallpapers.dart';
import '../data/wallpaper_models.dart';

/// Ana ekrandaki gunun ayeti + duvar kagidi karti.
/// 24 saatte bir, gece 00:00'da degisir.
/// Uzerine tiklayinca sadece o anki wallpaper tam ekran acilir.
class WallpaperVerseCard extends StatelessWidget {
  final int currentIndex;
  final void Function(int index, WallpaperItem item) onTap;
  final VoidCallback? onSetWallpaper;
  final bool isPremium;

  const WallpaperVerseCard({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.onSetWallpaper,
    this.isPremium = false,
  });

  @override
  Widget build(BuildContext context) {
    final wallpapers = WallpaperRegistry.all;
    if (wallpapers.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(24),
        ),
      );
    }
    final item = wallpapers[currentIndex.clamp(0, wallpapers.length - 1)];

    return GestureDetector(
      onTap: () => onTap(currentIndex, item),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          image: DecorationImage(
            image: AssetImage(item.assetPath),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.45),
              BlendMode.darken,
            ),
            onError: (exception, stackTrace) {},
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Ayet metni
              Text(
                item.verseText,
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textLight,
                  fontSize: 15,
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 8),
              // Sure bilgisi
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${item.surahName}, ${item.verseNumbers}',
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
