import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/wallpapers.dart';
import '../../../data/services/wallpaper_preferences.dart';
import '../data/wallpaper_models.dart';

/// Ana ekrandaki dönen duvar kağıdı + ayet kartı.
/// 8 saniyede bir wallpaper ve ayet değişir.
class WallpaperVerseCard extends StatefulWidget {
  final int initialIndex;
  final void Function(int index, WallpaperItem item) onTap;
  final VoidCallback? onSetWallpaper;

  const WallpaperVerseCard({
    super.key,
    required this.initialIndex,
    required this.onTap,
    this.onSetWallpaper,
  });

  @override
  State<WallpaperVerseCard> createState() => _WallpaperVerseCardState();
}

class _WallpaperVerseCardState extends State<WallpaperVerseCard> {
  late int _currentIndex;
  Timer? _carouselTimer;
  bool _isPremium = false;

  List<WallpaperItem> get _wallpapers => WallpaperRegistry.all;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, _wallpapers.length - 1);
    _checkPremium();
    _startCarousel();
  }

  @override
  void didUpdateWidget(covariant WallpaperVerseCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      _currentIndex = widget.initialIndex.clamp(0, _wallpapers.length - 1);
    }
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkPremium() async {
    final premium = await WallpaperPreferences.isPremium;
    if (mounted) setState(() => _isPremium = premium);
  }

  void _startCarousel() {
    _carouselTimer?.cancel();
    _carouselTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (!mounted) return;
      setState(() {
        _currentIndex = (_currentIndex + 1) % _wallpapers.length;
      });
      WallpaperPreferences.saveWallpaperIndex(_currentIndex);
    });
  }

  void _goTo(int index) {
    _carouselTimer?.cancel();
    setState(() => _currentIndex = index.clamp(0, _wallpapers.length - 1));
    WallpaperPreferences.saveWallpaperIndex(_currentIndex);
    _startCarousel();
  }

  @override
  Widget build(BuildContext context) {
    final item = _wallpapers[_currentIndex];
    final locked = item.isPremium && !_isPremium;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => widget.onTap(_currentIndex, item),
            child: Stack(
              children: [
                // Duvar kağıdı görseli (animasyonlu geçiş)
                Positioned.fill(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 800),
                    child: Image.asset(
                      item.assetPath,
                      key: ValueKey(item.asset),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),
                // Koyu overlay
                Positioned.fill(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 800),
                    color: Colors.black.withValues(alpha: 0.55),
                  ),
                ),
                // Ayet metni
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.format_quote_rounded,
                            color: AppColors.gold,
                            size: 28,
                          ),
                          const Spacer(),
                          if (locked)
                            Icon(
                              Icons.lock_rounded,
                              color: AppColors.gold.withValues(alpha: 0.7),
                              size: 18,
                            )
                          else if (widget.onSetWallpaper != null)
                            IconButton(
                              icon: const Icon(
                                Icons.wallpaper_rounded,
                                color: AppColors.gold,
                                size: 20,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: widget.onSetWallpaper,
                              tooltip: 'Duvar kağıdı yap',
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 600),
                        child: Text(
                          '"${item.verseText}"',
                          key: ValueKey(item.asset),
                          style: const TextStyle(
                            color: AppColors.textLight,
                            fontSize: 16,
                            height: 1.5,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 600),
                        child: Align(
                          alignment: Alignment.centerRight,
                          key: ValueKey('ref_${item.asset}'),
                          child: Text(
                            '${item.surahName}, ${item.verseNumbers}',
                            style: const TextStyle(
                              color: AppColors.gold,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Alt nokta göstergeleri (opsiyonel, ince bir gösterge)
                Positioned(
                  bottom: 8,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: _buildDotIndicator(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDotIndicator() {
    // Sadece 5 nokta göster, aktif ortada
    final total = _wallpapers.length;
    final dots = <Widget>[];
    for (var i = 0; i < total; i++) {
      final isActive = i == _currentIndex;
      dots.add(
        GestureDetector(
          onTap: () => _goTo(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isActive ? 8 : 5,
            height: 5,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.gold
                  : AppColors.gold.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
      );
    }
    // Mobilde çok nokta varsa sadece aktif civarını göster
    if (total <= 7) {
      return Row(mainAxisSize: MainAxisSize.min, children: dots);
    }
    // Uzun liste: sadece aktif + 2 önce + 2 sonra
    final visible = <Widget>[];
    for (var i = 0; i < total; i++) {
      if ((i - _currentIndex).abs() <= 2 || i == 0 || i == total - 1) {
        final isActive = i == _currentIndex;
        visible.add(
          GestureDetector(
            onTap: () => _goTo(i),
            child: Container(
              width: isActive ? 7 : 4,
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.gold
                    : AppColors.gold.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        );
      }
    }
    return Row(mainAxisSize: MainAxisSize.min, children: visible);
  }
}
