import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// Günlük hayatta okunan bir duayı temsil eder.
class _DuaEntry {
  final String title;
  final String category;
  final String arabic;
  final String transliteration;
  final String meaning;
  final String note;

  const _DuaEntry({
    required this.title,
    required this.category,
    required this.arabic,
    required this.transliteration,
    required this.meaning,
    required this.note,
  });
}

const List<String> _categories = [
  'Tümü',
  'Sabah / Akşam',
  'Günlük Yaşam',
  'Yemek',
  'Uyku',
  'Yolculuk',
  'Zor Anlarda',
];

const List<_DuaEntry> _allDualar = [
  _DuaEntry(
    title: 'Sabah Duası',
    category: 'Sabah / Akşam',
    arabic: 'اَللّٰهُمَّ بِكَ اَصْبَحْنَا وَبِكَ اَمْسَيْنَا وَبِكَ نَحْيَا وَبِكَ نَمُوتُ وَاِلَيْكَ النُّشُورُ',
    transliteration: 'Allâhümme bike asbahnâ ve bike emseynâ ve bike nahyâ ve bike nemûtü ve ileykenNüşûr.',
    meaning: 'Allah\'ım! Sabaha Senin lütfunla eriştik, akşama Senin lütfunla ereriz. Senin (izninle) yaşarız, Senin (iznin) ile ölürüz. Dönüş de ancak Sanadır.',
    note: 'Sabah kalkınca, güne başlarken okunur.',
  ),
  _DuaEntry(
    title: 'Akşam Duası',
    category: 'Sabah / Akşam',
    arabic: 'اَللّٰهُمَّ بِكَ اَمْسَيْنَا وَبِكَ اَصْبَحْنَا وَبِكَ نَحْيَا وَبِكَ نَمُوتُ وَاِلَيْكَ الْمَصِيرُ',
    transliteration: 'Allâhümme bike emseynâ ve bike asbahnâ ve bike nahyâ ve bike nemûtü ve ileykel-masîr.',
    meaning: 'Allah\'ım! Akşama Senin lütfunla eriştik, sabaha da Senin lütfunla ereriz. Dönüşümüz de ancak Sanadır.',
    note: 'Akşam olduğunda, akşam namazına yakın okunur.',
  ),
  _DuaEntry(
    title: 'Evden Çıkarken Dua',
    category: 'Günlük Yaşam',
    arabic: 'بِسْمِ اللّٰهِ تَوَكَّلْتُ عَلَى اللّٰهِ وَلَا حَوْلَ وَلَا قُوَّةَ اِلَّا بِاللّٰهِ',
    transliteration: 'Bismillâhi tevekkeltü alallâhi ve lâ havle ve lâ kuvvete illâ billâh.',
    meaning: 'Allah\'ın adıyla, Allah\'a güvendim. Güç ve kuvvet ancak Allah\'tandır.',
    note: 'Evden çıkarken eşikte okunur.',
  ),
  _DuaEntry(
    title: 'Eve Girerken Dua',
    category: 'Günlük Yaşam',
    arabic: 'اَللّٰهُمَّ اِنّٖى اَسْـَٔلُكَ خَيْرَ الْمَوْلِجِ وَخَيْرَ الْمَخْرَجِ بِسْمِ اللّٰهِ وَلَجْنَا وَبِسْمِ اللّٰهِ خَرَجْنَا وَعَلَى اللّٰهِ رَبِّنَا تَوَكَّلْنَا',
    transliteration: 'Allâhümme innî es\'elüke hayral-mevlici ve hayral-mahrec, bismillâhi velecnâ ve bismillâhi haracnâ ve alâllâhi Rabbinâ tevekkelnâ.',
    meaning: 'Allah\'ım! Senden girişin ve çıkışın hayırlısını isterim. Allah\'ın adıyla girdik, Allah\'ın adıyla çıktık ve Rabbimiz Allah\'a güvendik.',
    note: 'Eve girerken kapı eşiğinde okunur.',
  ),
  _DuaEntry(
    title: 'Tuvalete Girerken Dua',
    category: 'Günlük Yaşam',
    arabic: 'اَللّٰهُمَّ اِنّٖى اَعُوذُ بِكَ مِنَ الْخُبُثِ وَالْخَبَائِثِ',
    transliteration: 'Allâhümme innî eûzü bike minel-hubsi vel-habâis.',
    meaning: 'Allah\'ım! Habis erkek ve dişi şeytanların şerrinden Sana sığınırım.',
    note: 'Tuvalete girmeden önce, sol ayakla girerken okunur.',
  ),
  _DuaEntry(
    title: 'Tuvaletten Çıkarken Dua',
    category: 'Günlük Yaşam',
    arabic: 'غُفْرَانَكَ',
    transliteration: 'Gufrâneke.',
    meaning: 'Allah\'ım, bağışlamanı dilerim.',
    note: 'Tuvaletten sağ ayakla çıkarken okunur.',
  ),
  _DuaEntry(
    title: 'Yemekten Önce Dua',
    category: 'Yemek',
    arabic: 'بِسْمِ اللّٰهِ',
    transliteration: 'Bismillâh.',
    meaning: 'Allah\'ın adıyla (başlarım).',
    note: 'Yemeğe başlamadan önce okunur; unutulursa "Bismillâhi evvelehû ve âhirehû" denir.',
  ),
  _DuaEntry(
    title: 'Yemekten Sonra Dua',
    category: 'Yemek',
    arabic: 'اَلْحَمْدُ لِلّٰهِ الَّذٖى اَطْعَمَنٖى هٰذَا وَرَزَقَنٖيهِ مِنْ غَيْرِ حَوْلٍ مِنّٖى وَلَا قُوَّةٍ',
    transliteration: 'Elhamdü lillâhillezî at\'amenî hâzâ ve rezekanîhi min gayri havlin minnî ve lâ kuvveh.',
    meaning: 'Bende bir güç ve kuvvet olmaksızın bu yemeği bana yediren ve rızık olarak veren Allah\'a hamd olsun.',
    note: 'Yemek bittikten hemen sonra okunur.',
  ),
  _DuaEntry(
    title: 'Su İçerken Dua',
    category: 'Yemek',
    arabic: 'اَلْحَمْدُ لِلّٰهِ الَّذٖى سَقَانَا عَذْبًا فُرَاتًا بِرَحْمَتِهٖ وَلَمْ يَجْعَلْهُ مِلْحًا اُجَاجًا بِذُنُوبِنَا',
    transliteration: 'Elhamdü lillâhillezî sekânâ azben furâten bi-rahmetihî ve lem yec\'alhü milhan ücâcen bi-zünûbinâ.',
    meaning: 'Bizi rahmetiyle tatlı ve içimi kolay suyla sulayan, günahlarımız sebebiyle onu tuzlu ve acı kılmayan Allah\'a hamd olsun.',
    note: 'Su içtikten sonra okunması tavsiye edilir.',
  ),
  _DuaEntry(
    title: 'Uyumadan Önce Dua',
    category: 'Uyku',
    arabic: 'بِاسْمِكَ اللّٰهُمَّ اَمُوتُ وَاَحْيَا',
    transliteration: 'Bismike Allâhümme emûtü ve ahyâ.',
    meaning: 'Allah\'ım! Senin adınla ölür (uyur) ve dirilirim (uyanırım).',
    note: 'Uyumadan önce, eller yanağın altına konularak okunur.',
  ),
  _DuaEntry(
    title: 'Uyanınca Okunan Dua',
    category: 'Uyku',
    arabic: 'اَلْحَمْدُ لِلّٰهِ الَّذٖى اَحْيَانَا بَعْدَ مَا اَمَاتَنَا وَاِلَيْهِ النُّشُورُ',
    transliteration: 'Elhamdü lillâhillezî ahyânâ ba\'de mâ emâtenâ ve ileyhin-nüşûr.',
    meaning: 'Bizi öldürdükten (uyuttuktan) sonra dirilten (uyandıran) Allah\'a hamd olsun. Dönüş ancak O\'nadır.',
    note: 'Uykudan uyanınca okunur.',
  ),
  _DuaEntry(
    title: 'Yolculuğa Çıkarken Dua',
    category: 'Yolculuk',
    arabic: 'سُبْحَانَ الَّذٖى سَخَّرَ لَنَا هٰذَا وَمَا كُنَّا لَهُ مُقْرِنٖينَ وَاِنَّٓا اِلٰى رَبِّنَا لَمُنْقَلِبُونَ',
    transliteration: 'Sübhânellezî sehhara lenâ hâzâ ve mâ künnâ lehû mukrinîn ve innâ ilâ Rabbinâ lemunkalibûn.',
    meaning: 'Bunu bizim hizmetimize veren Allah\'ı tesbih ederiz, yoksa bizim buna gücümüz yetmezdi. Şüphesiz biz Rabbimize döneceğiz.',
    note: 'Bineğe/araca binerken, yolculuk başlarken okunur (Zuhruf, 13-14).',
  ),
  _DuaEntry(
    title: 'Yolculuktan Dönüşte Dua',
    category: 'Yolculuk',
    arabic: 'اٰيِبُونَ تَٓائِبُونَ عَابِدُونَ لِرَبِّنَا حَامِدُونَ',
    transliteration: 'Âyibûne tâibûne âbidûne li-Rabbinâ hâmidûn.',
    meaning: 'Biz (Allah\'a) dönen, tövbe eden, ibadet eden ve Rabbimize hamd edenleriz.',
    note: 'Yolculuktan/seferden dönerken okunur.',
  ),
  _DuaEntry(
    title: 'Ezan Duası',
    category: 'Günlük Yaşam',
    arabic: 'اَللّٰهُمَّ رَبَّ هٰذِهِ الدَّعْوَةِ التَّامَّةِ وَالصَّلَاةِ الْقَٓائِمَةِ اٰتِ مُحَمَّدًا نِ الْوَسٖيلَةَ وَالْفَضٖيلَةَ وَابْعَثْهُ مَقَامًا مَحْمُودًا نِ الَّذٖى وَعَدْتَهُ',
    transliteration: 'Allâhümme Rabbe hâzihid-da\'vetit-tâmmeh, ves-salâtil-kâimeh, âti Muhammedenil-vesîlete vel-fadîleh, veb\'ashü makâmen mahmûdenillezî vaadteh.',
    meaning: 'Ey bu eksiksiz davetin ve kılınacak namazın Rabbi olan Allah\'ım! Muhammed\'e vesileyi ve fazileti ver, O\'nu vaad ettiğin makam-ı mahmûda ulaştır.',
    note: 'Ezan bittikten sonra okunur.',
  ),
  _DuaEntry(
    title: 'Namaz Sonrası İstiğfar',
    category: 'Günlük Yaşam',
    arabic: 'اَسْتَغْفِرُ اللّٰهَ ، اَسْتَغْفِرُ اللّٰهَ ، اَسْتَغْفِرُ اللّٰهَ ، اَللّٰهُمَّ اَنْتَ السَّلَامُ وَمِنْكَ السَّلَامُ تَبَارَكْتَ يَا ذَا الْجَلَالِ وَالْاِكْرَامِ',
    transliteration: 'Estağfirullâh, estağfirullâh, estağfirullâh. Allâhümme entes-selâmü ve minkes-selâm, tebârekte yâ zel-celâli vel-ikrâm.',
    meaning: 'Allah\'tan bağışlanma dilerim (üç kez). Allah\'ım! Selâm Sensin, esenlik Sendendir. Ey azamet ve ikram sahibi olan Allah\'ım, Sen yücesin.',
    note: 'Farz namazların hemen ardından okunur.',
  ),
  _DuaEntry(
    title: 'Sıkıntı Anında Okunan Dua',
    category: 'Zor Anlarda',
    arabic: 'حَسْبُنَا اللّٰهُ وَنِعْمَ الْوَكٖيلُ',
    transliteration: 'Hasbünallâhü ve ni\'mel-vekîl.',
    meaning: 'Allah bize yeter, O ne güzel vekildir.',
    note: 'Sıkıntı, korku ve zorluk anlarında okunur (Âl-i İmrân, 173).',
  ),
  _DuaEntry(
    title: 'Musibet Anında Okunan Dua',
    category: 'Zor Anlarda',
    arabic: 'اِنَّا لِلّٰهِ وَاِنَّٓا اِلَيْهِ رَاجِعُونَ',
    transliteration: 'İnnâ lillâhi ve innâ ileyhi râciûn.',
    meaning: 'Şüphesiz biz Allah\'a aitiz ve şüphesiz O\'na döneceğiz.',
    note: 'Bir musibet, kayıp veya kötü haber karşısında okunur (Bakara, 156).',
  ),
  _DuaEntry(
    title: 'Kur\'an Okumaya Başlarken',
    category: 'Zor Anlarda',
    arabic: 'اَعُوذُ بِاللّٰهِ مِنَ الشَّيْطَانِ الرَّجٖيمِ. بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحٖيمِ',
    transliteration: 'Eûzü billâhi mineş-şeytânir-racîm. Bismillâhir-rahmânir-rahîm.',
    meaning: 'Kovulmuş şeytanın şerrinden Allah\'a sığınırım. Rahmân ve Rahîm olan Allah\'ın adıyla.',
    note: 'Kur\'an-ı Kerim tilavetine başlarken okunur.',
  ),
  _DuaEntry(
    title: 'Anne-Babaya Dua',
    category: 'Zor Anlarda',
    arabic: 'رَبِّ ارْحَمْهُمَا كَمَا رَبَّيَانٖى صَغٖيرًا',
    transliteration: 'Rabbirhamhümâ kemâ rabbeyânî sağîrâ.',
    meaning: 'Rabbim! Onlar beni küçükken nasıl (sevgiyle) büyüttülerse, Sen de onlara öylece merhamet et.',
    note: 'Anne baba için her zaman, özellikle namaz sonrası okunur (İsrâ, 24).',
  ),
];

