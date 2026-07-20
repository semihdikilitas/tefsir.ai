#!/usr/bin/env python3
"""
Elmalili Tefsir OCR Duzeltme Scripti
Claude tarafindan yazilmis akilli indeksleme.
Calistir: python3 fix_tafsir.py
"""

import json, re, os, shutil
from collections import Counter

# ═══════════════════════════════════════════════════════
# 1. SURAH NAME FUZZY MATCHING
# ═══════════════════════════════════════════════════════

# Known OCR corruptions for each surah name
SURAH_FINGERPRINTS = {
    1:  ['FATIHA', 'FATİHA', 'FATll IA', 'FATlHA', 'FATiHA', 'FATI UA', 'FATI JIA',
         'FATIl IA', 'FATlllA', 'FATtl IA', 'FATI HA', 'FATIH A'],
    2:  ['BAKARA', 'BAKJRA', 'IİAKARA', 'UAKARA', 'BAKA RA', 'BAK ARA'],
    3:  ['IMRAN', 'İMRAN', 'lMRAN', '1MRAN', 'IMRAN', 'İM RAN'],
    4:  ['NISA', 'NİSA', 'NlsA', 'NiSA', 'N IS A'],
    5:  ['MAIDE', 'MAİDE', 'MAiDE', 'MA IDE'],
    6:  ["EN'AM", 'ENAM', 'EN1AM', "EN'İM", 'EN AM', "EN' AM"],
    7:  ["A'RAF", 'ARAF', "A' RAF", "A'R AF"],
    8:  ['ENFAL', 'ENF AL', 'ENFAL'],
    9:  ['TEVBE', 'TEYBE', 'TEVUE', 'TEV BE'],
    10: ['YUNUS', 'YUN US', 'YUNUS'],
    11: ['HUD', 'HÜD', 'l IUD', 'l HJD', 'llJD', 'H UD'],
    12: ['YUSUF', 'YÜSUF', 'YUS UF'],
    13: ["RA'D", 'RAD', "RA D"],
    14: ['IBRAHIM', 'İBRAHİM', 'IBRAHiM', 'IBRAH IM'],
    15: ['HICR', 'HİCR', 'HIC R'],
    16: ['NAHL', 'NA HL'],
    17: ['ISRA', 'İSRA', 'IS RA'],
    18: ['KEHF', 'KE HF'],
    19: ['MERYEM', 'MER YEM'],
    20: ['TAHA', 'TÂHÂ', 'TA HA'],
    21: ['ENBIYA', 'ENBİYA', 'ENB IYA'],
    22: ['HACC', 'HAC C', 'HAC'],
    23: ["MU'MINUN", 'MÜMİNUN', 'MUMINUN'],
    24: ['NUR', 'NÜR', 'NU R'],
    25: ['FURKAN', 'FUR KAN', 'FURK AN'],
    26: ["SU'ARA", 'ŞUARA', "SU ARA"],
    27: ['NEML', 'NEM L'],
    28: ['KASAS', 'KAS AS'],
    29: ['ANKEBUT', 'ANKEBÜT', 'ANKE BUT'],
    30: ['RUM', 'RÜM', 'RU M'],
    31: ['LOKMAN', 'LOK MAN'],
    32: ['SECDE', 'SEC DE'],
    33: ['AHZAB', 'AH ZAB'],
    34: ['SEBE', "SEBE'", 'SE BE'],
    35: ['FATIR', 'FÂTIR', 'FAT IR'],
    36: ['YASIN', 'YÂSÎN', 'YAS IN', 'YASiN'],
    37: ['SAFFAT', 'SÂFFÂT', 'SAF FAT'],
    38: ['SAD', 'SÂD', 'SA D'],
    39: ['ZUMER', 'ZÜMER', 'ZU MER'],
    40: ["MU'MIN", 'MÜMİN', 'MUMIN'],
}

def score_surah_match(text_upper):
    """Return {surah_num: match_count} for how many fingerprint hits each surah has"""
    scores = {}
    for snum, fingerprints in SURAH_FINGERPRINTS.items():
        count = sum(text_upper.count(f) for f in fingerprints)
        if count > 0:
            scores[snum] = count
    return scores

