/// Tek bir Kur'an ayetini temsil eder.
class Ayah {
  final int number; // Sure içindeki ayet numarası (1'den başlar)
  final String text; // Arapça metin (Uthmani)
  final String translation; // Türkçe meal
  final String transliteration; // Latin harfleriyle okunuş

  const Ayah({
    required this.number,
    required this.text,
    required this.translation,
    required this.transliteration,
  });

  factory Ayah.fromJson(Map<String, dynamic> json) => Ayah(
        number: json['id'] as int,
        text: json['text'] as String? ?? '',
        translation: json['translation'] as String? ?? '',
        transliteration: json['transliteration'] as String? ?? '',
      );
}

/// Tek bir sureyi (114 sureden biri) temsil eder.
class Surah {
  final int number; // 1-114 arası sure numarası
  final String name; // Arapça yazılışı
  final String transliteration; // Latin harfleriyle adı (örn. "Al-Fatihah")
  final String turkishName; // Türkçe adı (örn. "Fâtiha")
  final String type; // "meccan" ya da "medinan"
  final int totalVerses;
  final List<Ayah> verses;

  const Surah({
    required this.number,
    required this.name,
    required this.transliteration,
    required this.turkishName,
    required this.type,
    required this.totalVerses,
    required this.verses,
  });

  bool get isMeccan => type == 'meccan';

  factory Surah.fromJson(Map<String, dynamic> json) => Surah(
        number: json['id'] as int,
        name: json['name'] as String? ?? '',
        transliteration: json['transliteration'] as String? ?? '',
        turkishName: json['translation'] as String? ?? '',
        type: json['type'] as String? ?? 'meccan',
        totalVerses: json['total_verses'] as int? ?? 0,
        verses: (json['verses'] as List<dynamic>? ?? [])
            .map((v) => Ayah.fromJson(v as Map<String, dynamic>))
            .toList(),
      );
}
