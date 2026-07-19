import 'package:flutter/foundation.dart';
import '../../data/services/api_service.dart';
import '../../features/wallpapers/data/wallpaper_models.dart';

/// Tum duvar kagitlarinin ve eslestigi ayetlerin merkezi kaydi.
/// Her wallpaper bir ayetle eslestirilmistir.
///
/// Calisma sirasi:
/// 1. Sunucudan veri cekmeyi dener
/// 2. Basarili olursa API verisini kullanir
/// 3. Basarisiz olursa yerleşik (built-in) listeye duser (offline fallback)
class WallpaperRegistry {
  WallpaperRegistry._();

  /// API'den yuklenen dinamik liste (null ise built-in kullanilir)
  static List<WallpaperItem>? _remoteList;

  /// API'nin yuklenip yuklenmedigi
  static bool _loaded = false;

  /// Aktif duvar kagidi listesi:
  /// Sunucudan gelen veri varsa onu, yoksa built-in listeyi dondurur.
  static List<WallpaperItem> get all => _remoteList ?? _builtIn;

  /// Yerlesik (built-in) duvar kagitlari — sunucuya erisilemediginde kullanilir.
  static const List<WallpaperItem> _builtIn = [
    WallpaperItem(
      asset: 'istanbul.png',
      category: 'Duvar Kagitlari',
      verseText: 'Şüphesiz güçlükle beraber bir kolaylık vardır.',
      surahName: 'İnşirah Suresi',
      verseNumbers: '5-6',
      isPremium: false,
    ),
    WallpaperItem(
      asset: 'pexels-abbas-zaidi-2161151287-37929176.jpg',
      category: 'Duvar Kagitlari',
      verseText: 'Allah, kendisinden başka ilah olmayandır. En güzel isimler O\'nundur.',
      surahName: 'Tâhâ Suresi',
      verseNumbers: '8',
      isPremium: false,
    ),
    WallpaperItem(
      asset: 'pexels-abeer-h-194760305-14621114.jpg',
      category: 'Duvar Kagitlari',
      verseText: 'Rabbinizden size indirilene uyun. O\'ndan başka velilere uymayın.',
      surahName: 'A\'râf Suresi',
      verseNumbers: '3',
      isPremium: false,
    ),
    WallpaperItem(
      asset: 'pexels-afhamhmsyri-27441157.jpg',
      category: 'Duvar Kagitlari',
      verseText: 'Allah\'ın ipine hepiniz sımsıkı sarılın, ayrılmayın.',
      surahName: 'Âl-i İmrân Suresi',
      verseNumbers: '103',
      isPremium: false,
    ),
    WallpaperItem(
      asset: 'pexels-afiography-36995143.jpg',
      category: 'Duvar Kagitlari',
      verseText: 'Kim Allah\'a dayanırsa, kuşkusuz doğru yola erişmiştir.',
      surahName: 'Âl-i İmrân Suresi',
      verseNumbers: '101',
      isPremium: false,
    ),
    WallpaperItem(
      asset: 'pexels-akbayfly-2158699886-35638164.jpg',
      category: 'Duvar Kagitlari',
      verseText: 'Rabbiniz, merhamet sahibidir. O\'nun rahmetinden ümit kesmeyin.',
      surahName: 'Zümer Suresi',
      verseNumbers: '53',
      isPremium: true,
    ),
    WallpaperItem(
      asset: 'pexels-alhawraa-489004176-37780505.jpg',
      category: 'Duvar Kagitlari',
      verseText: 'Allah sabredenlerle beraberdir.',
      surahName: 'Bakara Suresi',
      verseNumbers: '153',
      isPremium: true,
    ),
    WallpaperItem(
      asset: 'pexels-anish-264852620-12889586.jpg',
      category: 'Duvar Kagitlari',
      verseText: 'Allah\'ı çok zikredin ki kurtuluşa eresiniz.',
      surahName: 'Cum\'a Suresi',
      verseNumbers: '10',
      isPremium: true,
    ),
    WallpaperItem(
      asset: 'pexels-antoaneta-mehandova-2160547688-36883348.jpg',
      category: 'Duvar Kagitlari',
      verseText: 'Allah\'ın mescitlerini ancak Allah\'a ve ahiret gününe iman edenler imar eder.',
      surahName: 'Tevbe Suresi',
      verseNumbers: '18',
      isPremium: true,
    ),
    WallpaperItem(
      asset: 'pexels-beratorer-33348119.jpg',
      category: 'Duvar Kagitlari',
      verseText: 'Rabbiniz size: "Bana dua edin, size icabet edeyim" buyurdu.',
      surahName: 'Mü\'min Suresi',
      verseNumbers: '60',
      isPremium: true,
    ),
    WallpaperItem(
      asset: 'pexels-bernahanim_-1173268160-30809929.jpg',
      category: 'Duvar Kagitlari',
      verseText: 'Kulunu bir gece Mescid-i Haram\'dan Mescid-i Aksâ\'ya yürüten Allah her türlü noksandan münezzehtir.',
      surahName: 'İsrâ Suresi',
      verseNumbers: '1',
      isPremium: true,
    ),
    WallpaperItem(
      asset: 'pexels-betty-30079555.jpg',
      category: 'Duvar Kagitlari',
      verseText: 'Doğu da Allah\'ındır, batı da. Nereye dönerseniz Allah\'ın yüzü oradadır.',
      surahName: 'Bakara Suresi',
      verseNumbers: '115',
      isPremium: true,
    ),
    WallpaperItem(
      asset: 'pexels-beyza-emisen-1205168918-38135685.jpg',
      category: 'Duvar Kagitlari',
      verseText: 'Gökleri ve yeri yaratan, onların benzerini yaratmaya kadir değil midir?',
      surahName: 'Yâsîn Suresi',
      verseNumbers: '81',
      isPremium: true,
    ),
    WallpaperItem(
      asset: 'pexels-beyza-emisen-1205168918-38281843.jpg',
      category: 'Duvar Kagitlari',
      verseText: 'Yeryüzünde, onları sarsmasın diye sabit dağlar yerleştirdik.',
      surahName: 'Enbiyâ Suresi',
      verseNumbers: '31',
      isPremium: true,
    ),
    WallpaperItem(
      asset: 'pexels-brokenadmiral_-493491871-16013170.jpg',
      category: 'Duvar Kagitlari',
      verseText: 'Gökten su indiren O\'dur. Her bitkiyi onunla bitirdik.',
      surahName: 'En\'âm Suresi',
      verseNumbers: '99',
      isPremium: true,
    ),
    WallpaperItem(
      asset: 'pexels-bugrahan-haksever-337114162-17561872.jpg',
      category: 'Duvar Kagitlari',
      verseText: 'Yeryüzüne bakmazlar mı, onda her güzel çiftten nice bitkiler yetiştirdik.',
      surahName: 'Şu\'arâ Suresi',
      verseNumbers: '7',
      isPremium: true,
    ),
    WallpaperItem(
      asset: 'pexels-catalin-todosia-876894548-29871574.jpg',
      category: 'Duvar Kagitlari',
      verseText: 'Göklerin ve yerin yaratılışında akıl sahipleri için deliller vardır.',
      surahName: 'Âl-i İmrân Suresi',
      verseNumbers: '190',
      isPremium: true,
    ),
    WallpaperItem(
      asset: 'pexels-cigdem-i-seri-163348451-12811841.jpg',
      category: 'Duvar Kagitlari',
      verseText: 'Göğe bakmazlar mı, onu nasıl yükselttik ve süsledik.',
      surahName: 'Kâf Suresi',
      verseNumbers: '6',
      isPremium: true,
    ),
    WallpaperItem(
      asset: 'pexels-ebuuyildiz-17793951.jpg',
      category: 'Duvar Kagitlari',
      verseText: 'Güneş de bir delildir onlara; kendi yörüngesinde akıp gider.',
      surahName: 'Yâsîn Suresi',
      verseNumbers: '38',
      isPremium: true,
    ),
    WallpaperItem(
      asset: 'pexels-ekremkaptanlar-28499163.jpg',
      category: 'Duvar Kagitlari',
      verseText: 'Ay\'a gelince, ona da menziller tayin ettik.',
      surahName: 'Yâsîn Suresi',
      verseNumbers: '39',
      isPremium: true,
    ),
    WallpaperItem(
      asset: 'pexels-ekrulila-4218831.jpg',
      category: 'Duvar Kagitlari',
      verseText: 'Gökleri ve yeri hak ile yarattı. Geceyi gündüze dolar.',
      surahName: 'Zümer Suresi',
      verseNumbers: '5',
      isPremium: true,
    ),
    WallpaperItem(
      asset: 'pexels-emre-bilgic-612391750-31587929.jpg',
      category: 'Duvar Kagitlari',
      verseText: 'Yıldızlar da O\'nun emrine boyun eğmiştir.',
      surahName: 'Nahl Suresi',
      verseNumbers: '12',
      isPremium: true,
    ),
    WallpaperItem(
      asset: 'pexels-erdirbit-20584441.jpg',
      category: 'Duvar Kagitlari',
      verseText: 'İki denizi birbirine kavuşmak üzere salıvermiştir.',
      surahName: 'Rahmân Suresi',
      verseNumbers: '19-20',
      isPremium: true,
    ),
    WallpaperItem(
      asset: 'pexels-faris-purnawarman-537694366-16539350.jpg',
      category: 'Duvar Kagitlari',
      verseText: 'Göklerin ve yerin mülkü O\'nundur. Her iş O\'na döndürülür.',
      surahName: 'Hadîd Suresi',
      verseNumbers: '5',
      isPremium: true,
    ),
    WallpaperItem(
      asset: 'pexels-fotovegraf-312591823-27397439.jpg',
      category: 'Duvar Kagitlari',
      verseText: 'O, korku ve ümit vermek için size şimşeği gösterendir.',
      surahName: 'Ra\'d Suresi',
      verseNumbers: '12',
      isPremium: true,
    ),
    WallpaperItem(
      asset: 'pexels-funda-izgi-236637469-22487909.jpg',
      category: 'Duvar Kagitlari',
      verseText: 'Allah göklerin ve yerin nurudur.',
      surahName: 'Nûr Suresi',
      verseNumbers: '35',
      isPremium: true,
    ),
    WallpaperItem(
      asset: 'pexels-gun-tfk-3901963-12364268.jpg',
      category: 'Duvar Kagitlari',
      verseText: 'Rabbim! Beni tek başıma bırakma. Sen varislerin en hayırlısısın.',
      surahName: 'Enbiyâ Suresi',
      verseNumbers: '89',
      isPremium: true,
    ),
    WallpaperItem(
      asset: 'pexels-hbt-670654920-21563667.jpg',
      category: 'Duvar Kagitlari',
      verseText: 'Ey iman edenler! Allah\'tan korkun ve doğrularla beraber olun.',
      surahName: 'Tevbe Suresi',
      verseNumbers: '119',
      isPremium: true,
    ),
    WallpaperItem(
      asset: 'pexels-hbt-670654920-21855272.jpg',
      category: 'Duvar Kagitlari',
      verseText: 'Allah size emanetleri ehline vermenizi emreder.',
      surahName: 'Nisâ Suresi',
      verseNumbers: '58',
      isPremium: true,
    ),
    WallpaperItem(
      asset: 'pexels-henrik-le-botos-654782730-19316863.jpg',
      category: 'Duvar Kagitlari',
      verseText: 'Allah, kullarına karşı çok şefkatlidir.',
      surahName: 'Şûrâ Suresi',
      verseNumbers: '19',
      isPremium: true,
    ),
    WallpaperItem(
      asset: 'pexels-hussam-eldeen-478486569-34303906.jpg',
      category: 'Duvar Kagitlari',
      verseText: 'De ki: Hiç bilenlerle bilmeyenler bir olur mu?',
      surahName: 'Zümer Suresi',
      verseNumbers: '9',
      isPremium: true,
    ),
    WallpaperItem(
      asset: 'pexels-ishahidsultan-8645749.jpg',
      category: 'Duvar Kagitlari',
      verseText: 'Allah size kolaylık diler, zorluk dilemez.',
      surahName: 'Bakara Suresi',
      verseNumbers: '185',
      isPremium: true,
    ),
    WallpaperItem(
      asset: 'pexels-jess-vide-5008226.jpg',
      category: 'Duvar Kagitlari',
      verseText: 'Allah\'tan bir rahmet dolayısıyla onlara yumuşak davrandın.',
      surahName: 'Âl-i İmrân Suresi',
      verseNumbers: '159',
      isPremium: true,
    ),
    WallpaperItem(
      asset: 'pexels-josh-hild-1270765-2607492.jpg',
      category: 'Duvar Kagitlari',
      verseText: 'Rabbimiz! Bize dünyada da iyilik ver, ahirette de iyilik ver.',
      surahName: 'Bakara Suresi',
      verseNumbers: '201',
      isPremium: true,
    ),
    WallpaperItem(
      asset: 'pexels-m-emre_celik-2054744248-29369522.jpg',
      category: 'Duvar Kagitlari',
      verseText: 'Allah adaletli davrananları sever.',
      surahName: 'Mümtehine Suresi',
      verseNumbers: '8',
      isPremium: true,
    ),
    WallpaperItem(
      asset: 'pexels-mahmut-tozal-368300344-35743716.jpg',
      category: 'Duvar Kagitlari',
      verseText: 'Rabbimiz! Unutur ya da yanılırsak bizi sorgulama.',
      surahName: 'Bakara Suresi',
      verseNumbers: '286',
      isPremium: true,
    ),
    WallpaperItem(
      asset: 'pexels-martin-marthadinata-252863-37446213.jpg',
      category: 'Duvar Kagitlari',
      verseText: 'Allah\'a tevekkül et. Vekil olarak Allah yeter.',
      surahName: 'Ahzâb Suresi',
      verseNumbers: '3',
      isPremium: true,
    ),
    WallpaperItem(
      asset: 'pexels-mohammed-abubakr-201794886-13058153.jpg',
      category: 'Duvar Kagitlari',
      verseText: 'Sabır ve namazla Allah\'tan yardım dileyin.',
      surahName: 'Bakara Suresi',
      verseNumbers: '45',
      isPremium: true,
    ),
    WallpaperItem(
      asset: 'pexels-ozlem-k-771715772-33514658.jpg',
      category: 'Duvar Kagitlari',
      verseText: 'De ki: Rabbim ilmimi artır.',
      surahName: 'Tâhâ Suresi',
      verseNumbers: '114',
      isPremium: true,
    ),
    WallpaperItem(
      asset: 'pexels-pakkontrack-9744509.jpg',
      category: 'Duvar Kagitlari',
      verseText: 'Allah\'ın rahmetinden ümit kesmeyin.',
      surahName: 'Zümer Suresi',
      verseNumbers: '53',
      isPremium: true,
    ),
    WallpaperItem(
      asset: 'pexels-peshin-photograhpar-80194280-37496403.jpg',
      category: 'Duvar Kagitlari',
      verseText: 'Allah\'a dayan, O sana yeter.',
      surahName: 'Enfâl Suresi',
      verseNumbers: '64',
      isPremium: true,
    ),
    WallpaperItem(
      asset: 'pexels-phsantiagoluna-13344258.jpg',
      category: 'Duvar Kagitlari',
      verseText: 'Kim bir iyilik yaparsa, ona on katı verilir.',
      surahName: 'En\'âm Suresi',
      verseNumbers: '160',
      isPremium: true,
    ),
    WallpaperItem(
      asset: 'pexels-ramiardilshad-26436652.jpg',
      category: 'Duvar Kagitlari',
      verseText: 'Rabbim! Göğsüme genişlik ver, işimi kolaylaştır.',
      surahName: 'Tâhâ Suresi',
      verseNumbers: '25-26',
      isPremium: true,
    ),
    WallpaperItem(
      asset: 'pexels-ramiardilshad-26436664.jpg',
      category: 'Duvar Kagitlari',
      verseText: 'Muhakkak ki Allah\'ın yardımı yakındır.',
      surahName: 'Bakara Suresi',
      verseNumbers: '214',
      isPremium: true,
    ),
    WallpaperItem(
      asset: 'pexels-rinalds-vanags-486629516-15924697.jpg',
      category: 'Duvar Kagitlari',
      verseText: 'Allah, insana şah damarından daha yakındır.',
      surahName: 'Kâf Suresi',
      verseNumbers: '16',
      isPremium: true,
    ),
    WallpaperItem(
      asset: 'pexels-rushdi-fatani-782816372-38546894.jpg',
      category: 'Duvar Kagitlari',
      verseText: 'Allah\'ın boyasıyla boyandık. Kimin boyası Allah\'ınkinden daha güzeldir?',
      surahName: 'Bakara Suresi',
      verseNumbers: '138',
      isPremium: true,
    ),
    WallpaperItem(
      asset: 'pexels-saad-alkot-419901137-16498673.jpg',
      category: 'Duvar Kagitlari',
      verseText: 'Rabbimiz! Bize katından bir rahmet ver.',
      surahName: 'Kehf Suresi',
      verseNumbers: '10',
      isPremium: true,
    ),
    WallpaperItem(
      asset: 'pexels-sadi-yucel-363896568-20628981.jpg',
      category: 'Duvar Kagitlari',
      verseText: 'Allah\'a ve Resulüne itaat edin.',
      surahName: 'Âl-i İmrân Suresi',
      verseNumbers: '132',
      isPremium: true,
    ),
    WallpaperItem(
      asset: 'pexels-sameerclicks-30216394.jpg',
      category: 'Duvar Kagitlari',
      verseText: 'Allah\'tan bağışlanma dile.',
      surahName: 'Nisâ Suresi',
      verseNumbers: '106',
      isPremium: true,
    ),
    WallpaperItem(
      asset: 'pexels-shanu-azhikode-531962-11118835.jpg',
      category: 'Duvar Kagitlari',
      verseText: 'Yalnız sana ibadet eder ve yalnız senden yardım dileriz.',
      surahName: 'Fâtiha Suresi',
      verseNumbers: '5',
      isPremium: true,
    ),
    WallpaperItem(
      asset: 'pexels-sultan-175963006-18274448.jpg',
      category: 'Duvar Kagitlari',
      verseText: 'Bizi doğru yola ilet.',
      surahName: 'Fâtiha Suresi',
      verseNumbers: '6',
      isPremium: true,
    ),
    WallpaperItem(
      asset: 'pexels-tahayasiryoney-19838134.jpg',
      category: 'Duvar Kagitlari',
      verseText: 'Allah her şeyin yaratıcısıdır. O her şeye vekildir.',
      surahName: 'Zümer Suresi',
      verseNumbers: '62',
      isPremium: true,
    ),
    WallpaperItem(
      asset: 'pexels-vishpix-18028130.jpg',
      category: 'Duvar Kagitlari',
      verseText: 'Nerede olursanız olun, Allah sizinle beraberdir.',
      surahName: 'Hadîd Suresi',
      verseNumbers: '4',
      isPremium: true,
    ),
    WallpaperItem(
      asset: 'pexels-yusuf-kaya-288172498-17379530.jpg',
      category: 'Duvar Kagitlari',
      verseText: 'O, yaratan ve size şekil verendir.',
      surahName: 'Haşr Suresi',
      verseNumbers: '24',
      isPremium: true,
    ),
    WallpaperItem(
      asset: 'pexels-yusuf-kaya-288172498-19001090.jpg',
      category: 'Duvar Kagitlari',
      verseText: 'Allah, hikmeti dilediğine verir.',
      surahName: 'Bakara Suresi',
      verseNumbers: '269',
      isPremium: true,
    ),
    WallpaperItem(
      asset: 'pexels-zkadoshi-36085972.jpg',
      category: 'Duvar Kagitlari',
      verseText: 'O, ölüleri diriltir ve O her şeye kadirdir.',
      surahName: 'Hac Suresi',
      verseNumbers: '6',
      isPremium: true,
    ),
  ];

