import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/wallpapers.dart';
import '../data/wallpaper_models.dart';
import 'wallpaper_fullscreen_screen.dart';

/// Duvar kagidi galerisi.
/// En ustte "Bugunun Duvar Kagidi" belirgin sekilde gosterilir.
/// Altinda kategorilere gore tum duvar kagitlari listelenir.
class WallpaperBrowserScreen extends StatefulWidget {
  final bool isPremium;

  const WallpaperBrowserScreen({super.key, this.isPremium = false});

  @override
  State<WallpaperBrowserScreen> createState() => _WallpaperBrowserScreenState();
}

class _WallpaperBrowserScreenState extends State<WallpaperBrowserScreen> {
  late int _todayIndex;

  @override
  void initState() {
    super.initState();
    _todayIndex = _calculateTodayIndex();
  }

  int _calculateTodayIndex() {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    return dayOfYear % WallpaperRegistry.all.length;
  }

  @override
  Widget build(BuildContext context) {
    final todayWallpaper = WallpaperRegistry.all[_todayIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceCard,
        elevation: 0,
        leading: const BackButton(color: AppColors.gold),
        title: const Text('Duvar Kagitlari',
            style: TextStyle(color: AppColors.textLight, fontSize: 18, fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          // ─── BUGUNUN DUVAR KAGIDI ───
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              Container(width: 3, height: 18, decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 10),
              const Text('Bugunun Duvar Kagidi', style: TextStyle(color: AppColors.gold, fontSize: 16, fontWeight: FontWeight.w700)),
              const Spacer(),
              _buildChangeBadge(),
            ]),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text('Her gece 00:00\'da yenisiyle degisir',
                style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.4), fontSize: 11)),
          ),
          const SizedBox(height: 12),
          // Bugunun duvar kagidi - buyuk kart
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildTodayHeroCard(todayWallpaper),
          ),
          const SizedBox(height: 28),

          // ─── TUM DUVAR KAGITLARI ───
          if (widget.isPremium) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(children: [
                Container(width: 3, height: 18, decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 10),
                Text('Tum Koleksiyon (${WallpaperRegistry.all.length})',
                    style: TextStyle(color: AppColors.gold.withValues(alpha: 0.6), fontSize: 14, fontWeight: FontWeight.w600)),
              ]),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 0.75,
                ),
                itemCount: WallpaperRegistry.all.length,
                itemBuilder: (context, index) {
                  final item = WallpaperRegistry.all[index];
                  return _buildGridItem(item, index, false);
                },
              ),
            ),
          ] else ...[
            // Premium degilse: blur'lu onizleme + mesaj
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.15)),
                ),
                child: Column(children: [
                  const Icon(Icons.auto_awesome_rounded, color: AppColors.gold, size: 40),
                  const SizedBox(height: 12),
                  const Text('Her gun yeni bir duvar kagidi seni bekliyor!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textLight, fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text('Premium\'a gec, 56 ozel duvar kagidina eris.\nHer gece 00:00\'da telefonunun duvar kagidi kendiliginden degissin.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.5), fontSize: 13, height: 1.5)),
                ]),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChangeBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
      ),
      child: const Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.refresh_rounded, color: AppColors.gold, size: 12),
        SizedBox(width: 4),
        Text('24 saat', style: TextStyle(color: AppColors.gold, fontSize: 10, fontWeight: FontWeight.w700)),
      ]),
    );
  }

  Widget _buildTodayHeroCard(WallpaperItem item) {
    final locked = item.isPremium && !widget.isPremium;
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => WallpaperFullscreenScreen(
            initialIndex: _todayIndex,
            isPremium: widget.isPremium,
            singleMode: true,
          ),
        ));
      },
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.3), width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Duvar kagidi resmi
              Image.asset(item.assetPath, fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(color: AppColors.surfaceCard)),
              // Overlay
              Container(color: Colors.black.withValues(alpha: 0.35)),
              // Ayet metni
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    Text(item.verseText,
                        textAlign: TextAlign.center, maxLines: 3, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5, fontWeight: FontWeight.w500,
                            shadows: [Shadow(color: Colors.black87, blurRadius: 6)])),
                    const SizedBox(height: 10),
                    Text('${item.surahName}, ${item.verseNumbers}',
                        style: const TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.w600,
                            shadows: [Shadow(color: Colors.black, blurRadius: 4)])),
                    const SizedBox(height: 12),
                    // Indir / Duvar Kagidi Yap butonu
                    if (locked)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                        child: const Text('🔒 Premium', style: TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.w600)),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(20)),
                        child: const Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.download_rounded, color: AppColors.gold, size: 14),
                          SizedBox(width: 4),
                          Text('Indir / Uygula', style: TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.w700)),
                        ]),
                      ),
                    const Spacer(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridItem(WallpaperItem item, int index, bool locked) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => WallpaperFullscreenScreen(
            initialIndex: index,
            isPremium: widget.isPremium,
          ),
        ));
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: (index == _todayIndex)
              ? AppColors.gold.withValues(alpha: 0.5)
              : AppColors.gold.withValues(alpha: 0.1)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(item.assetPath, fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(color: AppColors.surfaceCard)),
              if (index == _todayIndex)
                Positioned(top: 0, left: 0, right: 0, child: Container(
                  color: AppColors.gold.withValues(alpha: 0.8),
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: const Text('BUGUN', textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.w800)),
                )),
              if (locked)
                Positioned(top: 6, right: 6, child: Icon(Icons.lock_rounded,
                    color: AppColors.gold.withValues(alpha: 0.8), size: 14)),
            ],
          ),
        ),
      ),
    );
  }
}
