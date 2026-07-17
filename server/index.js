const express = require('express');
const cors = require('cors');
const fs = require('fs');
const path = require('path');
const multer = require('multer');

const app = express();
const PORT = process.env.PORT || 3000;
const DATA_DIR = process.env.DATA_DIR || path.join(__dirname, 'data');

app.use(cors());
app.use(express.json());

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

function readData(filename) {
  ensureDataDir();
  const filePath = path.join(DATA_DIR, filename);
  if (!fs.existsSync(filePath)) {
    // Fallback: built-in seed data'dan kopyala
    const seedPath = path.join(__dirname, 'seed', filename);
    if (fs.existsSync(seedPath)) {
      fs.copyFileSync(seedPath, filePath);
    } else {
      return [];
    }
  }
  try {
    return JSON.parse(fs.readFileSync(filePath, 'utf-8'));
  } catch {
    return [];
  }
}

function writeData(filename, data) {
  ensureDataDir();
  const filePath = path.join(DATA_DIR, filename);
  fs.writeFileSync(filePath, JSON.stringify(data, null, 2), 'utf-8');
}

// ─── Resim upload ───

const storage = multer.diskStorage({
  destination: uploadsDir,
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname);
    cb(null, Date.now() + '-' + Math.round(Math.random() * 1e9) + ext);
  },
});
const upload = multer({ storage, limits: { fileSize: 50 * 1024 * 1024 } });

app.post('/api/upload', upload.single('image'), (req, res) => {
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

  app.post(route, (req, res) => {
    const data = readData(filename);
    const item = { id: Date.now().toString(), ...req.body, createdAt: new Date().toISOString() };
    data.push(item);
    writeData(filename, data);
    res.status(201).json(item);
  });

  app.put(`${route}/:id`, (req, res) => {
    const data = readData(filename);
    const index = data.findIndex(w => w.id === req.params.id);
    if (index === -1) return res.status(404).json({ error: 'Bulunamadi' });
    data[index] = { ...data[index], ...req.body, updatedAt: new Date().toISOString() };
    writeData(filename, data);
    res.json(data[index]);
  });

  app.delete(`${route}/:id`, (req, res) => {
    const data = readData(filename);
    writeData(filename, data.filter(w => w.id !== req.params.id));
    res.json({ success: true });
  });
}

// ─── Tum kaynaklar icin CRUD ───

['wallpapers', 'verses', 'hadiths', 'prayers'].forEach(crudRoutes);

// ─── Baslat ───

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Tefsir AI API calisiyor: http://0.0.0.0:${PORT}`);
  console.log(`Admin panel: http://0.0.0.0:${PORT}/admin`);
  console.log(`Data dizini: ${DATA_DIR}`);
});