  /// Sadece ucretsiz duvar kagitlari (ilk 5)
  static List<WallpaperItem> get free => all.where((w) => !w.isPremium).toList();

  /// Sadece premium duvar kagitlari
  static List<WallpaperItem> get premium => all.where((w) => w.isPremium).toList();

  /// Kategoriye gore gruplanmis liste
  static Map<String, List<WallpaperItem>> get byCategory {
    final map = <String, List<WallpaperItem>>{};
    for (final w in all) {
      map.putIfAbsent(w.category, () => []).add(w);
    }
    return map;
  }

  /// Tum kategoriler (sirali)
  static List<String> get categories {
    final seen = <String>{};
    final result = <String>[];
    for (final w in all) {
      if (seen.add(w.category)) result.add(w.category);
    }
    return result;
  }

  /// Sunucudan duvar kagidi listesini yukler.
  /// Basarili olursa [_remoteList] guncellenir ve true doner.
  /// Basarisiz olursa built-in liste kullanilmaya devam edilir.
  static Future<bool> loadFromApi() async {
    if (_loaded) return _remoteList != null;

    try {
      final apiItems = await ApiService().getWallpapers();
      if (apiItems.isEmpty) return false;

      _remoteList = apiItems.map((json) {
        final api = ApiWallpaper.fromJson(json);
        return WallpaperItem(
          asset: api.asset,
          category: api.category,
          verseText: api.verseText,
          surahName: api.surahName,
          verseNumbers: api.verseNumbers,
          isPremium: api.isPremium,
          imageUrl: api.imageUrl.isNotEmpty ? api.imageUrl : null,
        );
      }).toList();

      _loaded = true;
      debugPrint('WallpaperRegistry: API\'den ${_remoteList!.length} duvar kagidi yuklendi');
      return true;
    } catch (e) {
      debugPrint('WallpaperRegistry: API yukleme basarisiz, built-in kullaniliyor. Hata: $e');
      // _loaded false kalir, boylece sonraki cagrilarda tekrar dener
      return false;
    }
  }

  /// Listeyi sifirlar (veri yenileme icin)
  static void reset() {
    _remoteList = null;
    _loaded = false;
  }
}
