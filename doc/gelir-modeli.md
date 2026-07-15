# Tefsir AI — Gelir Modeli & Strateji Planı

> Son güncelleme: Temmuz 2026

---

## 1. Gelir Kaynakları

### A. Premium Abonelik

| Plan | Fiyat | İçerik |
|---|---|---|
| Aylık | ₺49,99 | 100 AI sorusu/ay, reklamsız, premium duvar kağıtları |
| Yıllık | ₺299,99 (₺24,99/ay) | Aylık ile aynı, %40 indirim |

**Net gelir (Apple/Google %30 komisyon sonrası):**
- Aylık: ₺35
- Yıllık: ₺210 (₺17,50/ay)

### B. Token (Soru) Paketleri

Premium kullanıcılar bile ek soru alabilir. Premium olmayanlar da alabilir.

| Paket | Fiyat | Net (komisyon sonrası) |
|---|---|---|
| 50 Soru | ₺19,99 | ₺14 |
| 200 Soru (Popüler) | ₺49,99 | ₺35 |
| 500 Soru | ₺99,99 | ₺70 |

### C. Reklam Geliri (Ücretsiz Kullanıcılar)

**Reklam türleri:**

| Tür | Gösterim/kullanıcı/gün | eCPM (Türkiye) | Aylık/kullanıcı |
|---|---|---|---|
| Banner (ana sayfa) | 10-15 | $1-3 | ₺0,30-0,90 |
| Rewarded (3 reklam = 1 soru) | 0-9 | $3-6 | ₺0-1,00 |
| Interstitial (ekran geçişleri) | 3-5 | $2-4 | ₺0,20-0,50 |
| **Toplam** | | | **₺0,50-2,40/ay** |

**İçerik filtreleme:**
- `maxAdContentRating: G` (sadece genel izleyici)
- `tagForChildDirectedTreatment: yes`
- Cinsel, alkol, kumar, siyasi reklamlar ENGELLİ
- AdMob dashboard → manuel kategori engelleme

### D. Reklam İzleme = AI Sorusu (Hibrit Model)

Ücretsiz kullanıcı AI'ya soru soramaz. Ama 3 rewarded reklam izleyerek 1 soru hakkı kazanabilir.

| | 3 Reklam Geliri | 1 AI Sorusu Maliyeti | Kâr |
|---|---|---|---|
| Ortalama | ₺0,30 | ₺0,01 | **₺0,29** |
| Yıllık (1.000 kullanıcı, günde 1 kez) | ₺109.500 | ₺3.650 | **₺105.850** |

---

## 2. Giderler (Aylık)

### Sabit Giderler

| Kalem | Aylık Maliyet | Açıklama |
|---|---|---|
| Apple Developer | $99/yıl (₺290/ay) | Zorunlu |
| Google Play | $25 (tek seferlik) | Zorunlu |
| Domain | ₺10 | cdn.islamiapp.com |
| **Sabit toplam** | **~₺300/ay** | |

### Değişken Giderler (kullanıcı sayısına bağlı)

| Kalem | 1.000 kullanıcı | 10.000 kullanıcı | 100.000 kullanıcı |
|---|---|---|---|
| **AI (Gemini 2.5 Flash)** | ₺25 | ₺250 | ₺2.500 |
| Her premium kullanıcı 100 soru × $0,00033 × %40 kullanım | | | |
| Her reklam izleyen 30 soru (10 set) × $0,00033 | | | |
| **Namaz Vakitleri API (Aladhan)** | ₺0 | ₺0 | ₺0 |
| **CDN (Kuran sayfaları)** | ₺0 | ₺0 | ₺0 |
| **Sunucu (opsiyonel)** | ₺0 | ₺0 | ₺340 |
| **Değişken toplam** | **₺25** | **₺250** | **₺2.840** |

### Toplam Gider

| Kullanıcı | Sabit | Değişken | Toplam |
|---|---|---|---|
| 1.000 | ₺300 | ₺25 | **₺325** |
| 10.000 | ₺300 | ₺250 | **₺550** |
| 100.000 | ₺300 | ₺2.840 | **₺3.140** |

> Not: AI maliyeti sürekli düşüyor. Gemini 2.5 Flash 2025'te çıktı, fiyatı her 6 ayda bir ~%30-50 düşüyor. 2027'de bugünkünün %25'i olacak.

---

## 3. Gelir Projeksiyonu

### Senaryo: %5 Premium dönüşüm, %20 reklam izleyici

| | 1.000 kullanıcı | 10.000 | 100.000 |
|---|---|---|---|
| **Premium** | | | |
| Premium kullanıcı | 50 | 500 | 5.000 |
| %70 aylık × ₺35 | ₺1.225 | ₺12.250 | ₺122.500 |
| %30 yıllık × ₺17,50 | ₺262 | ₺2.625 | ₺26.250 |
| **Reklam (ücretsiz)** | | | |
| Banner (950 kişi) | ₺570 | ₺5.700 | ₺57.000 |
| Rewarded (200 kişi × 10 set) | ₺60 | ₺600 | ₺6.000 |
| Interstitial | ₺285 | ₺2.850 | ₺28.500 |
| **Token paketleri** (%5 satın alır) | ₺53 | ₺530 | ₺5.300 |
| **Brüt gelir** | **₺2.455** | **₺24.555** | **₺245.550** |
| **Gider** | −₺325 | −₺550 | −₺3.140 |
| **Net Kâr** | **₺2.130** | **₺24.005** | **₺242.410** |

