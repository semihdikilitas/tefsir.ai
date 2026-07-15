import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// Esmaül Hüsna'daki tek bir ismi (sırası, Arapça yazılışı, okunuşu, anlamı) temsil eder.
class _EsmaEntry {
  final int number;
  final String name;
  final String arabic;
  final String meaning;

  const _EsmaEntry(this.number, this.name, this.arabic, this.meaning);
}

// Allah'ın 99 ismi — Tirmizî ve İbn Mâce rivayetlerinde geçen sıra esas alınmıştır.
const List<_EsmaEntry> _allEsma = [
  _EsmaEntry(1, 'Allah', 'اللَّهُ', 'Kendisinden başka ilah olmayan, bütün güzel isimleri kendinde toplayan öz ad.'),
  _EsmaEntry(2, 'er-Rahmân', 'الرَّحْمنُ', 'Dünyada bütün yaratılmışlara sınırsız merhamet eden.'),
  _EsmaEntry(3, 'er-Rahîm', 'الرَّحِيمُ', 'Ahirette özellikle inananlara merhamet eden.'),
  _EsmaEntry(4, 'el-Melik', 'الْمَلِكُ', 'Mülkün ve kâinatın gerçek ve tek sahibi.'),
  _EsmaEntry(5, 'el-Kuddûs', 'الْقُدُّوسُ', 'Her türlü eksiklikten ve kusurdan tamamen uzak, tertemiz.'),
  _EsmaEntry(6, 'es-Selâm', 'السَّلاَمُ', 'Her türlü afet ve kusurdan uzak, esenlik ve güven kaynağı.'),
  _EsmaEntry(7, 'el-Mü\'min', 'الْمُؤْمِنُ', 'Güven veren, kalplere iman ve emniyet bahşeden.'),
  _EsmaEntry(8, 'el-Müheymin', 'الْمُهَيْمِنُ', 'Her şeyi gözetip koruyan, kâinatı yöneten.'),
  _EsmaEntry(9, 'el-Azîz', 'الْعَزِيزُ', 'Karşı konulamaz izzet ve üstünlük sahibi.'),
  _EsmaEntry(10, 'el-Cebbâr', 'الْجَبَّارُ', 'Dilediğini yaptırmaya gücü yeten, azamet sahibi.'),
  _EsmaEntry(11, 'el-Mütekebbir', 'الْمُتَكَبِّرُ', 'Büyüklükte eşi ve benzeri olmayan.'),
  _EsmaEntry(12, 'el-Hâlik', 'الْخَالِقُ', 'Her şeyi yoktan var eden yaratıcı.'),
  _EsmaEntry(13, 'el-Bâri\'', 'الْبَارِئُ', 'Yarattıklarını birbiriyle uyumlu ve dengeli biçimde var eden.'),
  _EsmaEntry(14, 'el-Musavvir', 'الْمُصَوِّرُ', 'Varlıklara şekil, suret ve özellik veren.'),
  _EsmaEntry(15, 'el-Gaffâr', 'الْغَفَّارُ', 'Günahları tekrar tekrar bağışlayan.'),
  _EsmaEntry(16, 'el-Kahhâr', 'الْقَهَّارُ', 'Her şeye galip gelen, hiçbir engel tanımayan.'),
  _EsmaEntry(17, 'el-Vehhâb', 'الْوَهَّابُ', 'Karşılık beklemeden sürekli ve bol bağışta bulunan.'),
  _EsmaEntry(18, 'er-Rezzâk', 'الرَّزَّاقُ', 'Bütün canlıların rızkını veren.'),
  _EsmaEntry(19, 'el-Fettâh', 'الْفَتَّاحُ', 'Her türlü zorluğu çözen, adaletle hükmeden.'),
  _EsmaEntry(20, 'el-Alîm', 'الْعَلِيمُ', 'Görüneni de gizliyi de, her şeyi bilen.'),
  _EsmaEntry(21, 'el-Kâbız', 'الْقَابِضُ', 'Dilediğinde rızkı ve nimeti daraltan.'),
  _EsmaEntry(22, 'el-Bâsıt', 'الْبَاسِطُ', 'Dilediğinde rızkı ve nimeti genişleten.'),
  _EsmaEntry(23, 'el-Hâfıd', 'الْخَافِضُ', 'Dilediğini alçaltan, değersiz kılan.'),
  _EsmaEntry(24, 'er-Râfi', 'الرَّافِعُ', 'Dilediğini yükselten, şereflendiren.'),
  _EsmaEntry(25, 'el-Muizz', 'الْمُعِزُّ', 'Dilediğine izzet, şeref ve itibar veren.'),
  _EsmaEntry(26, 'el-Müzill', 'الْمُذِلُّ', 'Dilediğini alçaltıp hor kılan.'),
  _EsmaEntry(27, 'es-Semî', 'السَّمِيعُ', 'Her şeyi işiten, duaları duyan.'),
  _EsmaEntry(28, 'el-Basîr', 'الْبَصِيرُ', 'Her şeyi gören, hiçbir şey gözünden kaçmayan.'),
  _EsmaEntry(29, 'el-Hakem', 'الْحَكَمُ', 'Adaletle hükmeden, son sözü söyleyen.'),
  _EsmaEntry(30, 'el-Adl', 'الْعَدْلُ', 'Mutlak adalet sahibi.'),
  _EsmaEntry(31, 'el-Latîf', 'اللَّطِيفُ', 'En ince işlerin inceliklerini bilen, lütufkâr.'),
  _EsmaEntry(32, 'el-Habîr', 'الْخَبِيرُ', 'Her şeyin iç yüzünden ve gizli tarafından haberdar olan.'),
  _EsmaEntry(33, 'el-Halîm', 'الْحَلِيمُ', 'Cezalandırmaya gücü yettiği halde yumuşak davranan.'),
  _EsmaEntry(34, 'el-Azîm', 'الْعَظِيمُ', 'Sınırsız büyüklük ve yücelik sahibi.'),
  _EsmaEntry(35, 'el-Gafûr', 'الْغَفُورُ', 'Çokça affeden, günahları örten.'),
  _EsmaEntry(36, 'eş-Şekûr', 'الشَّكُورُ', 'Az bir iyiliğe bile büyük karşılık veren.'),
  _EsmaEntry(37, 'el-Aliyy', 'الْعَلِيُّ', 'Şan, şeref ve hükümranlıkta en yüce olan.'),
  _EsmaEntry(38, 'el-Kebîr', 'الْكَبِيرُ', 'Zâtı ve sıfatlarıyla sınırsız büyük olan.'),
  _EsmaEntry(39, 'el-Hafîz', 'الْحَفِيظُ', 'Her şeyi koruyup gözeten, afetlerden saklayan.'),
  _EsmaEntry(40, 'el-Mukît', 'الْمُقِيتُ', 'Yarattıklarının rızkını takdir edip ulaştıran.'),
  _EsmaEntry(41, 'el-Hasîb', 'الْحَسِيبُ', 'Herkesin hesabını en ince ayrıntısına kadar gören.'),
  _EsmaEntry(42, 'el-Celîl', 'الْجَلِيلُ', 'Azamet ve büyüklük sahibi.'),
  _EsmaEntry(43, 'el-Kerîm', 'الْكَرِيمُ', 'Karşılıksız, cömertçe ikramda bulunan.'),
  _EsmaEntry(44, 'er-Rakîb', 'الرَّقِيبُ', 'Her an her şeyi gözetleyip kontrol altında tutan.'),
  _EsmaEntry(45, 'el-Mücîb', 'الْمُجِيبُ', 'Duaları işitip kabul eden.'),
  _EsmaEntry(46, 'el-Vâsi', 'الْوَاسِعُ', 'İlmi, rahmeti ve ihsanı sınırsız genişlikte olan.'),
  _EsmaEntry(47, 'el-Hakîm', 'الْحَكِيمُ', 'Her işi hikmetle, bir amaca uygun yapan.'),
  _EsmaEntry(48, 'el-Vedûd', 'الْوَدُودُ', 'Kullarını çok seven ve sevilmeye en layık olan.'),
  _EsmaEntry(49, 'el-Mecîd', 'الْمَجِيدُ', 'Şanı ve şerefi çok yüce, övgüye layık olan.'),
  _EsmaEntry(50, 'el-Bâis', 'الْبَاعِثُ', 'Ölüleri dirilten, peygamberler gönderen.'),
  _EsmaEntry(51, 'eş-Şehîd', 'الشَّهِيدُ', 'Her yerde ve her an her şeye tanık olan.'),
  _EsmaEntry(52, 'el-Hakk', 'الْحَقُّ', 'Varlığı hiç değişmeyen mutlak gerçek.'),
  _EsmaEntry(53, 'el-Vekîl', 'الْوَكِيلُ', 'Kendisine güvenilip işlerin emanet edildiği.'),
  _EsmaEntry(54, 'el-Kavî', 'الْقَوِيُّ', 'Sınırsız güç ve kuvvet sahibi.'),
  _EsmaEntry(55, 'el-Metîn', 'الْمَتِينُ', 'Kudreti hiçbir şekilde sarsılmayan, çok sağlam.'),
  _EsmaEntry(56, 'el-Velî', 'الْوَلِيُّ', 'Müminlerin dostu, yardımcısı ve destekçisi.'),
  _EsmaEntry(57, 'el-Hamîd', 'الْحَمِيدُ', 'Her daim övgüye ve şükre layık olan.'),
  _EsmaEntry(58, 'el-Muhsî', 'الْمُحْصِي', 'Her şeyin sayısını tek tek bilen.'),
  _EsmaEntry(59, 'el-Mübdi', 'الْمُبْدِئُ', 'Varlıkları örneksiz ve yoktan yaratan.'),
  _EsmaEntry(60, 'el-Muîd', 'الْمُعِيدُ', 'Öldükten sonra yeniden diriltecek olan.'),
  _EsmaEntry(61, 'el-Muhyî', 'الْمُحْيِي', 'Can veren, hayat bahşeden.'),
  _EsmaEntry(62, 'el-Mümît', 'الْمُمِيتُ', 'Ölümü yaratan, canlıya ölümü tattıran.'),
  _EsmaEntry(63, 'el-Hayy', 'الْحَيُّ', 'Ezelî ve ebedî hayat sahibi, gerçek diri.'),
  _EsmaEntry(64, 'el-Kayyûm', 'الْقَيُّومُ', 'Bütün varlığı ayakta tutan, kendi kendine kaim olan.'),
  _EsmaEntry(65, 'el-Vâcid', 'الْوَاجِدُ', 'Dilediğini dilediği an bulan, hiçbir şeye muhtaç olmayan.'),
  _EsmaEntry(66, 'el-Mâcid', 'الْمَاجِدُ', 'Şanı, kerâmeti ve cömertliği çok yüce olan.'),
  _EsmaEntry(67, 'el-Vâhid', 'الْوَاحِدُ', 'Zâtında, sıfatlarında ve işlerinde eşi ve ortağı olmayan tek.'),
  _EsmaEntry(68, 'es-Samed', 'الصَّمَدُ', 'Hiçbir şeye muhtaç olmayan, herkesin kendisine muhtaç olduğu.'),
  _EsmaEntry(69, 'el-Kâdir', 'الْقَادِرُ', 'Dilediğini dilediği gibi yaratmaya gücü yeten.'),
  _EsmaEntry(70, 'el-Muktedir', 'الْمُقْتَدِرُ', 'Kudretini dilediği gibi, sınırsız kullanan.'),
  _EsmaEntry(71, 'el-Mukaddim', 'الْمُقَدِّمُ', 'Dilediğini öne alan, ileri geçiren.'),
  _EsmaEntry(72, 'el-Muahhir', 'الْمُؤَخِّرُ', 'Dilediğini geri bırakan, erteleyen.'),
  _EsmaEntry(73, 'el-Evvel', 'الأَوَّلُ', 'Varlığının başlangıcı olmayan, ilk olan.'),
  _EsmaEntry(74, 'el-Âhir', 'الآخِرُ', 'Varlığının sonu olmayan, son olan.'),
  _EsmaEntry(75, 'ez-Zâhir', 'الظَّاهِرُ', 'Varlığı delilleriyle apaçık ortada olan.'),
  _EsmaEntry(76, 'el-Bâtın', 'الْبَاطِنُ', 'Zâtının hakikati akılların kavrayışının ötesinde olan, gizliyi bilen.'),
  _EsmaEntry(77, 'el-Vâlî', 'الْوَالِي', 'Bütün kâinatı tek başına yöneten.'),
  _EsmaEntry(78, 'el-Müteâlî', 'الْمُتَعَالِي', 'Akılların kavrayabileceği her şeyden çok yüce olan.'),
  _EsmaEntry(79, 'el-Berr', 'الْبَرُّ', 'İyiliği ve ihsanı sınırsız bol olan.'),
  _EsmaEntry(80, 'et-Tevvâb', 'التَّوَّابُ', 'Tövbeleri kabul edip bağışlayan.'),
  _EsmaEntry(81, 'el-Müntakım', 'الْمُنْتَقِمُ', 'Zalimleri hak ettikleri cezaya çarptıran.'),
  _EsmaEntry(82, 'el-Afüvv', 'الْعَفُوُّ', 'Günahları affedip izlerini bile silen.'),
  _EsmaEntry(83, 'er-Raûf', 'الرَّؤُوفُ', 'Çok şefkatli, engin merhamet sahibi.'),
  _EsmaEntry(84, 'Mâlikü\'l-Mülk', 'مَالِكُ الْمُلْكِ', 'Mülkün ebedî ve tek sahibi.'),
  _EsmaEntry(85, 'Zü\'l-Celâli ve\'l-İkrâm', 'ذُو الْجَلاَلِ وَالإِكْرَامِ', 'Hem sınırsız azamet hem sonsuz kerem sahibi.'),
  _EsmaEntry(86, 'el-Muksit', 'الْمُقْسِطُ', 'Herkesin hakkını adaletle veren.'),
  _EsmaEntry(87, 'el-Câmi', 'الْجَامِعُ', 'Dilediğini dilediği yerde ve zamanda bir araya getiren.'),
  _EsmaEntry(88, 'el-Ganî', 'الْغَنِيُّ', 'Hiçbir şeye muhtaç olmayan, sınırsız zengin.'),
  _EsmaEntry(89, 'el-Muğnî', 'الْمُغْنِي', 'Dilediğini zengin kılan, ihtiyaçları gideren.'),
  _EsmaEntry(90, 'el-Mâni', 'الْمَانِعُ', 'Dilemediği şeyin gerçekleşmesine izin vermeyen.'),
  _EsmaEntry(91, 'ed-Dârr', 'الضَّارُّ', 'Hikmeti gereği zarar verebilecek şeyleri de yaratan.'),
  _EsmaEntry(92, 'en-Nâfi', 'النَّافِعُ', 'Fayda ve hayır veren şeyleri yaratan.'),
  _EsmaEntry(93, 'en-Nûr', 'النُّورُ', 'Kâinatı aydınlatan, nur kaynağı.'),
  _EsmaEntry(94, 'el-Hâdî', 'الْهَادِي', 'Dilediği kulunu doğru yola ileten.'),
  _EsmaEntry(95, 'el-Bedî', 'الْبَدِيعُ', 'Eşi ve örneği olmayan şeyler yaratan.'),
  _EsmaEntry(96, 'el-Bâkî', 'الْبَاقِي', 'Varlığının sonu olmayan, ebedî.'),
  _EsmaEntry(97, 'el-Vâris', 'الْوَارِثُ', 'Her şeyin gerçek ve son sahibi.'),
  _EsmaEntry(98, 'er-Reşîd', 'الرَّشِيدُ', 'Her işi ezelî hikmetiyle doğru sonuca ulaştıran.'),
  _EsmaEntry(99, 'es-Sabûr', 'الصَّبُورُ', 'Sonsuz sabır sahibi, cezalandırmakta acele etmeyen.'),
];

