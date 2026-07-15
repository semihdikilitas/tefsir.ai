# Kur'an-ı Kerim Entegrasyonu — Kurulum Talimatları

## 1. Dosyaları projene kopyala

Bu zip'in içindeki klasör yapısını, kendi Flutter projenin köküne şu şekilde eşleştir (dosyaları doğrudan üzerine kopyala):

```
senin_projen/
  assets/
    quran/
      quran_tr_full.json        <-- YENİ (Arapça metin + Türkçe meal + okunuş, 114 sure)
  lib/
    data/
      models/
        quran_models.dart       <-- YENİ
      services/
        quran_service.dart      <-- YENİ
    screens/
      home_screen.dart          <-- GÜNCELLENDİ (Kur'an-ı Kerim kartı artık çalışıyor)
      quran_screen.dart         <-- YENİ (sure listesi + arama)
      surah_detail_screen.dart  <-- YENİ (ayet detayları)
    widgets/
      app_drawer.dart           <-- GÜNCELLENDİ (menüye "Kur'an-ı Kerim" eklendi)
```

> Not: `home_screen.dart` ve `app_drawer.dart` senin orijinal dosyalarının üzerine yazılacak
> şekilde güncellendi (sadece Kur'an ile ilgili kısımlar eklendi, geri kalan her şey aynı).
> Diğer dosyalarında (prayer_times, worship_tracker vb.) hiçbir değişiklik yapılmadı.

## 2. pubspec.yaml'a asset'i tanıt

`pubspec.yaml` dosyanda `flutter:` bölümüne şunu ekle (zaten bir `assets:` listen varsa,
sadece yeni satırı ekle):

```yaml
flutter:
  assets:
    - assets/quran/quran_tr_full.json
```

Sonra terminalde:

```bash
flutter pub get
```

## 3. (Opsiyonel ama önerilir) Arapça font

Şu an Arapça metin cihazın varsayılan sistem fontuyla gösteriliyor. Bu çalışır ama
tecvid/diyakritik işaretler bazı cihazlarda tam düzgün render olmayabilir. Daha güzel
görünmesi için `google_fonts` paketini eklemeni öneririm:

```bash
flutter pub add google_fonts
```

Sonra `surah_detail_screen.dart` içindeki ayet metninin `TextStyle`'ına şunu ekle:

```dart
import 'package:google_fonts/google_fonts.dart';

// ayah.text gösteren Text widget'ında:
style: GoogleFonts.amiri(
  color: AppColors.textLight,
  fontSize: 22,
  height: 1.9,
  fontWeight: FontWeight.w500,
),
```

("Amiri" yerine "ScheherazadeNew" veya "NotoNaskhArabic" da denenebilir.)

## 4. Test et

```bash
flutter run
```

Ana ekrandaki **"Kuran-ı Kerim"** kartına veya sağ menüdeki **"Kur'an-ı Kerim"**
satırına dokunarak sure listesine, oradan da bir sureye dokunarak ayet detaylarına
ulaşabilirsin. Sağ üstteki altyazı ikonuyla Latin harfli okunuşu açıp kapatabilirsin.

## 5. Lisans / Atıf — ÖNEMLİ

Kur'an metni ve çeviriler **CC-BY-SA 4.0** lisanslı `quran-json` projesinden alındı.
Bu lisans atıf zorunluluğu getiriyor. Uygulamanın "Hakkında" veya "Ayarlar" ekranına
(şu an placeholder olan `Hakkında / Geri Bildirim` satırına) şu metni eklemen gerekiyor:

> Kur'an-ı Kerim metni ve mealler [quran-json](https://github.com/risan/quran-json)
> projesinden CC-BY-SA 4.0 lisansı altında alınmıştır. Arapça metin: The Noble Qur'an
> Encyclopedia. Türkçe meal: Diyanet İşleri Başkanlığı (tanzil.net).

Bu bir hukuki tavsiye değildir — ben avukat değilim; ama pratikte bu tarz bir atıf
satırı CC-BY-SA gerekliliklerini karşılamak için standart bir yöntemdir.

## Veri hakkında notlar

- `quran_tr_full.json`, orijinal `quran-json` paketindeki `quran_tr.json` (Arapça +
  Türkçe meal) ile `quran_transliteration.json` (Latin okunuş) dosyalarının birleştirilip
  sadeleştirilmiş halidir — tek dosyadan tüm veriye erişebilmen için hazırlandı.
- Dosya boyutu ~3.2 MB. Uygulama ilk açıldığında `QuranService` bunu bir kere okuyup
  RAM'de önbelleğe alıyor, sonraki her erişim anında oluyor.
- İstersen ileride favori ayet / son okunan yer gibi özellikler için `sqflite`
  kullanan bir yapıya geçirebiliriz (projede zaten `database_helper.dart` var, aynı
  desene uyacak şekilde genişletilebilir) — şimdilik basit ve hızlı çalışan asset+RAM
  yaklaşımını tercih ettim çünkü 114 sure için performans sorunu yaratmıyor.
