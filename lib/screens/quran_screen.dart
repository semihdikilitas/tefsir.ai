import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_colors.dart';
import '../data/services/remote_asset_service.dart';

class QuranScreen extends StatefulWidget {
  final int initialPage;
  const QuranScreen({super.key, this.initialPage = 1});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  // Gerçek bir mushaf sayfasının kâğıt rengi: sıcak krem/bej tonu.
  static const Color pageBackground = Color(0xFFF3E8D6);
  // Mushaf'ta gerçek sayfa 1..604 arası. 000.png kapak/boş sayfa olduğu için atlıyoruz.
  static const int firstPage = 1;
  static const int lastPage = 604;

  late final PageController _controller;
  late int _currentPage;
  bool _showOverlay = true;

  bool _bookmarked = false;

  @override
  void initState() {
    super.initState();
    _loadSavedPage();
  }

  Future<void> _loadSavedPage() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getInt('quran_last_page') ?? widget.initialPage;
    _currentPage = saved.clamp(firstPage, lastPage);
    _bookmarked = prefs.getBool('quran_bookmarked') ?? false;
    _controller = PageController(initialPage: _currentPage - firstPage);
    if (mounted) setState(() {});
  }

  Future<void> _savePage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('quran_last_page', _currentPage);
  }

  Future<void> _toggleBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _bookmarked = !_bookmarked);
    await prefs.setBool('quran_bookmarked', _bookmarked);
  }

  @override
  void dispose() {
    _savePage();
    _controller.dispose();
    super.dispose();
  }

  String _assetFor(int page) =>
      'assets/quran/Quran-PNG-master/${page.toString().padLeft(3, '0')}.png';

  void _showJumpToPageSheet() {
    final textController = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: 24 + MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sayfaya Git',
                style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                '$firstPage - $lastPage arası bir sayfa numarası gir',
                style: TextStyle(
                    color: AppColors.textLight.withValues(alpha: 0.5),
                    fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: textController,
                keyboardType: TextInputType.number,
                autofocus: true,
                style: const TextStyle(color: AppColors.textLight, fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Sayfa no',
                  hintStyle: TextStyle(
                      color: AppColors.textLight.withValues(alpha: 0.35)),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.04),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(color: AppColors.gold, width: 1.2),
                  ),
                ),
                onSubmitted: (_) => _jumpFromField(textController.text),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.textDark,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () => _jumpFromField(textController.text),
                  child: const Text('Git',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _jumpFromField(String value) {
    final page = int.tryParse(value.trim());
    Navigator.pop(context);
    if (page == null) return;
    final clamped = page.clamp(firstPage, lastPage);
    _controller.jumpToPage(clamped - firstPage);
  }

  void _toggleOverlay() {
    setState(() => _showOverlay = !_showOverlay);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,
      body: GestureDetector(
        // Sayfaya dokununca üst/alt bar'ı göster/gizle
        onTap: _toggleOverlay,
        child: Stack(
          children: [
            // TAM EKRAN SAYFA GÖRÜNTÜLEYİCİ
            Positioned.fill(
              child: PageView.builder(
                controller: _controller,
                reverse: true,
                itemCount: lastPage - firstPage + 1,
                onPageChanged: (index) {
                  _currentPage = firstPage + index;
                  _savePage();
                  setState(() {});
                },
                itemBuilder: (context, index) {
                  final page = firstPage + index;
                  return Container(
                    color: pageBackground,
                    child: InteractiveViewer(
                      minScale: 1,
                      maxScale: 4,
                      child: Center(
                        child: _QuranPageImage(
                          page: page,
                          assetPath: _assetFor(page),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // ÜST BAR — yarı saydam, sayfa üzerine biner
            AnimatedOpacity(
              opacity: _showOverlay ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 250),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      pageBackground.withValues(alpha: 0.95),
                      pageBackground.withValues(alpha: 0.0),
                    ],
                  ),
                ),
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 4,
                  left: 4,
                  right: 4,
                  bottom: 8,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.black87.withValues(alpha: 0.7)),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'Kuran-ı Kerim',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF5A4A2F),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(_bookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                          color: _bookmarked ? const Color(0xFFB8860B) : Colors.black87.withValues(alpha: 0.7)),
                      tooltip: _bookmarked ? 'Yer imi kaldır' : 'Yer imi ekle',
                      onPressed: _toggleBookmark,
                    ),
                    IconButton(
                      icon: Icon(Icons.tag_rounded,
                          color: Colors.black87.withValues(alpha: 0.7)),
                      onPressed: _showJumpToPageSheet,
                    ),
                  ],
                ),
              ),
            ),

            // ALT SAYFA GÖSTERGESİ — küçük, yarı saydam hap
            AnimatedOpacity(
              opacity: _showOverlay ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 250),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom + 16,
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Sayfa $_currentPage / $lastPage',
                    style: const TextStyle(
                      color: Color(0xFFF3E8D6),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Kuran sayfasını önce uzak sunucudan (ya da önbellekten) yüklemeyi dener,
/// bulamazsa yerel `assetPath`'e düşer.
class _QuranPageImage extends StatefulWidget {
  final int page;
  final String assetPath;
  const _QuranPageImage({required this.page, required this.assetPath});

  @override
  State<_QuranPageImage> createState() => _QuranPageImageState();
}

class _QuranPageImageState extends State<_QuranPageImage> {
  String? _cachedPath;
  bool _triedRemote = false;

  @override
  void initState() {
    super.initState();
    _tryLoadRemote();
  }

  Future<void> _tryLoadRemote() async {
    final path = await RemoteAssetService.quranPage(widget.page);
    if (!mounted) return;
    if (path != null && await File(path).exists()) {
      setState(() {
        _cachedPath = path;
        _triedRemote = true;
      });
    } else {
      setState(() => _triedRemote = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Uzak dosya varsa göster
    if (_cachedPath != null) {
      return Image.file(
        File(_cachedPath!),
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => _localFallback(),
      );
    }
    // Henüz uzak denenmemişse yükleniyor göster
    if (!_triedRemote) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.gold, strokeWidth: 2),
      );
    }
    // Yerel asset'e düş
    return _localFallback();
  }

  Widget _localFallback() {
    return Image.asset(
      widget.assetPath,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => Center(
        child: Text(
          'Sayfa ${widget.page} yüklenemedi.\nassets/quran/Quran-PNG-master/ klasörünü\nveya sunucu bağlantısını kontrol et.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black.withValues(alpha: 0.5), fontSize: 13, height: 1.5),
        ),
      ),
    );
  }
}
