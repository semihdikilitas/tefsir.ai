const express = require('express');
const cors = require('cors');
const fs = require('fs');
const path = require('path');
const multer = require('multer');

const app = express();
const PORT = process.env.PORT || 3000;
const DATA_DIR = process.env.DATA_DIR || path.join(__dirname, 'data');
const ADMIN_PASSWORD = process.env.ADMIN_PASSWORD;
if (!ADMIN_PASSWORD) {
  console.error('FATAL: ADMIN_PASSWORD environment variable is required');
  process.exit(1);
}
const CLAUDE_API_KEY = process.env.CLAUDE_API_KEY || '';
const CLAUDE_MODEL = 'claude-haiku-4-5-20251001';

// Rate limiting (in-memory, restart'ta sifirlanir, periyodik temizlenir)
const rateLimitMap = new Map(); // IP -> { count, resetTime }
const loginAttempts = new Map(); // IP -> { count, lastAttempt }
const FREE_DAILY_LIMIT = 50;
const PREMIUM_DAILY_LIMIT = 500;
const RATE_CLEANUP_INTERVAL = 3600000; // 1 saatte bir temizlik

// Eski rate limit entry'lerini temizle
setInterval(() => {
  const now = Date.now();
  for (const [key, val] of rateLimitMap) {
    if (val.resetTime < now) rateLimitMap.delete(key);
  }
}, RATE_CLEANUP_INTERVAL);

function checkRateLimit(ip, isPremium) {
  const now = Date.now();
  const today = new Date().toDateString();
  const key = ip + '_' + today;
  const entry = rateLimitMap.get(key);
  const limit = isPremium ? PREMIUM_DAILY_LIMIT : FREE_DAILY_LIMIT;

  if (entry) {
    if (entry.count >= limit) return false;
    entry.count++;
  } else {
    rateLimitMap.set(key, { count: 1, resetTime: now + 86400000 });
  }
  return true;
}

// Brute force protection for login
const MAX_LOGIN_ATTEMPTS = 10;
const LOGIN_LOCKOUT_MS = 900000; // 15 dakika

function checkLoginRateLimit(ip) {
  const now = Date.now();
  const entry = loginAttempts.get(ip);
  if (!entry) return true;
  if (entry.count >= MAX_LOGIN_ATTEMPTS && now - entry.lastAttempt < LOGIN_LOCKOUT_MS) {
    return false;
  }
  if (now - entry.lastAttempt > LOGIN_LOCKOUT_MS) {
    loginAttempts.delete(ip);
    return true;
  }
  return true;
}

// Allowed fields per resource (prototype pollution onlemi)
const ALLOWED_FIELDS = {
  wallpapers: ['asset', 'imageUrl', 'category', 'verseText', 'surahName', 'verseNumbers', 'isPremium'],
  verses: ['text', 'surahName', 'verseNumbers'],
  hadiths: ['text', 'source', 'category', 'arabic'],
  prayers: ['title', 'category', 'arabic', 'transliteration', 'text', 'note'],
};

function sanitizeBody(body, resourceName) {
  const allowed = ALLOWED_FIELDS[resourceName] || [];
  const clean = {};
  for (const key of allowed) {
    if (body[key] !== undefined) {
      clean[key] = typeof body[key] === 'string' ? body[key].substring(0, 10000) : body[key];
    }
  }
  return clean;
}

app.use(cors({
  origin: process.env.ALLOWED_ORIGINS ? process.env.ALLOWED_ORIGINS.split(',') : '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
}));
app.use(express.json({ limit: '50kb' }));

// Auth middleware
function requireAdmin(req, res, next) {
  const pw = req.headers['x-admin-password'] || '';
  if (ADMIN_PASSWORD && pw === ADMIN_PASSWORD) return next();
  res.status(401).json({ error: 'Yetkisiz erisim. Lutfen giris yapin.' });
}

// Admin login endpoint
app.post('/api/admin/login', (req, res) => {
  const { password } = req.body;
  if (password === ADMIN_PASSWORD) {
    res.json({ success: true, token: ADMIN_PASSWORD });
  } else {
    res.status(401).json({ error: 'Hatali sifre' });
  }
});

// Admin panel
app.use('/admin', express.static(path.join(__dirname, 'admin')));