class EsmaulHusnaScreen extends StatefulWidget {
  const EsmaulHusnaScreen({super.key});

  @override
  State<EsmaulHusnaScreen> createState() => _EsmaulHusnaScreenState();
}

class _EsmaulHusnaScreenState extends State<EsmaulHusnaScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  late final _EsmaEntry _todaysEsma;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    _todaysEsma = _allEsma[dayOfYear % _allEsma.length];
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_EsmaEntry> get _filtered {
    if (_query.isEmpty) return _allEsma;
    return _allEsma.where((e) {
      return e.name.toLowerCase().contains(_query) || e.meaning.toLowerCase().contains(_query);
    }).toList();
  }

  void _showDetail(_EsmaEntry entry) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (context) => _buildDetailDialog(entry),
    );
  }

  Widget _buildDetailDialog(_EsmaEntry entry) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard, 
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.gold.withValues(alpha: 0.3), width: 1.5),
                  ),
                  child: Text(
                    '${entry.number}',
                    style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close_rounded, color: AppColors.textLight.withValues(alpha: 0.5), size: 22),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            Text(
              entry.arabic,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.gold, fontSize: 44, fontWeight: FontWeight.w600, height: 1.4),
            ),
            const SizedBox(height: 16),
            
            Text(
              entry.name,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textLight, fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(child: Divider(color: AppColors.gold.withValues(alpha: 0.15), height: 1)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Icon(Icons.auto_awesome_rounded, color: AppColors.gold.withValues(alpha: 0.6), size: 16),
                ),
                Expanded(child: Divider(color: AppColors.gold.withValues(alpha: 0.15), height: 1)),
              ],
            ),
            const SizedBox(height: 20),
            
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Text(
                  entry.meaning,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.85), fontSize: 16, height: 1.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        title: const Text(
          'Esmaül Hüsna',
          style: TextStyle(color: AppColors.gold, fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          _buildSearchField(),
          const SizedBox(height: 16),
          
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  if (_query.isEmpty) ...[
                    _buildTodaysEsmaCard(),
                    const SizedBox(height: 24),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Tüm İsimler',
                          style: TextStyle(color: AppColors.textLight, fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  _buildGrid(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
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
            hintText: 'İsim veya anlamda ara...',
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

  // Günün İsmi - Koyu Zümrüt Zemin ve Altın Çerçeve
  Widget _buildTodaysEsmaCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: () => _showDetail(_todaysEsma),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard, // Gradient kaldırıldı, zemin tamamen koyu zümrüt oldu
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.3), width: 1.5), // Parlayan altın çerçeve
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.auto_awesome_rounded, color: AppColors.gold, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Günün İsmi',
                    style: TextStyle(color: AppColors.gold, fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 1.0),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      _todaysEsma.name,
                      style: const TextStyle(color: AppColors.textLight, fontSize: 24, fontWeight: FontWeight.w800),
                    ),
                  ),
                  Text(
                    _todaysEsma.arabic,
                    style: const TextStyle(color: AppColors.gold, fontSize: 32, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                _todaysEsma.meaning,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.7), fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrid() {
    final items = _filtered;
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Text(
            'Sonuç bulunamadı.',
            style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.5), fontSize: 15),
          ),
        ),
      );
    }
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16, 
        crossAxisSpacing: 16,
        childAspectRatio: 0.9, 
      ),
      itemBuilder: (context, index) => _buildEsmaCard(items[index]),
    );
  }

  Widget _buildEsmaCard(_EsmaEntry entry) {
    return GestureDetector(
      onTap: () => _showDetail(entry),
      child: Container(
        padding: const EdgeInsets.all(16), 
        decoration: BoxDecoration(
          color: AppColors.surfaceCard, 
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${entry.number}',
                style: const TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
            const Spacer(),
            Center(
              child: Text(
                entry.arabic,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.gold, fontSize: 28, fontWeight: FontWeight.w600), 
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                entry.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.textLight, fontSize: 16, fontWeight: FontWeight.w700), 
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}