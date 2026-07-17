// Kuran verilerini alquran.cloud API'sinden indirip JSON dosyasi olarak kaydeder.
// Kullanim: node download-quran.js
// Kaynak: https://alquran.cloud/api (ucretsiz, rate-limit var)

const https = require('https');
const fs = require('fs');
const path = require('path');

const BASE = 'https://api.alquran.cloud/v1';
const DELAY = 500; // Her istek arasi 500ms (rate-limit'e takilmamak icin)

function fetch(url) {
  return new Promise((resolve, reject) => {
    https.get(url, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try { resolve(JSON.parse(data)); }
        catch(e) { reject(e); }
      });
    }).on('error', reject);
  });
}

function sleep(ms) { return new Promise(r => setTimeout(r, ms)); }

async function downloadAll() {
  console.log('Kuran verileri indiriliyor...');

  // 1. Sure listesini al
  const listRes = await fetch(`${BASE}/surah`);
  const surahs = listRes.data;
  console.log(`${surahs.length} sure bulundu`);

  const result = [];

  for (let i = 0; i < surahs.length; i++) {
    const s = surahs[i];
    const num = s.number;
    process.stdout.write(`\rSure ${num}/114: ${s.englishName}...`);

    try {
      // Arapca + Turkce meal + Ingilizce meal paralel cek
      const [arabic, turkish, english] = await Promise.all([
        fetch(`${BASE}/surah/${num}/quran-uthmani`),
        fetch(`${BASE}/surah/${num}/tr.diyanet`),
        fetch(`${BASE}/surah/${num}/en.sahih`),
      ]);

      const ayahs = arabic.data.ayahs.map((a, idx) => ({
        id: a.numberInSurah,
        text: a.text,
        translation: turkish.data?.ayahs?.[idx]?.text || '',
        transliteration: english.data?.ayahs?.[idx]?.text || '',
      }));

      result.push({
        id: num,
        name: s.name,
        transliteration: s.englishName,
        translation: s.englishNameTranslation || s.englishName,
        type: s.revelationType === 'Meccan' ? 'meccan' : 'medinan',
        total_verses: s.numberOfAyahs,
        verses: ayahs,
      });
    } catch (e) {
      console.error(`\nSure ${num} hatasi:`, e.message);
    }

    await sleep(DELAY);
  }

  // Kaydet
  const outPath = path.join(__dirname, 'data', 'quran', 'quran_full.json');
  fs.writeFileSync(outPath, JSON.stringify(result, null, 2), 'utf-8');
  console.log(`\n\nKaydedildi: ${outPath} (${result.length} sure, ${result.reduce((a,s) => a+s.verses.length, 0)} ayet)`);
  console.log(`Boyut: ${(fs.statSync(outPath).size / 1024 / 1024).toFixed(1)} MB`);
}

downloadAll().catch(console.error);
