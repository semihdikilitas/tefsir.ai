import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// Tek bir hadis-i şerifi temsil eder.
class _HadisEntry {
  final String topic;
  final String category;
  final String arabic;
  final String text;
  final String source;

  const _HadisEntry({
    required this.topic,
    required this.category,
    required this.arabic,
    required this.text,
    required this.source,
  });
}

const List<String> _categories = [
  'Tümü', 'İman & İhlas', 'Ahlak', 'İbadet', 'İlim', 'Aile', 'Sosyal Hayat',
];

const List<_HadisEntry> _allHadisler = [
  _HadisEntry(
    topic: 'Ameller Niyetlere Göredir',
    category: 'İman & İhlas',
    arabic: 'إِنَّمَا الْأَعْمَالُ بِالنِّيَّاتِ، وَإِنَّمَا لِكُلِّ امْرِئٍ مَا نَوَى',
    text: 'Ameller ancak niyetlere göredir. Herkese niyet ettiği şey vardır.',
    source: 'Buhârî, Bed\'ü\'l-Vahy, 1; Müslim, İmâre, 155',
  ),
  _HadisEntry(
    topic: 'Müslüman, Elinden ve Dilinden Güvende Olunan Kişidir',
    category: 'Ahlak',
    arabic: 'الْمُسْلِمُ مَنْ سَلِمَ الْمُسْلِمُونَ مِنْ لِسَانِهِ وَيَدِهِ',
    text: 'Müslüman, diğer Müslümanların elinden ve dilinden güvende olduğu kimsedir.',
    source: 'Buhârî, Îmân, 4; Müslim, Îmân, 64',
  ),
  _HadisEntry(
    topic: 'Kolaylaştırınız, Zorlaştırmayınız',
    category: 'Ahlak',
    arabic: 'يَسِّرُوا وَلَا تُعَسِّرُوا، وَبَشِّرُوا وَلَا تُنَفِّرُوا',
    text: 'Kolaylaştırın, zorlaştırmayın; müjdeleyin, nefret ettirmeyin.',
    source: 'Buhârî, İlim, 11; Müslim, Cihâd, 6',
  ),
  _HadisEntry(
    topic: 'Kendisi İçin İstediğini Kardeşi İçin de İstemek',
    category: 'Ahlak',
    arabic: 'لَا يُؤْمِنُ أَحَدُكُمْ حَتَّى يُحِبَّ لِأَخِيهِ مَا يُحِبُّ لِنَفْسِهِ',
    text: 'Sizden biriniz, kendisi için istediğini kardeşi için de istemedikçe (gerçek anlamda) iman etmiş olmaz.',
    source: 'Buhârî, Îmân, 7; Müslim, Îmân, 71',
  ),
  _HadisEntry(
    topic: 'Namazın Önemi',
    category: 'İbadet',
    arabic: 'الصَّلَاةُ عِمَادُ الدِّينِ',
    text: 'Namaz dinin direğidir.',
    source: 'Beyhakî, Şuabü\'l-Îmân',
  ),
];

class HadisiSerifScreen extends StatefulWidget {
  const HadisiSerifScreen({super.key});

  @override
  State<HadisiSerifScreen> createState() => _HadisiSerifScreenState();
}