// Statik dosyalar (upload edilen resimler)
const uploadsDir = path.join(DATA_DIR, 'uploads');
if (!fs.existsSync(uploadsDir)) fs.mkdirSync(uploadsDir, { recursive: true });
app.use('/uploads', express.static(uploadsDir));

// ─── Yardimci fonksiyonlar ───

function ensureDataDir() {
  if (!fs.existsSync(DATA_DIR)) fs.mkdirSync(DATA_DIR, { recursive: true });
}

// In-memory cache for large files (tafsir 43MB, quran 4MB)
const dataCache = new Map();

function readData(filename) {
  // Return cached if available
  if (dataCache.has(filename)) return dataCache.get(filename);

  ensureDataDir();
  const filePath = path.join(DATA_DIR, filename);
  if (!fs.existsSync(filePath)) {
    const seedPath = path.join(__dirname, 'seed', filename);
    if (fs.existsSync(seedPath)) {
      fs.copyFileSync(seedPath, filePath);
    } else {
      return [];
    }
  }
  try {
    const data = JSON.parse(fs.readFileSync(filePath, 'utf-8'));
    // Cache large files (>1MB) in memory
    if (filePath.endsWith('tafsir.json') || filePath.endsWith('quran_full.json')) {
      dataCache.set(filename, data);
    }
    return data;
  } catch {
    return [];
  }
}

// Invalidate cache on write
function writeData(filename, data) {
  ensureDataDir();
  const filePath = path.join(DATA_DIR, filename);
  fs.writeFileSync(filePath, JSON.stringify(data, null, 2), 'utf-8');
  dataCache.delete(filename); // Invalidate cache
}

// ─── Resim upload ───

const storage = multer.diskStorage({
  destination: uploadsDir,
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname);
    cb(null, Date.now() + '-' + Math.round(Math.random() * 1e9) + ext);
  },
});
const upload = multer({
  storage,
  limits: { fileSize: 50 * 1024 * 1024 },
  fileFilter: (req, file, cb) => {
    const allowed = ['image/jpeg', 'image/png', 'image/webp', 'image/gif'];
    if (allowed.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('Sadece resim dosyalari yuklenebilir (JPEG, PNG, WebP, GIF)'));
    }
  },
});

app.post('/api/upload', requireAdmin, upload.single('image'), (req, res) => {
  if (!req.file) return res.status(400).json({ error: 'Dosya yuklenemedi' });
  const url = `/uploads/${req.file.filename}`;
  res.json({ url, filename: req.file.filename });
});

// ─── Health check ───

app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', uptime: process.uptime(), dataDir: DATA_DIR });
});

// ─── CRUD: Generic handler ───

function crudRoutes(resourceName) {
  const filename = `${resourceName}.json`;
  const route = `/api/${resourceName}`;

  app.get(route, (req, res) => {
    const data = readData(filename);
    res.json(data);
  });

  app.get(`${route}/:id`, (req, res) => {
    const data = readData(filename);
    const item = data.find(w => w.id === req.params.id);
    if (!item) return res.status(404).json({ error: 'Bulunamadi' });
    res.json(item);
  });

  // Write endpoints: admin auth required
  app.post(route, requireAdmin, (req, res) => {
    const data = readData(filename);
    const item = { id: Date.now().toString(), ...req.body, createdAt: new Date().toISOString() };
    data.push(item);
    writeData(filename, data);
    res.status(201).json(item);
  });

  app.put(`${route}/:id`, requireAdmin, (req, res) => {
    const data = readData(filename);
    const index = data.findIndex(w => w.id === req.params.id);
    if (index === -1) return res.status(404).json({ error: 'Bulunamadi' });
    data[index] = { ...data[index], ...req.body, updatedAt: new Date().toISOString() };
    writeData(filename, data);
    res.json(data[index]);
  });

  app.delete(`${route}/:id`, requireAdmin, (req, res) => {
    const data = readData(filename);
    writeData(filename, data.filter(w => w.id !== req.params.id));
    res.json({ success: true });
  });
}

// ─── Tum kaynaklar icin CRUD ───

['wallpapers', 'verses', 'hadiths', 'prayers'].forEach(crudRoutes);

// ─── KURAN API ───

let quranData = null;
const SURAH_NAMES_PATH = path.join(__dirname, 'surah_names.json');

