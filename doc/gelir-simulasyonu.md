# Gelir Simülasyonu — 100K Aktif Kullanıcı

> Varsayımlar: Günde 5 oturum, %1 premium, %10 AI reklam izleyici, TR eCPM ortalaması

---

## Kullanıcı Dağılımı (100K)

| Segment | Kişi | Oran |
|---|---|---|
| Premium (aylık %70) | 700 | %0,7 |
| Premium (yıllık %30) | 300 | %0,3 |
| Ücretsiz — sadece namaz/Kuran | 89.000 | %89 |
| Ücretsiz — AI reklam izleyen | 10.000 | %10 |

---

## 1. Banner (Ana Sayfa — Herkes Görür)

| Premium dahil herkes | 100.000 kişi × 5 oturum = 500K gösterim/gün |
|---|---|
| Günlük | 500K × $0,80 eCPM / 1000 = **$400** |
| Aylık | **$12.000 = ₺408.000** |

> Banner premium'da da var. Hafif, rahatsız etmez.

---

## 2. Interstitial — Namaz Vakti (günde 1 kez, ücretsizler)

| 99.000 ücretsiz kullanıcı × günde 1 |
|---|
| Günlük | 99K × $3 eCPM / 1000 = **$297** |
| Aylık | **$8.910 = ₺303.000** |

---

## 3. Interstitial — AI Tefsir (10 dk'da 1, ücretsiz AI kullananlar)

| 10.000 kişi × günde 1,5 gösterim |
|---|
| Günlük | 15K × $3 eCPM / 1000 = **$45** |
| Aylık | **$1.350 = ₺46.000** |

---

## 4. Rewarded (3 reklam = 1 AI sorusu)

| 10.000 kişi × günde 1 set (3 reklam) |
|---|
| Günlük | 30K × $5 eCPM / 1000 = **$150** |
| Aylık | **$4.500 = ₺153.000** |

---

## 5. Premium Abonelik

| Plan | Kişi | Net (komisyon sonrası) | Aylık |
|---|---|---|---|
| Aylık ₺49,99 | 700 | ₺35 | ₺24.500 |
| Yıllık ₺299,99 | 300 | ₺210/yıl → ₺17,50/ay | ₺5.250 |
| **Toplam** | **1.000** | | **₺29.750** |

---

## Aylık Toplam

| Kaynak | $/ay | ₺/ay | Pay |
|---|---|---|---|
| Banner (herkes) | $12.000 | ₺408.000 | %43 |
| Namaz interstitial (ücretsiz) | $8.910 | ₺303.000 | %32 |
| Rewarded (AI soru) | $4.500 | ₺153.000 | %16 |
| AI interstitial | $1.350 | ₺46.000 | %5 |
| Premium abonelik | $875 | ₺29.750 | %3 |
| Token paketleri (tahmini) | $150 | ₺5.000 | %1 |
| **Toplam** | **$27.785** | **₺944.750** | |

---

## Kişi Başı Aylık Gelir

| Segment | Gelir |
|---|---|
| 1 ücretsiz (pasif) | ₺7,50 |
| 1 ücretsiz (AI kullanan) | ₺30 |
| 1 premium (aylık) | ₺42,50 |
| 1 premium (yıllık) | ₺25 |

---

## Senaryo Karşılaştırması

| | %1 Premium | %3 Premium | %5 Premium | %10 Premium |
|---|---|---|---|---|
| Premium kişi | 1.000 | 3.000 | 5.000 | 10.000 |
| Premium geliri | ₺29.750 | ₺89.250 | ₺148.750 | ₺297.500 |
| Reklam geliri | ₺915.000 | ₺890.000 | ₺860.000 | ₺790.000 |
| **Toplam** | **₺944.750** | **₺979.250** | **₺1.008.750** | **₺1.087.500** |

> Premium arttıkça reklam geliri düşer ama toplam artar. %5 optimum.

---

## Maliyetler (Aylık)

| Kalem | Aylık |
|---|---|
| Gemini AI (premium + reklam izleyen) | ₺2.500 |
| Apple Developer ($99/yıl) | ₺290 |
| Firebase (Blaze) | ₺0 (ücretsiz tier) |
| RevenueCat | ₺0 (ilk $10K MRR ücretsiz) |
| **Toplam** | **₺2.790** |

---

## Net Kâr

| | Aylık | Yıllık |
|---|---|---|
| Brüt gelir | ₺944.750 | ₺11.337.000 |
| Maliyet | −₺2.790 | −₺33.480 |
| **Net kâr** | **₺941.960** | **₺11.303.520** |

**≈ $27.700/ay ≈ $332.000/yıl**

---

## 500K Kullanıcıya Ölçekleme

| | Aylık |
|---|---|
| Reklam | ₺4.575.000 |
| Premium (%1 = 5.000 kişi) | ₺148.750 |
| Maliyet | −₺12.000 |
| **Net** | **₺4.711.750/ay ≈ $138.500/ay** |

---

> **Notlar:**
> - eCPM Türkiye ortalamasıdır. ABD/Avrupa'da 3-5 kat daha yüksek.
> - AI maliyeti sürekli düşüyor (Gemini fiyatları her 6 ayda bir ~%40 azalıyor)
> - Premium dönüşümü %1'den %5'e çıkarsa aylık net ₺1M'i geçer
> - En büyük gelir kalemi: Banner (%43) — herkes görüyor, premium dahil
> - En kârlı reklam: Rewarded — kullanıcı kendi isteğiyle izliyor