class GunlukDualarScreen extends StatefulWidget {
  const GunlukDualarScreen({super.key});

  @override
  State<GunlukDualarScreen> createState() => _GunlukDualarScreenState();
}

class _GunlukDualarScreenState extends State<GunlukDualarScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String _selectedCategory = 'Tümü';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_DuaEntry> get _filtered {
    return _allDualar.where((d) {
      final matchesCategory = _selectedCategory == 'Tümü' || d.category == _selectedCategory;
      final matchesQuery = _query.isEmpty ||
          d.title.toLowerCase().contains(_query) ||
          d.meaning.toLowerCase().contains(_query);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  void _showDetail(_DuaEntry entry) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (_) => _DuaDetailDialog(entry: entry),
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
          'Günlük Dualar',
          style: TextStyle(color: AppColors.gold, fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            _buildSearchField(),
            const SizedBox(height: 14),
            _buildCategoryChips(),
            const SizedBox(height: 10),
            Expanded(child: _buildList()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.15)),
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(color: AppColors.textLight, fontSize: 15),
          decoration: InputDecoration(
            hintText: 'Dua adı veya anlamda ara...',
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
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
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
              padding: const EdgeInsets.symmetric(horizontal: 18),
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
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildList() {
    final items = _filtered;
    if (items.isEmpty) {
      return Center(
        child: Text(
          'Sonuç bulunamadı.',
          style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.5), fontSize: 15),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) => _buildDuaCard(items[index]),
    );
  }

  Widget _buildDuaCard(_DuaEntry entry) {
    return GestureDetector(
      onTap: () => _showDetail(entry),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.volunteer_activism_rounded, color: AppColors.gold, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.title,
                    style: const TextStyle(color: AppColors.textLight, fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          entry.category,
                          style: TextStyle(color: AppColors.gold.withValues(alpha: 0.75), fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.gold.withValues(alpha: 0.5), size: 22),
          ],
        ),
      ),
    );
  }
}