class _HadisiSerifScreenState extends State<HadisiSerifScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String _selectedCategory = 'Tümü';

  late final _HadisEntry _gununHadisi;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    _gununHadisi = _allHadisler[dayOfYear % _allHadisler.length];
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_HadisEntry> get _filtered {
    return _allHadisler.where((h) {
      final matchesCategory = _selectedCategory == 'Tümü' || h.category == _selectedCategory;
      final matchesQuery = _query.isEmpty ||
          h.topic.toLowerCase().contains(_query) ||
          h.text.toLowerCase().contains(_query);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  void _showDetail(_HadisEntry entry) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (_) => _HadisDetailDialog(entry: entry),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.gold),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Hadis-i Şerif',
          style: TextStyle(color: AppColors.gold, fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 10),
                _buildSearchField(),
                const SizedBox(height: 16),
                _buildCategoryChips(),
                const SizedBox(height: 16),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  if (_query.isEmpty && _selectedCategory == 'Tümü') ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildGununHadisiCard(),
                    ),
                    const SizedBox(height: 24),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Tüm Hadisler',
                          style: TextStyle(color: AppColors.textLight, fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  _buildList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.15)),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: AppColors.textLight, fontSize: 15),
        decoration: InputDecoration(
          hintText: 'Hadislerde ara...',
          hintStyle: TextStyle(color: AppColors.textLight.withValues(alpha: 0.4), fontSize: 15),
          prefixIcon: Icon(Icons.search_rounded, color: AppColors.gold.withValues(alpha: 0.7), size: 22),
          suffixIcon: _query.isEmpty
              ? null
              : IconButton(
                  icon: Icon(Icons.close_rounded, color: AppColors.textLight.withValues(alpha: 0.5), size: 18),
                  onPressed: () => _searchController.clear(),
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = cat == _selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.gold : AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.gold : AppColors.gold.withValues(alpha: 0.15),
                ),
              ),
              child: Text(
                cat,
                style: TextStyle(
                  color: isSelected ? AppColors.textDark : AppColors.textLight.withValues(alpha: 0.7),
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGununHadisiCard() {
    return GestureDetector(
      onTap: () => _showDetail(_gununHadisi),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.2), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.wb_twilight_rounded, color: AppColors.gold, size: 22),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Günün Hadisi',
                  style: TextStyle(color: AppColors.gold, fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 1.0),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              _gununHadisi.topic,
              style: const TextStyle(color: AppColors.textLight, fontSize: 20, fontWeight: FontWeight.w800, height: 1.3),
            ),
            const SizedBox(height: 14),
            Text(
              _gununHadisi.text,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.7), fontSize: 14, height: 1.6),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Tamamını Oku',
                  style: TextStyle(color: AppColors.gold.withValues(alpha: 0.8), fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward_rounded, color: AppColors.gold.withValues(alpha: 0.8), size: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    final items = _filtered;
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Text(
            'Sonuç bulunamadı.',
            style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.5), fontSize: 15),
          ),
        ),
      );
    }
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _buildHadisCard(items[index]),
    );
  }

  Widget _buildHadisCard(_HadisEntry entry) {
    return GestureDetector(
      onTap: () => _showDetail(entry),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.1)),
        ),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Sol altın vurgu çizgisi (dua sayfasından farklı tasarım)
              Container(
                width: 5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.gold.withValues(alpha: 0.6),
                      AppColors.gold.withValues(alpha: 0.15),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 8, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.topic,
                        style: const TextStyle(color: AppColors.textLight, fontSize: 15, fontWeight: FontWeight.w700, height: 1.25),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        entry.text,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.55), fontSize: 13, height: 1.4),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.source_rounded, color: AppColors.gold.withValues(alpha: 0.4), size: 12),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              entry.source,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: AppColors.gold.withValues(alpha: 0.5), fontSize: 10.5, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(Icons.chevron_right_rounded, color: AppColors.gold.withValues(alpha: 0.4), size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ─── ORTADA AÇILAN HADİS DETAY DİYALOĞU ───
class _HadisDetailDialog extends StatelessWidget {
  final _HadisEntry entry;
  const _HadisDetailDialog({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.2), width: 1),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 16, 16, 0),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close_rounded, color: AppColors.textLight.withValues(alpha: 0.5), size: 20),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // İkon — hadise özel farklı ikon
                    Center(
                      child: Container(
                        width: 56,
                        height: 56,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.gold.withValues(alpha: 0.3), width: 1.5),
                        ),
                        child: const Icon(Icons.menu_book_rounded, color: AppColors.gold, size: 28),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      entry.topic,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textLight, fontSize: 20, fontWeight: FontWeight.w800, height: 1.3),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.gold.withValues(alpha: 0.15)),
                          ),
                          child: Text(
                            entry.category,
                            style: TextStyle(color: AppColors.gold.withValues(alpha: 0.75), fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    // Arapça metin kutusu — hadis için daha resmi, çerçeveli
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.gold.withValues(alpha: 0.12)),
                      ),
                      child: Text(
                        entry.arabic,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.gold, fontSize: 24, fontWeight: FontWeight.w600, height: 1.9),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Meal
                    _hadisBlock('MEALİ', Icons.translate_rounded, entry.text),
                    const SizedBox(height: 14),
                    // Kaynak — hadise özel, vurgulu
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.gold.withValues(alpha: 0.12)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.source_rounded, color: AppColors.gold.withValues(alpha: 0.7), size: 16),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'KAYNAK',
                                  style: TextStyle(color: AppColors.gold.withValues(alpha: 0.5), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.0),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  entry.source,
                                  style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.8), fontSize: 13, height: 1.5, fontStyle: FontStyle.italic),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _hadisBlock(String label, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.025),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.gold.withValues(alpha: 0.6), size: 15),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(color: AppColors.gold.withValues(alpha: 0.6), fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: 0.8),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.9), fontSize: 14, height: 1.6),
          ),
        ],
      ),
    );
  }
}