def identify_surah(text):
    """Smart surah identification with tiebreaking"""
    scores = score_surah_match(text.upper())
    if not scores:
        return None

    # Find the surah with the MOST fingerprint hits
    best = max(scores, key=lambda k: (scores[k], k))

    # Confidence check: need at least 2 hits, or 3x more than runner-up
    if scores[best] >= 3:
        return best

    runner_up = max((s for s in scores if s != best), key=lambda k: scores.get(k, 0), default=None)
    if runner_up and scores[best] >= scores[runner_up] * 2:
        return best

    if scores[best] >= 2 and not runner_up:
        return best

    return None  # Not confident enough

# ═══════════════════════════════════════════════════════
# 2. AYAH NUMBER DETECTION
# ═══════════════════════════════════════════════════════

def extract_ayahs(text, current_surah):
    """Extract valid ayah numbers from text, filtering out page numbers"""
    # Pattern: SURESI: 123 or SURESi: 123-125
    matches = re.findall(
        r'(?:SUR|SÜR|sfJR|S[J]R|s[uü]r)\w*\s*:\s*(\d+(?:\s*[-.]\s*\d+)?)',
        text, re.IGNORECASE
    )

    ayahs = set()
    for m in matches:
        m = re.sub(r'\s+', '', m).split('.')[0]
        if not m or not m[0].isdigit():
            continue
        try:
            if '-' in m:
                parts = m.split('-')
                for a in range(int(parts[0]), int(parts[1]) + 1):
                    if 1 <= a <= 286:  # Max ayahs in any surah
                        ayahs.add(a)
            else:
                a = int(m)
                if 1 <= a <= 286:
                    ayahs.add(a)
        except:
            pass

    return sorted(ayahs)

# ═══════════════════════════════════════════════════════
# 3. EXPECTED AYAH COUNTS PER SURAH
# ═══════════════════════════════════════════════════════

EXPECTED = {
    1:7, 2:286, 3:200, 4:176, 5:120, 6:165, 7:206, 8:75, 9:129, 10:109,
    11:123, 12:111, 13:43, 14:52, 15:99, 16:128, 17:111, 18:110, 19:98, 20:135,
    21:112, 22:78, 23:118, 24:64, 25:77, 26:227, 27:93, 28:88, 29:69, 30:60,
    31:34, 32:30, 33:73, 34:54, 35:45, 36:83, 37:182, 38:88, 39:75, 40:85
}

def validate_ayah(surah_id, ayah_id):
    """Check if ayah number is valid for this surah"""
    max_ayah = EXPECTED.get(surah_id, 300)
    return 1 <= ayah_id <= max_ayah

# ═══════════════════════════════════════════════════════
# 4. MAIN PROCESSING
# ═══════════════════════════════════════════════════════

VOLUMES = [
    'sayfalar_cilt1.json',
    'Hak_Dini_Kuran_Dili_Cilt_2.json',
    'Hak_Dini_Kuran_Dili_Cilt_3.json',
    'Hak_Dini_Kuran_Dili_Cilt_4.json',
    'Hak_Dini_Kuran_Dili_Cilt_5.json',
    'Hak_Dini_Kuran_Dili_Cilt_6.json',
    'Hak_Dini_Kuran_Dili_Cilt_7.json',
    'Hak_Dini_Kuran_Dili_Cilt_8.json',
    'Hak_Dini_Kuran_Dili_Cilt_9.json',
    'Hak_Dini_Kuran_Dili_Cilt_10.json',
]

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
all_entries = []

for vol_name in VOLUMES:
    vol_path = os.path.join(BASE_DIR, vol_name)
    if not os.path.exists(vol_path):
        print(f"  SKIP: {vol_name}")
        continue

    with open(vol_path) as f:
        data = json.load(f)

    # Handle both formats
    if vol_name == 'sayfalar_cilt1.json':
        pages = data
        pages = sorted(pages, key=lambda p: p.get('pdf_sayfa_no', 0))
    else:
        pages = data.get('pages', [])
        pages = sorted(pages, key=lambda p: p.get('page', 0))

    current_surah = None
    current_ayah = 0
    page_count = 0
    entry_count = 0

    for p in pages:
        text = p.get('text', p.get('tefsir_metni', ''))
        if len(text) < 80:
            continue

        # SMART surah detection with confidence scoring
        detected = identify_surah(text)
        if detected and detected != current_surah:
            current_surah = detected
            current_ayah = 0

        if not current_surah:
            continue

        # Extract ayah numbers
        ayahs = extract_ayahs(text, current_surah)

        if ayahs:
            # Update to the highest valid ayah
            valid_ayahs = [a for a in ayahs if validate_ayah(current_surah, a)]
            if valid_ayahs:
                current_ayah = max(valid_ayahs)

                for a in valid_ayahs:
                    all_entries.append({
                        'surahId': current_surah,
                        'ayahId': a,
                        'text': text.strip(),
                        'source': "Elmalili Hamdi Yazir - Hak Dini Kur'an Dili"
                    })
                    entry_count += 1

        elif current_ayah > 0:
            # Continuation page: belongs to current ayah
            if validate_ayah(current_surah, current_ayah):
                all_entries.append({
                    'surahId': current_surah,
                    'ayahId': current_ayah,
                    'text': text.strip(),
                    'source': "Elmalili Hamdi Yazir - Hak Dini Kur'an Dili"
                })
                entry_count += 1

        page_count += 1

    print(f"  {vol_name}: {entry_count} entries ({page_count} pages)")