/// ─── ORTADA AÇILAN DUA DETAY DİYALOĞU ───
class _DuaDetailDialog extends StatelessWidget {
  final _DuaEntry entry;
  const _DuaDetailDialog({required this.entry});

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
              // Üst: kapatma butonu
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
                    // İkon
                    Center(
                      child: Container(
                        width: 56,
                        height: 56,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFD4AF37), Color(0xFFE8C547)],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.volunteer_activism_rounded, color: Colors.black87, size: 28),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Başlık
                    Text(
                      entry.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textLight, fontSize: 20, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          entry.category,
                          style: TextStyle(color: AppColors.gold.withValues(alpha: 0.85), fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    // Arapça — dua sayfasında daha büyük ve öne çıkan
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.gold.withValues(alpha: 0.08),
                            AppColors.gold.withValues(alpha: 0.02),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.gold.withValues(alpha: 0.15)),
                      ),
                      child: Text(
                        entry.arabic,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.gold, fontSize: 28, fontWeight: FontWeight.w600, height: 2.0),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _block('OKUNUŞU', Icons.record_voice_over_rounded, entry.transliteration, italic: true),
                    const SizedBox(height: 16),
                    _block('ANLAMI', Icons.translate_rounded, entry.meaning),
                    const SizedBox(height: 16),
                    _block('NE ZAMAN OKUNUR', Icons.schedule_rounded, entry.note),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _block(String label, IconData icon, String text, {bool italic = false}) {
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
            style: TextStyle(
              color: AppColors.textLight.withValues(alpha: 0.9),
              fontSize: 14,
              height: 1.6,
              fontStyle: italic ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ],
      ),
    );
  }
}
