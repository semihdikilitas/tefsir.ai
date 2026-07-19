import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/wallpapers.dart';
import '../../../core/services/wallpaper_service.dart';
import '../../../data/services/wallpaper_preferences.dart';
import '../data/wallpaper_models.dart';
import 'wallpaper_image.dart';

/// Tam ekran duvar kagidi goruntuleyici.
/// PageView ile kaydirma, InteractiveViewer ile pinch-to-zoom.
/// Ayet metni her zaman resmin ortasinda gorunur.
/// Duvar kagidi indirirken ayetle birlikte tek resim olarak kaydedilir.
class WallpaperFullscreenScreen extends StatefulWidget {
  final int initialIndex;
  final bool isPremium;
  final bool singleMode; // true = sadece bu wallpaper, kaydirma yok

  const WallpaperFullscreenScreen({
    super.key,
    required this.initialIndex,
    this.isPremium = false,
    this.singleMode = false,
  });

  @override
  State<WallpaperFullscreenScreen> createState() => _WallpaperFullscreenScreenState();
}

class _WallpaperFullscreenScreenState extends State<WallpaperFullscreenScreen> {
  late PageController _pageController;
  late int _currentPage;
  final GlobalKey _repaintKey = GlobalKey();
  bool _capturing = false;

  List<WallpaperItem> get _wallpapers => WallpaperRegistry.all;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialIndex.clamp(0, _wallpapers.length - 1);
    _pageController = PageController(initialPage: _currentPage);
    _enterFullscreen();
  }

  @override
  void dispose() {
    _exitFullscreen();
    _pageController.dispose();
    super.dispose();
  }

  void _enterFullscreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarIconBrightness: Brightness.light,
    ));
  }

  void _exitFullscreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  /// Ekranda gorunen resim + ayet metnini tek bir goruntu olarak yakalar.
  Future<Uint8List?> _captureCompositeImage() async {
    try {
      final boundary = _repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      return byteData?.buffer.asUint8List();
    } catch (e) {
      return null;
    }
  }

  Future<void> _setAsHomeDefault() async {
    await WallpaperPreferences.saveWallpaperIndex(_currentPage);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Ana ekrana sabitlendi ✓'),
        backgroundColor: AppColors.gold.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showSetWallpaperSheet() {
    final item = _wallpapers[_currentPage];
    final locked = item.isPremium && !widget.isPremium;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Icon(Icons.wallpaper_rounded, color: AppColors.gold, size: 40),
              const SizedBox(height: 12),
              const Text(
                'Duvar Kagidi Yap',
                style: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Resim ayet metniyle birlikte kaydedilir.',
                style: TextStyle(
                  color: AppColors.textLight.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              if (locked) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.lock_rounded, color: AppColors.gold, size: 24),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Bu duvar kagidi Premium uyelere ozeldir.',
                          style: TextStyle(color: AppColors.textLight, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                ListTile(
                  leading: const Icon(Icons.home_rounded, color: AppColors.gold),
                  title: const Text('Ana Ekrana Sabitle',
                      style: TextStyle(color: AppColors.textLight)),
                  subtitle: Text('Ana ekrandaki ayet kartinda bu duvar kagidi gosterilir.',
                      style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.5), fontSize: 12)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _setAsHomeDefault();
                  },
                ),
                const Divider(color: AppColors.gold, height: 1),
                ListTile(
                  leading: const Icon(Icons.phone_android_rounded, color: AppColors.gold),
                  title: const Text('Telefona Uygula',
                      style: TextStyle(color: AppColors.textLight)),
                  subtitle: Text('Ayet metniyle birlikte duvar kagidi yapilir.',
                      style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.5), fontSize: 12)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _setPhoneWallpaper();
                  },
                ),
                const Divider(color: AppColors.gold, height: 1),
                ListTile(
                  leading: const Icon(Icons.download_rounded, color: AppColors.gold),
                  title: const Text('Galeriye Kaydet',
                      style: TextStyle(color: AppColors.textLight)),
                  subtitle: Text('Ayet metniyle birlikte galeriye indirilir.',
                      style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.5), fontSize: 12)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _saveToGallery();
                  },
                ),
              ],
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _setPhoneWallpaper() async {
    setState(() => _capturing = true);
    final bytes = await _captureCompositeImage();
    setState(() => _capturing = false);

    if (bytes == null || !mounted) return;

    // Gecici dosyaya yaz
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/wallpaper_with_verse.png');
    await file.writeAsBytes(bytes);

    final success = await WallpaperService.setWallpaperFile(file.path);

    if (!mounted) return;

    if (success) {
      final message = Platform.isAndroid
          ? 'Duvar kagidi ayetle birlikte uygulandi ✓'
          : 'Gorsel fotograflara kaydedildi. Ayarlardan duvar kagidi yapabilirsiniz.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.gold.withValues(alpha: 0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Duvar kagidi uygulanamadi. Lutfen tekrar deneyin.'),
          backgroundColor: AppColors.error.withValues(alpha: 0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _saveToGallery() async {
    setState(() => _capturing = true);
    final bytes = await _captureCompositeImage();
    setState(() => _capturing = false);

    if (bytes == null || !mounted) return;

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/wallpaper_with_verse.png');
    await file.writeAsBytes(bytes);

    final success = await WallpaperService.saveToGallery(file.path);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Galeriye kaydedildi ✓' : 'Kaydedilemedi, lutfen tekrar deneyin.'),
        backgroundColor: success
            ? AppColors.gold.withValues(alpha: 0.9)
            : AppColors.error.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) _exitFullscreen();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: RepaintBoundary(
          key: _repaintKey,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // PageView — resim + ayet her sayfada birlikte
              // singleMode: sadece tek wallpaper, kaydirma kapali
              if (widget.singleMode)
                _buildWallpaperPage(_currentPage)
              else
                PageView.builder(
                  controller: _pageController,
                  itemCount: _wallpapers.length,
                  onPageChanged: (page) => setState(() => _currentPage = page),
                  itemBuilder: (context, index) {
                    return _buildWallpaperPage(index);
                  },
                ),

              // Ust bar — her zaman gorunur, yari seffaf
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.35),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.close_rounded, color: Colors.white, size: 26),
                            onPressed: () {
                              _exitFullscreen();
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        const Spacer(),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.35),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.wallpaper_rounded, color: Colors.white, size: 22),
                            onPressed: _showSetWallpaperSheet,
                            tooltip: 'Duvar kagidi yap',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),


              // Capture loading indicator
              if (_capturing)
                const Positioned.fill(
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.gold),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Tek bir wallpaper sayfasi: resim uzerine ayet metni sag ustte
  Widget _buildWallpaperPage(int index) {
    final item = _wallpapers[index];
    return InteractiveViewer(
      maxScale: 4.0,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Tam ekran resim (sunucu veya local)
          WallpaperImage(item: item, fit: BoxFit.cover),

          // Resmi hafif koyulastir (isigi azalt)
          Container(color: Colors.black.withValues(alpha: 0.25)),

          // Ayet metni — sag ust kosede
          Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                margin: const EdgeInsets.only(top: 100, right: 20),
                constraints: const BoxConstraints(maxWidth: 240),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.verseText,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.5,
                        fontWeight: FontWeight.w600,
                        shadows: [
                          Shadow(color: Color(0xAA000000), blurRadius: 10),
                          Shadow(color: Color(0x88000000), blurRadius: 20),
                          Shadow(color: Color(0xCC000000), blurRadius: 4),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${item.surahName}, ${item.verseNumbers}',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: Color(0xFFE8E0D0),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        shadows: [
                          Shadow(color: Color(0xAA000000), blurRadius: 8),
                          Shadow(color: Color(0xCC000000), blurRadius: 3),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
