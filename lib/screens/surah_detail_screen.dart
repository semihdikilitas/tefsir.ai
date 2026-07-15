import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../data/models/quran_models.dart';
import '../data/services/quran_service.dart';

const List<String> _arabicIndicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

/// 12 -> "١٢" gibi Arapça-Hint rakamlarına çevirir (Mushaf'ta ayet
/// numaraları böyle yazılır).
String _toArabicIndic(int number) {
  return number.toString().split('').map((d) => _arabicIndicDigits[int.parse(d)]).join();
}

/// Tek bir sureyi, gerçek bir Mushaf sayfası hissi verecek şekilde —
/// Arapça metin akıcı ve kesintisiz, ayet numaraları küçük madalyonlar
/// halinde metnin içine gömülü — gösteren ekran. Bir ayete dokunulduğunda
/// altta mealini ve (açıksa) okunuşunu gösteren bir panel açılır.
class SurahDetailScreen extends StatefulWidget {
  final int surahNumber;

  const SurahDetailScreen({super.key, required this.surahNumber});

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  Surah? _surah;
  String? _error;
  bool _showTransliteration = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final surah = await QuranService.instance.getSurah(widget.surahNumber);
      if (!mounted) return;
      setState(() => _surah = surah);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Sure yüklenemedi:\n$e');
    }
  }

  void _showAyahSheet(Ayah ayah) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _AyahDetailSheet(
        ayah: ayah,
        showTransliteration: _showTransliteration,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final surah = _surah;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.gold),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          surah?.turkishName ?? '',
          style: const TextStyle(color: AppColors.gold, fontSize: 20, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            tooltip: 'Okunuşu göster/gizle',
            icon: Icon(
              _showTransliteration ? Icons.subtitles_rounded : Icons.subtitles_off_rounded,
              color: AppColors.gold,
            ),
            onPressed: () => setState(() => _showTransliteration = !_showTransliteration),
          ),
        ],
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(child: _buildBody(surah)),
      ),
    );
  }

  Widget _buildBody(Surah? surah) {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SelectableText(
            _error!,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.7), fontSize: 13),
          ),
        ),
      );
    }
    if (surah == null) {
      return const Center(child: CircularProgressIndicator(color: AppColors.gold));
    }
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
      children: [
        _buildSurahHeader(surah),
        _buildMushafPage(surah),
      ],
    );
  }

  Widget _buildSurahHeader(Surah surah) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.2), width: 1.2),
      ),
      child: Column(
        children: [
          Text(
            surah.name,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.gold, fontSize: 32, fontWeight: FontWeight.w600, height: 1.3),
          ),
          const SizedBox(height: 10),
          Text(
            '${surah.transliteration} · ${surah.isMeccan ? 'Mekkî' : 'Medenî'} · ${surah.totalVerses} Ayet',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.6), fontSize: 13),
          ),
          // Besmele: Tevbe (9) suresi hariç her surenin başında geleneksel olarak okunur.
          // Fâtiha'da (1) besmele zaten metnin ilk ayeti olduğu için tekrar gösterilmiyor.
          if (surah.number != 9 && surah.number != 1) ...[
            const SizedBox(height: 16),
            Divider(color: AppColors.gold.withValues(alpha: 0.15), height: 1),
            const SizedBox(height: 16),
            const Text(
              'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textLight, fontSize: 22, fontWeight: FontWeight.w500, height: 1.6),
            ),
          ],
          const SizedBox(height: 14),
          Text(
            'Ayet numarasına dokunarak mealini görebilirsin.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.gold.withValues(alpha: 0.55), fontSize: 11.5, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  /// Tüm ayetleri, gerçek bir Mushaf sayfasındaki gibi kesintisiz akan
  /// tek bir metin bloğu halinde, ayet sonlarına gömülü küçük numara
  /// madalyonlarıyla birlikte gösterir.
  Widget _buildMushafPage(Surah surah) {
    final spans = <InlineSpan>[];
    const arabicStyle = TextStyle(
      color: AppColors.textLight,
      fontSize: 24,
      height: 2.15,
      fontWeight: FontWeight.w500,
    );

    for (final ayah in surah.verses) {
      spans.add(TextSpan(text: '${ayah.text} ', style: arabicStyle));
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => _showAyahSheet(ayah),
              child: Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceElevated,
                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.55), width: 1.2),
                ),
                child: Text(
                  _toArabicIndic(ayah.number),
                  style: const TextStyle(color: AppColors.gold, fontSize: 12.5, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ),
      );
      spans.add(const TextSpan(text: ' '));
    }

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.1)),
      ),
      child: RichText(
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.justify,
        text: TextSpan(children: spans),
      ),
    );
  }
}

/// Bir ayete dokunulduğunda altta açılan, o ayetin Arapça metnini büyük
/// puntoyla, mealini ve (açıksa) okunuşunu gösteren panel.
class _AyahDetailSheet extends StatelessWidget {
  final Ayah ayah;
  final bool showTransliteration;

  const _AyahDetailSheet({required this.ayah, required this.showTransliteration});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.2), width: 1),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 24, offset: const Offset(0, 10)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.gold.withValues(alpha: 0.4), width: 1.2),
                  ),
                  child: Text(
                    '${ayah.number}',
                    style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: AppColors.surfaceElevated, shape: BoxShape.circle),
                    child: Icon(Icons.close_rounded, color: AppColors.textLight.withValues(alpha: 0.5), size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              ayah.text,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: const TextStyle(color: AppColors.textLight, fontSize: 24, height: 1.8, fontWeight: FontWeight.w500),
            ),
            if (showTransliteration && ayah.transliteration.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                ayah.transliteration,
                style: TextStyle(color: AppColors.gold.withValues(alpha: 0.8), fontSize: 13.5, fontStyle: FontStyle.italic, height: 1.5),
              ),
            ],
            const SizedBox(height: 16),
            Divider(color: AppColors.gold.withValues(alpha: 0.15), height: 1),
            const SizedBox(height: 16),
            Text(
              ayah.translation,
              style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.85), fontSize: 15, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}