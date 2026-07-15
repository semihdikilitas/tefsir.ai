# Tefsir AI — Backend & Frontend Planı

> Son güncelleme: Temmuz 2026

---

## Backend Mimarisi

### Önerilen Tech Stack

| Katman | Teknoloji | Neden |
|---|---|---|
| Sunucu | **Firebase** (BaaS) | Ücretsiz başlangıç, sıfır sunucu yönetimi, Flutter ile native entegrasyon |
| Auth | Firebase Auth | Google/Apple/Email sign-in, 1 günde entegre |
| Veritabanı | Cloud Firestore | Realtime sync, offline destek, ücretsiz tier 50K okuma/gün |
| AI Proxy | Firebase Functions | Gemini API key'i sunucuda gizli, rate limiting, token sayacı |
| Depolama | Firebase Storage | Kuran sayfaları, şehir görselleri, kullanıcı upload'ları |
| Abonelik | **RevenueCat** | App Store / Google Play IAP yönetimi, webhook, cross-platform |
| Push Notification | Firebase Cloud Messaging | Namaz vakti hatırlatmaları |
| Analitik | Firebase Analytics + Crashlytics | Ücretsiz, güçlü |

**Alternatif:** Supabase (açık kaynak, PostgreSQL, daha ucuz) — ama Firebase'in Flutter desteği daha olgun.

### Neden Backend Şimdi Gerekli?

| Sorun | Şu anki durum | Backend ile |
|---|---|---|
| Gemini API key | Kodda açıkta `YOUR_GEMINI_API_KEY` ❌ | Sunucuda gizli, proxy üzerinden ✅ |
| Token sayacı | Client-side, manipüle edilebilir | Server-side, güvenli ✅ |
| Premium doğrulama | `_isPremium = false` hardcoded | RevenueCat + Firestore ile gerçek doğrulama ✅ |
| Veri kaybı | SQLite/SharedPrefs — telefon silinirse gider | Cloud sync ✅ |
| Çoklu cihaz | Yok | Firestore sync ile ✅ |
| Analitik | Yok | Firebase Analytics ile ✅ |

---

## Backend Görevleri

### B1. Firebase Projesi Kurulumu

- [ ] Firebase Console'da proje oluştur
- [ ] Android + iOS app ekle (google-services.json / GoogleService-Info.plist)
- [ ] Firebase Auth (Email + Google + Apple Sign-In)
- [ ] Cloud Firestore (üretim modunda güvenlik kuralları)
- [ ] Firebase Functions (Blaze plan — ücretli ama cüzi)
- [ ] Firebase Cloud Messaging (push notification)

### B2. Cloud Firestore Veri Modeli

```
users/{userId}/
  ├── profile
  │   ├── email: string
  │   ├── name: string
  │   ├── createdAt: timestamp
  │   ├── isPremium: bool
  │   └── subscriptionExpiry: timestamp
  │
  ├── worship/{date}/
  │   ├── imsak, ogle, ikindi, aksam, yatsi: bool
  │   ├── quranPages: int
  │   ├── dhikrCount: int
  │   └── isFasting: bool
  │
  ├── bookmarks/{id}/
  │   ├── question: string
  │   ├── answer: string
  │   ├── surahRefs: string
  │   └── createdAt: timestamp
  │
  └── ai_usage/{yearMonth}/
      ├── questionsUsed: int
      └── questionsLimit: int (100 premium, 0 free)
```

### B3. Firebase Functions (AI Proxy)

```typescript
// functions/src/tafsir.ts
exports.askTafsir = functions.https.onCall(async (data, context) => {
  const userId = context.auth?.uid;
  
  // 1. Auth kontrolü
  if (!userId) throw new HttpsError('unauthenticated');
  
  // 2. Token kontrolü (Firestore'dan kullanıcının kalan hakkı)
  const usage = await getUserQuota(userId);
  if (usage.remaining <= 0) throw new HttpsError('resource-exhausted');
  
  // 3. Gemini API'ye istek (API key sunucuda gizli)
  const answer = await geminiAI.ask(data.question);
  
  // 4. Token sayacını güncelle
  await decrementQuota(userId);
  
  // 5. Log
  await logUsage(userId, data.question, answer);
  
  return { answer, remaining: usage.remaining - 1 };
});
```

**Neden bu kritik:** Gemini API key'i uygulama kodunda OLAMAZ. Birisi APK'yı decompile edip key'i çalarsa senin faturan kabarır. Proxy ile key sunucuda kalır, rate limiting yapabilirsin.

### B4. RevenueCat Entegrasyonu

- [ ] RevenueCat hesabı → App Store Connect / Google Play Console bağla
- [ ] Ürünleri tanımla:
  - `premium_monthly` (₺49,99)
  - `premium_yearly` (₺299,99)
  - `token_50` (₺19,99)
  - `token_200` (₺49,99)
  - `token_500` (₺99,99)
- [ ] RevenueCat SDK'yı Flutter'a ekle
- [ ] Satın alma flow'unu bağla (şu an simülasyon)
- [ ] Webhook ile premium durumunu Firestore'a yaz

### B5. Push Notification Sistemi

- [ ] Namaz vakti hatırlatması (imsak, öğle, ikindi, akşam, yatsı)
- [ ] Kullanıcı lokasyonuna göre otomatik saat ayarı
- [ ] Cuma namazı özel hatırlatması
- [ ] "3 gündür streak'in devam ediyor" motivasyon bildirimi

---