# ═══════════════════════════════════════════════════════
# 5. POST-PROCESSING CLEANUP
# ═══════════════════════════════════════════════════════

print(f"\nRaw: {len(all_entries)} entries")

# Remove invalid entries
valid = [e for e in all_entries if validate_ayah(e['surahId'], e['ayahId'])]
print(f"After validation: {len(valid)} entries (removed {len(all_entries) - len(valid)})")

# Fix mis-assignments: if first 2 lines clearly say a different surah
# Only fix if the alternative surah has 3x more hits than current
def first_line_check(text, current_surah):
    """Check if first 2 lines clearly belong to a different surah"""
    first_part = '\n'.join(text.split('\n')[:2]).upper()
    scores = score_surah_match(first_part)
    if not scores or current_surah not in scores:
        return None

    current_score = scores[current_surah]
    best = max(scores, key=lambda k: scores[k])
    best_score = scores[best]

    # Only override if another surah is clearly more present
    if best != current_surah and best_score > current_score * 3:
        return best
    return None

fixed = []
moved = 0
for e in valid:
    correction = first_line_check(e['text'], e['surahId'])
    if correction and 1 <= correction <= 40:
        e = dict(e)
        e['surahId'] = correction
        moved += 1
    # Re-validate after potential move
    if validate_ayah(e['surahId'], e['ayahId']):
        fixed.append(e)

print(f"First-line fix: moved {moved} entries")
print(f"Final: {len(fixed)} entries")

# ═══════════════════════════════════════════════════════
# 6. COVERAGE REPORT
# ═══════════════════════════════════════════════════════

cs = Counter(e['surahId'] for e in fixed)
print(f"\nCoverage: {len(cs)} surahs")
for s in sorted(cs):
    ayahs = sorted(set(e['ayahId'] for e in fixed if e['surahId'] == s))
    exp = EXPECTED.get(s, '?')
    print(f"  Surah {s:2d}: {len(ayahs):3d}/{exp} ayahs ({min(ayahs)}-{max(ayahs)})")

# ═══════════════════════════════════════════════════════
# 7. SAVE
# ═══════════════════════════════════════════════════════

# Save Elmalili
with open(os.path.join(BASE_DIR, 'elmali_all.json'), 'w') as f:
    json.dump(fixed, f, ensure_ascii=False, indent=2)

print(f"\nSaved elmali_all.json")

# Merge with As-Saadi for server seed
saadi = []
seed_dir = os.path.join(os.path.dirname(BASE_DIR), 'server', 'seed', 'quran', 'tefsir')
for sid in range(1, 115):
    try:
        with open(f'{seed_dir}/{sid}.json') as f:
            saadi.extend(json.load(f))
    except:
        pass

if saadi:
    keys = set((e['surahId'], e['ayahId']) for e in fixed)
    merged = fixed.copy()
    for s in saadi:
        if (s['surahId'], s['ayahId']) not in keys:
            merged.append(s)

    out_dir = os.path.join(os.path.dirname(BASE_DIR), '..', 'server', 'seed', 'quran', 'tefsir')
    if os.path.exists(out_dir):
        shutil.rmtree(out_dir)
    os.makedirs(out_dir)
    for sid in set(t['surahId'] for t in merged):
        entries = [t for t in merged if t['surahId'] == sid]
        with open(f'{out_dir}/{sid}.json', 'w', encoding='utf-8') as f:
            json.dump(entries, f, ensure_ascii=False, indent=2)

    print(f"Merged with As-Saadi: {len(merged)} entries, seed updated")
else:
    print("As-Saadi not found — skipping merge")

print("\n✅ Done! Run: flyctl deploy server/ -a tefsir-ai-api")