function loadQuranData() {
  if (quranData) return quranData;
  const p = path.join(DATA_DIR, 'quran', 'quran_full.json');
  if (!fs.existsSync(p)) {
    // Seed'den kopyala
    const seed = path.join(__dirname, 'seed', 'quran', 'quran_full.json');
    if (fs.existsSync(seed)) {
      const dir = path.dirname(p);
      if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
      fs.copyFileSync(seed, p);
    } else return [];
  }
  quranData = JSON.parse(fs.readFileSync(p, 'utf-8'));
  return quranData;
}

// Sure listesi (Turkce isimlerle)
app.get('/api/quran/surahs', (req, res) => {
  if (!fs.existsSync(SURAH_NAMES_PATH)) {
    return res.json([]);
  }
  res.json(JSON.parse(fs.readFileSync(SURAH_NAMES_PATH, 'utf-8')));
});

// Tek bir sure (tum ayetlerle)
app.get('/api/quran/surah/:id', (req, res) => {
  const data = loadQuranData();
  const surah = data.find(s => s.id === parseInt(req.params.id));
  if (!surah) return res.status(404).json({ error: 'Sure bulunamadi' });
  res.json(surah);
});

// Tek bir ayet
app.get('/api/quran/ayah/:surahId/:ayahId', (req, res) => {
  const data = loadQuranData();
  const surah = data.find(s => s.id === parseInt(req.params.surahId));
  if (!surah) return res.status(404).json({ error: 'Sure bulunamadi' });
  const ayah = surah.verses.find(a => a.id === parseInt(req.params.ayahId));
  if (!ayah) return res.status(404).json({ error: 'Ayet bulunamadi' });
  res.json({ surah: { id: surah.id, name: surah.name, translation: surah.translation }, ayah });
});

// Birden fazla ayet (range: /api/quran/ayahs/1/1-7)
app.get('/api/quran/ayahs/:surahId/:range', (req, res) => {
  const data = loadQuranData();
  const surah = data.find(s => s.id === parseInt(req.params.surahId));
  if (!surah) return res.status(404).json({ error: 'Sure bulunamadi' });

  const [start, end] = req.params.range.split('-').map(Number);
  const ayahs = surah.verses.filter(a => a.id >= start && a.id <= (end || start));
  res.json({ surah: { id: surah.id, name: surah.name, translation: surah.translation }, ayahs });
});

// Arama (ayet metninde veya mealde)
app.get('/api/quran/search', (req, res) => {
  const q = (req.query.q || '').toLowerCase();
  if (!q || q.length < 3 || q.length > 200) return res.json([]);

  const data = loadQuranData();
  const results = [];
  for (const surah of data) {
    for (const ayah of surah.verses) {
      if (ayah.translation.toLowerCase().includes(q) || ayah.text.includes(q)) {
        results.push({
          surah: { id: surah.id, name: surah.name, translation: surah.translation },
          ayah,
        });
        if (results.length >= 20) break; // Max 20 sonuc
      }
    }
    if (results.length >= 20) break;
  }
  res.json(results);
});

// ─── TEFSIR API ───

// Tefsir verisi (sure bazli parcali JSON, RAM dostu)
function loadTafsir(surahId) {
  const filePath = path.join(DATA_DIR, 'quran', 'tefsir', `${surahId}.json`);
  const seedPath = path.join(__dirname, 'seed', 'quran', 'tefsir', `${surahId}.json`);

  // Seed'den her zaman kopyala (guncel veri icin)
  if (fs.existsSync(seedPath)) {
    const dir = path.dirname(filePath);
    if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
    // Sadece seed daha yeniyse kopyala
    const seedStat = fs.statSync(seedPath);
    let copy = true;
    if (fs.existsSync(filePath)) {
      const dataStat = fs.statSync(filePath);
      copy = seedStat.mtime > dataStat.mtime;
    }
    if (copy) {
      fs.copyFileSync(seedPath, filePath);
    }
  } else if (!fs.existsSync(filePath)) {
    return [];
  }

  try {
    return JSON.parse(fs.readFileSync(filePath, 'utf-8'));
  } catch {
    return [];
  }
}

app.get('/api/tafsir/:surahId/:ayahId', (req, res) => {
  const data = loadTafsir(parseInt(req.params.surahId));
  const entry = data.find(t =>
    t.surahId === parseInt(req.params.surahId) &&
    t.ayahId === parseInt(req.params.ayahId)
  );
  if (!entry) return res.json({ text: 'Bu ayet icin henuz tefsir eklenmedi.', source: '' });
  res.json(entry);
});