## Frontend Kalan İşler

### F1. Auth Ekranı (YENİ)

- [ ] Login / Register ekranı
- [ ] Google Sign-In butonu
- [ ] Email / Password formu
- [ ] Şifre sıfırlama
- [ ] Guest mode (auth'suz kullanım — sınırlı)
- [ ] Profil sayfası

### F2. API Katmanı Refactor

- [ ] `TafsirChatScreen` → Gemini'ye direkt değil, Firebase Functions üzerinden
- [ ] `WorshipTrackerScreen` → Firestore sync ekle
- [ ] `HistoryService` → SharedPrefs'ten Firestore'a taşı
- [ ] API servis sınıfı oluştur (`ApiService`)

### F3. Premium Flow'u Gerçeğe Bağla

- [ ] RevenueCat SDK entegrasyonu
- [ ] Premium sayfasındaki "Satın Al" butonu → gerçek IAP
- [ ] Satın alma sonrası `_isPremium` state'i güncelleme
- [ ] Abonelik durumu kontrolü (app açılışında)
- [ ] "Satın Alımları Geri Yükle" → RevenueCat.restorePurchases()

### F4. Reklamları Canlıya Al

- [ ] SPM çakışması çözüldüğünde `google_mobile_ads` paketini ekle
- [ ] `AdService` → gerçek init + banner yükleme
- [ ] `AdBanner` → placeholder yerine gerçek `AdWidget`
- [ ] Rewarded ad → `_watchAd()` metodunda gerçek reklam göster
- [ ] Interstitial → namaz vakti → kuran geçişi gibi noktalara ekle

### F5. Veri Senkronizasyonu

- [ ] İbadet takibi verilerini Firestore'a yaz/oku
- [ ] İlk açılışta lokal veriyi cloud'a migrate et
- [ ] Offline queue — internet yoksa lokale yaz, gelince sync'le
- [ ] Çakışma çözümü (son yazan kazanır)

### F6. Push Notification

- [ ] FCM token'ını al, Firestore'a kaydet
- [ ] Bildirim izni iste (iOS özellikle hassas)
- [ ] Bildirim tercihleri sayfası (hangi vakitler, aç/kapat)
- [ ] Lokasyon değişince saatleri güncelle

### F7. Eksik Ekranlar / Özellikler

- [ ] **Profil sayfası** — isim, email, abonelik durumu, çıkış yap
- [ ] **Onboarding flow** — ilk açılışta 3-4 adım (konum izni, bildirim izni, kayıt)
- [ ] **Şehir arama** — şehir seçiciye arama çubuğu ekle
- [ ] **Kuran'da yer imi** — son okunan sayfayı kaydet, devam et
- [ ] **Arama** — sure/ayet araması (Kuran'da)
- [ ] **Loading/Error state iyileştirmeleri** — tüm sayfalarda tutarlı
- [ ] **Boş state'ler** — "Henüz kaydedilmiş tefsir yok" gibi (bazıları var, tamamlama)
- [ ] **Erişilebilirlik** — font scaling, screen reader

### F8. Test & Kalite

- [ ] Widget testleri (temel bileşenler)
- [ ] Integration test (kritik akışlar)
- [ ] iOS + Android farklı ekran boyutlarında test
- [ ] Performance profiling (özellikle Kuran sayfaları)
- [ ] Offline mod testi

### F9. App Store Hazırlığı

- [ ] App simgesi (1024x1024)
- [ ] Splash screen
- [ ] Ekran görüntüleri (6.5" + 5.5" iPhone, çeşitli Android)
- [ ] App Store açıklaması (Türkçe + İngilizce)
- [ ] Gizlilik politikası URL'i
- [ ] Kullanım şartları URL'i
- [ ] App Store Connect sayfası (kategori: Reference / Lifestyle)
- [ ] Google Play Console sayfası

---

## Öncelikli Yol Haritası

| Öncelik | Görev | Tahmini Süre |
|---|---|---|
| 🔴 P0 | Firebase proje kurulumu + Auth | 2 gün |
| 🔴 P0 | AI Proxy (Functions) — API key güvenliği | 1 gün |
| 🔴 P0 | RevenueCat IAP entegrasyonu | 2 gün |
| 🟡 P1 | Firestore veri modeli + sync | 3 gün |
| 🟡 P1 | Auth ekranı (Login/Register) | 2 gün |
| 🟡 P1 | Premium flow'u RevenueCat'e bağla | 1 gün |
| 🟢 P2 | Reklamları canlıya al (SPM çözülünce) | 1 gün |
| 🟢 P2 | Push notification | 2 gün |
| 🟢 P2 | Profil + onboarding + eksik ekranlar | 2 gün |
| ⚪ P3 | Testler, performans, App Store hazırlığı | 3 gün |
| **Toplam** | | **~19 gün** |

---

## Tahmini Maliyet (Aylık, Firebase Blaze Plan)

| Servis | 1.000 kullanıcı | 100.000 kullanıcı |
|---|---|---|
| Firebase Auth | Ücretsiz | Ücretsiz |
| Cloud Firestore | Ücretsiz | ~$5-10 |
| Firebase Functions | Ücretsiz | ~$10-20 |
| Firebase Storage | Ücretsiz | ~$5 |
| Gemini API (AI Proxy) | ~$1 | ~$100 |
| RevenueCat | Ücretsiz (ilk $10K MRR) | $120 (1% of revenue) |
| **Toplam** | **~$1/ay** | **~$150-250/ay** |