### Büyüme Hedefleri

| Ay | Kullanıcı | Aylık Kâr | 
|---|---|---|
| 1-3 | 1.000 | ₺2.100 |
| 4-6 | 5.000 | ₺10.500 |
| 7-12 | 20.000 | ₺42.000 |
| 2. yıl | 100.000 | ₺242.000 |
| 3. yıl | 500.000 | ₺1.200.000 |

---

## 4. Strateji

### A. Kullanıcı Kazanma (Acquisition)

1. **Organik (ASO)** 
   - Başlık: "Tefsir AI: Kuran, Namaz, Kıble"
   - Anahtar kelimeler: namaz vakti, kuran, kıble, tefsir, esmaül hüsna, dualar
   - Rakip kelimeler: Muslim Pro, Azan, Pillars

2. **Sosyal Medya**
   - Instagram/TikTok reels: "Kuran'da geçen bir ayetin AI ile tefsiri"
   - Twitter: Günlük ayet + tefsir paylaşımları

3. **Community**
   - Reddit r/islam, r/muslimlounge
   - WhatsApp grupları

### B. Kullanıcı Tutma (Retention)

| Özellik | Açılma sıklığı | Tutma gücü |
|---|---|---|
| Namaz vakitleri | 5×/gün | Çok yüksek |
| İbadet takibi | 1-2×/gün | Yüksek |
| Kuran | 1×/gün | Orta |
| AI Tefsir | 2-3×/hafta | Orta |
| Kıble pusulası | Seyrek | Düşük |
| Rozetler & streak | 1×/gün | Yüksek (gamification) |

**Kritik:** Namaz vakitleri ücretsiz → kullanıcı her gün uygulamayı açar → reklam görür → premium'a dönüşür.

### C. Dönüşüm (Conversion)

**Bedava → Premium hunisi:**
1. Kullanıcı namaz vakitleri için uygulamayı indirir (ücretsiz)
2. Reklamları görür, AI tefsiri dener (0 soru → panel çıkar)
3. 3 reklam izleyip 1 soru sorar → AI kalitesini görür
4. Daha fazla sormak ister → "Hemen Premium'a Geç" butonu
5. %5'i premium olur

**Reklam → AI sorusu hunisi:**
1. AI soramaz → panel çıkar
2. "3 Reklam İzle" → kolay, risksiz
3. Cevabı beğenir → daha fazla ister
4. Ya premium alır ya da token paketi

### D. Ücretlendirme Psikolojisi

- **Yıllık plan öne çıkarılmış** (%40 indirim, "Popüler" etiketi)
- Token paketlerinde "200 Soru" popüler işaretli (decoy effect)
- Aylık ₺49,99 pahalı gösterilip yıllığa yönlendirme
- Ücretsiz AI = SIFIR → premium'un değeri net

---

## 5. Rakipler & Farklılaşma

| Özellik | Muslim Pro | Pillars | **Tefsir AI** |
|---|---|---|---|
| Namaz vakitleri | ✅ | ✅ | ✅ (81 il + dünya) |
| Kuran | ✅ | ✅ | ✅ (tam mushaf) |
| Kıble | ✅ | ✅ | ✅ (CustomPainter) |
| AI Tefsir | ❌ | ❌ | ✅ **Tek** |
| Reklamlı soru | ❌ | ❌ | ✅ **Tek** |
| İbadet takibi | ❌ | ❌ | ✅ Gamification |
| Kaza takibi | ❌ | ❌ | ✅ **Tek** |
| Türkçe öncelikli | ❌ | ❌ | ✅ |
| Fiyat (aylık) | $4.99 (₺170) | $2.99 (₺100) | **₺49,99** |

**Farklılaşma:** AI tefsir + reklamlı soru modeli + kaza takibi pazarda TEK.

---

## 6. Riskler & Çözümler

| Risk | Olasılık | Çözüm |
|---|---|---|
| AI maliyeti artar | Düşük | Fiyatlar düşüyor, token limiti ayarlanabilir |
| Google AdMob politikası | Orta | İçerik G seviyesinde, dini uygulama avantajlı |
| Apple review reddi | Düşük | Tamamen guideline uyumlu |
| Rakip AI özelliği ekler | Yüksek | İlk olma avantajı + sürekli geliştirme |
| Kullanıcı artmazsa | Orta | Pazarlama bütçesi ayrılacak |

---

## 7. Aksiyon Planı

### Faz 1: Beta (1-2 ay)
- [x] Temel özellikler (namaz, kuran, kıble, dualar, hadis)
- [x] AI Tefsir (Gemini entegrasyonu)
- [x] İbadet takibi + rozetler
- [x] Kaza takibi
- [x] Premium sayfası
- [x] Reklam altyapısı (placeholder)
- [ ] AdMob canlı entegrasyonu (SPM çakışması çözülünce)
- [ ] In-App Purchase (RevenueCat veya direk StoreKit)
- [ ] 50 beta kullanıcısı ile test

### Faz 2: Lansman (3-4 ay)
- [ ] App Store + Google Play yayın
- [ ] ASO optimizasyonu
- [ ] Sosyal medya hesapları
- [ ] İlk 1.000 kullanıcı hedefi

### Faz 3: Büyüme (5-12 ay)
- [ ] Push notification (namaz vakti hatırlatmaları)
- [ ] Topluluk özelliği (haftalık challenge'lar)
- [ ] Daha fazla dil (İngilizce, Arapça)
- [ ] 20.000 kullanıcı hedefi
