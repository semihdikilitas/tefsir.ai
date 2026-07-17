import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/wallpapers.dart';
import '../data/wallpaper_models.dart';
import 'wallpaper_fullscreen_screen.dart';

/// Kategorilere göre gruplanmış duvar kağıdı galerisi.
/// AppDrawer üzerinden erişilir.
class WallpaperBrowserScreen extends StatelessWidget {
  final bool isPremium;

  const WallpaperBrowserScreen({super.key, this.isPremium = false});

  @override
  Widget build(BuildContext context) {
    final categories = WallpaperRegistry.byCategory;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceCard,
        elevation: 0,
        leading: const BackButton(color: AppColors.gold),
        title: const Text(
          'Duvar Kağıtları',
          style: TextStyle(
            color: AppColors.textLight,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: WallpaperRegistry.categories.length,
        itemBuilder: (context, index) {
          final category = WallpaperRegistry.categories[index];
          final wallpapers = categories[category];
          if (wallpapers == null || wallpapers.isEmpty) {
            return const SizedBox.shrink();
          }
          return _buildCategorySection(context, category, wallpapers);
        },
      ),
    );
  }

  Widget _buildCategorySection(
    BuildContext context,
    String category,
    List<WallpaperItem> wallpapers,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  category,
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${wallpapers.length}',
                  style: TextStyle(
                    color: AppColors.textLight.withValues(alpha: 0.4),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: wallpapers.length,
              itemBuilder: (context, index) {
                final item = wallpapers[index];
                final globalIndex = WallpaperRegistry.all.indexOf(item);
                return _buildThumbnailCard(context, item, globalIndex);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnailCard(
    BuildContext context,
    WallpaperItem item,
    int globalIndex,
  ) {
    final locked = item.isPremium && !isPremium;

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => WallpaperFullscreenScreen(
                initialIndex: globalIndex,
                isPremium: isPremium,
              ),
            ),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 140,
            height: 180,
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Küçük resim
                Hero(
                  tag: 'wallpaper_$globalIndex',
                  child: Image.asset(
                    item.assetPath,
                    fit: BoxFit.cover,
                  ),
                ),
                // Koyu overlay (alt kısımda metin için)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 50,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Color(0xCC000000),
                        ],
                      ),
                    ),
                    alignment: Alignment.bottomCenter,
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      item.surahName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                // Premium kilit rozeti
                if (locked)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(
                        Icons.lock_rounded,
                        color: AppColors.textDark,
                        size: 14,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
