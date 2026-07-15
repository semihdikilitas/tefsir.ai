# Tefsir AI — Backend Planı

> Son güncelleme: Temmuz 2026

---

## Backend Mimarisi

| Katman | Teknoloji | Neden |
|---|---|---|
| Sunucu | **Firebase** (BaaS) | Ücretsiz başlangıç, sıfır sunucu yönetimi, Flutter ile native entegrasyon |
| Auth | Firebase Auth | Google/Apple/Email sign-in |
| Veritabanı | Cloud Firestore | Realtime sync, offline destek, ücretsiz tier 50K okuma/gün |
| AI Proxy | Firebase Functions | Gemini API key'i sunucuda gizli, rate limiting, token sayacı |
| Depolama | Firebase Storage | Kuran sayfaları, şehir görselleri, kullanıcı upload'ları |
| Abonelik | **RevenueCat** | App Store / Google Play IAP yönetimi, webhook, cross-platform |
| Push Notification | Firebase Cloud Messaging | Namaz vakti hatırlatmaları |
| Analitik | Firebase Analytics + Crashlytics | Ücretsiz, güçlü |

**Alternatif:** Supabase (açık kaynak, PostgreSQL) — Firebase'in Flutter desteği daha olgun.

---

## Neden Backend Şimdi Gerekli?

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
- [ ] Firebase Functions (Blaze plan)
- [ ] Firebase Cloud Messaging (push notification)

### B2. Cloud Firestore Veri Modeli
```
users/{userId}/
  ├── profile
  │   ├── email, name, createdAt, isPremium, subscriptionExpiry
  ├── worship/{date}/
  │   ├── imsak, ogle, ikindi, aksam, yatsi, quranPages, dhikrCount, isFasting
  ├── bookmarks/{id}/
  │   ├── question, answer, surahRefs, createdAt
  └── ai_usage/{yearMonth}/
      ├── questionsUsed, questionsLimit
```

### B3. Firebase Functions (AI Proxy)
```typescript
exports.askTafsir = functions.https.onCall(async (data, context) => {
  const userId = context.auth?.uid;
  if (!userId) throw new HttpsError('unauthenticated');
  const usage = await getUserQuota(userId);
  if (usage.remaining <= 0) throw new HttpsError('resource-exhausted');
  const answer = await geminiAI.ask(data.question);
  await decrementQuota(userId);
  await logUsage(userId, data.question, answer);
  return { answer, remaining: usage.remaining - 1 };
});
```

### B4. RevenueCat Entegrasyonu
- [ ] RevenueCat hesabı → App Store Connect / Google Play Console bağla
- [ ] Ürünleri tanımla:
  - `premium_monthly` (₺49,99)
  - `premium_yearly` (₺299,99)
  - `token_50` (₺19,99)
  - `token_200` (₺49,99)
  - `token_500` (₺99,99)
- [ ] RevenueCat SDK'yı Flutter'a ekle
- [ ] Satın alma flow'unu bağla
- [ ] Webhook ile premium durumunu Firestore'a yaz

### B5. Push Notification Sistemi
- [ ] Namaz vakti hatırlatması
- [ ] Cuma namazı özel hatırlatması
- [ ] Streak motivasyon bildirimi

---

## Frontend Kalan İşler

### ✅ Tamamlananlar
- [x] Auth ekranı (Login/Register/sosyal/misafir)
- [x] Profil sayfası
- [x] Onboarding flow (4 adım)
- [x] Şehir arama
- [x] Kuran yer imi
- [x] Reklam altyapısı (placeholder)
- [x] Çoklu dil (TR/EN/AR/FA)
- [x] Günlük sohbet reset + geçmiş
- [x] Premium sayfası + token paketleri
- [x] Kaza takibi
- [x] Rozet sistemi

### ⏳ Backend Bağımlı
- [ ] Firebase Auth'u gerçeğe bağla (P0)
- [ ] AI Proxy — Functions'a taşı (P0)
- [ ] RevenueCat IAP — premium flow'u bağla (P0)
- [ ] Firestore sync — ibadet verisi, bookmark (P1)
- [ ] Bildirimleri canlıya al (P2)
- [ ] Reklamları canlıya al — google_mobile_ads (P2, SPM çözülünce)

### ⏳ Backend Bağımsız
- [ ] Widget testleri (P3)
- [ ] App simgesi + splash screen (P3)
- [ ] App Store ekran görüntüleri (P3)
- [ ] Gizlilik politikası + kullanım şartları (P3)

---

## Öncelikli Yol Haritası

| Öncelik | Görev | Süre |
|---|---|---|
| 🔴 P0 | Firebase proje + Auth bağlantısı | 2 gün |
| 🔴 P0 | AI Proxy (Functions) | 1 gün |
| 🔴 P0 | RevenueCat IAP | 2 gün |
| 🟡 P1 | Firestore sync | 3 gün |
| 🟡 P1 | Auth ekranını Firebase'e bağla | 1 gün |
| 🟢 P2 | Reklamları canlıya al | 1 gün |
| 🟢 P2 | Push notification | 2 gün |
| ⚪ P3 | Test + App Store hazırlığı | 3 gün |
| **Toplam** | | **~15 gün** |

---

## Tahmini Maliyet (Aylık)

| Servis | 1.000 kullanıcı | 100.000 kullanıcı |
|---|---|---|
| Firebase Auth | Ücretsiz | Ücretsiz |
| Cloud Firestore | Ücretsiz | ~$5-10 |
| Firebase Functions | Ücretsiz | ~$10-20 |
| Firebase Storage | Ücretsiz | ~$5 |
| Gemini API | ~$1 | ~$100 |
| RevenueCat | Ücretsiz | $120 (%1 gelir) |
| **Toplam** | **~$1/ay** | **~$150-250/ay** |