app.get('/api/tafsir/:surahId', (req, res) => {
  const data = loadTafsir(parseInt(req.params.surahId));
  res.json(data);
});

// ─── KURAN SAYFA GORSEL API ───

// Sayfa URL listesini getir
app.get('/api/quran/pages', (req, res) => {
  const data = readData('quran_pages.json');
  res.json(data);
});

// Tek sayfanin URL'ini getir
app.get('/api/quran/page/:number', (req, res) => {
  const data = readData('quran_pages.json');
  const page = data.pages?.find(p => p.page === parseInt(req.params.number));
  if (!page) return res.status(404).json({ error: 'Sayfa bulunamadi' });
  res.json(page);
});

// ─── CLAUDE AI PROXY ───

app.post('/api/ai/ask', async (req, res) => {
  if (!CLAUDE_API_KEY) {
    return res.status(503).json({ error: 'AI servisi henuz yapilandirilmadi' });
  }

  const { messages, systemPrompt } = req.body;
  const ip = req.ip || 'unknown';
  const isPremium = req.headers['x-premium'] === 'true';

  // Rate limit kontrolu
  if (!checkRateLimit(ip, isPremium)) {
    return res.status(429).json({ error: 'Gunluk soru limitiniz doldu. Premium ile sinirsiz erisim saglayabilirsiniz.' });
  }

  try {
    const fullMessages = [
      ...(messages || []).slice(-10), // Son 10 mesaji al
    ];

    const resp = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'x-api-key': CLAUDE_API_KEY,
        'anthropic-version': '2023-06-01',
        'content-type': 'application/json',
      },
      body: JSON.stringify({
        model: CLAUDE_MODEL,
        max_tokens: 1024,
        temperature: 0.3,
        system: systemPrompt || '',
        messages: fullMessages,
      }),
    });

    if (!resp.ok) {
      const err = await resp.text();
      console.error(`Claude API error ${resp.status}:`, err.substring(0, 200));
      return res.status(resp.status).json({ error: 'AI servisi gecici olarak kullanilamiyor' });
    }

    const data = await resp.json();
    const reply = data.content[0].text;

    // Kullanim sayisini logla
    const key = ip + '_' + new Date().toDateString();
    const entry = rateLimitMap.get(key) || { count: 0 };
    console.log(`AI ask: ${ip} (${isPremium ? 'premium' : 'free'}) - ${entry.count}/${isPremium ? PREMIUM_DAILY_LIMIT : FREE_DAILY_LIMIT}`);

    res.json({ reply });
  } catch (e) {
    res.status(500).json({ error: 'AI servisi gecici olarak kullanilamiyor' });
  }
});

// ─── NAMAZ VAKITLERI PROXY ───

app.get('/api/prayer-times', async (req, res) => {
  try {
    const { lat, lng, date, method } = req.query;
    const today = new Date();
    const d = date || `${today.getDate().toString().padStart(2,'0')}-${(today.getMonth()+1).toString().padStart(2,'0')}-${today.getFullYear()}`;
    const m = method || '13'; // 13 = Diyanet

    const resp = await fetch(
      `https://api.aladhan.com/v1/timings/${d}?latitude=${lat || 41.0082}&longitude=${lng || 28.9784}&method=${m}`
    );
    const data = await resp.json();
    res.json(data);
  } catch (e) {
    res.status(500).json({ error: 'Namaz vakitleri alinamadi' });
  }
});

app.get('/api/prayer-times/health', (req, res) => {
  res.json({ status: 'ok' });
});

// ─── Baslat ───

const server = app.listen(PORT, '0.0.0.0', () => {
  console.log(`Tefsir AI API calisiyor: http://0.0.0.0:${PORT}`);
  console.log(`Admin panel: http://0.0.0.0:${PORT}/admin`);
  console.log(`Data dizini: ${DATA_DIR}`);
});

process.on('SIGTERM', () => {
  console.log('SIGTERM alindi, kapaniyor...');
  server.close(() => process.exit(0));
  setTimeout(() => process.exit(1), 10000);
});

process.on('SIGINT', () => {
  console.log('SIGINT alindi, kapaniyor...');
  server.close(() => process.exit(0));
  setTimeout(() => process.exit(1), 10000);
});
