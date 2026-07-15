import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// İlçe verisi.
class District {
  final String name;
  final String slug;
  final double lat;
  final double lng;
  const District(this.name, this.slug, this.lat, this.lng);
}

/// Şehir verisi.
class City {
  final String name;
  final String slug;
  final double lat;
  final double lng;
  final List<District> districts;
  const City(this.name, this.slug, this.lat, this.lng, {this.districts = const []});
}

/// Ülke verisi.
class Country {
  final String name;
  final List<City> cities;
  const Country(this.name, this.cities);
}

// ═══════════════════════════════════════════════════════════════
// VERİ
// ═══════════════════════════════════════════════════════════════

const List<Country> countries = [
  Country('Türkiye', [
    City('Adana', 'adana', 37.0000, 35.3213, districts: [District('Seyhan', 'seyhan', 36.9914, 35.3308), District('Çukurova', 'cukurova', 37.0500, 35.2833), District('Yüreğir', 'yuregir', 36.9833, 35.3667), District('Ceyhan', 'ceyhan', 37.0283, 35.8125)]),
    City('Adıyaman', 'adiyaman', 37.7642, 38.2786, districts: [District('Merkez', 'merkez', 37.7642, 38.2786), District('Besni', 'besni', 37.6917, 37.8573), District('Kahta', 'kahta', 37.7853, 38.6237)]),
    City('Afyonkarahisar', 'afyonkarahisar', 38.7568, 30.5387, districts: [District('Merkez', 'merkez', 38.7568, 30.5387), District('Sandıklı', 'sandikli', 38.4650, 30.2700), District('Bolvadin', 'bolvadin', 38.7167, 31.0500)]),
    City('Ağrı', 'agri', 39.7191, 43.0503, districts: [District('Merkez', 'merkez', 39.7191, 43.0503), District('Doğubayazıt', 'dogubayazit', 39.5475, 44.0833), District('Patnos', 'patnos', 39.2261, 42.8583)]),
    City('Aksaray', 'aksaray', 38.3712, 34.0285, districts: [District('Merkez', 'merkez', 38.3712, 34.0285), District('Ortaköy', 'ortakoy', 38.7333, 34.0333)]),
    City('Amasya', 'amasya', 40.6500, 35.8333, districts: [District('Merkez', 'merkez', 40.6500, 35.8333), District('Merzifon', 'merzifon', 40.8733, 35.4633), District('Suluova', 'suluova', 40.8333, 35.6500)]),
    City('Ankara', 'ankara', 39.9334, 32.8597, districts: [District('Çankaya', 'cankaya', 39.8961, 32.8747), District('Keçiören', 'kecioren', 39.9833, 32.8667), District('Yenimahalle', 'yenimahalle', 39.9667, 32.8000), District('Mamak', 'mamak', 39.9333, 32.9167), District('Etimesgut', 'etimesgut', 39.9500, 32.6500), District('Altındağ', 'altindag', 39.9500, 32.8667), District('Sincan', 'sincan', 39.9667, 32.5833), District('Gölbaşı', 'golbasi', 39.7833, 32.8000)]),
    City('Antalya', 'antalya', 36.8969, 30.7133, districts: [District('Muratpaşa', 'muratpasa', 36.8833, 30.7667), District('Konyaaltı', 'konyaalti', 36.8667, 30.6333), District('Kepez', 'kepez', 36.9167, 30.7000), District('Alanya', 'alanya', 36.5436, 31.9997), District('Manavgat', 'manavgat', 36.7833, 31.4333), District('Serik', 'serik', 36.9167, 31.1000), District('Kemer', 'kemer', 36.6000, 30.5500)]),
    City('Ardahan', 'ardahan', 41.1103, 42.7022),
    City('Artvin', 'artvin', 41.1828, 41.8183),
    City('Aydın', 'aydin', 37.8483, 27.8453, districts: [District('Efeler', 'efeler', 37.8483, 27.8453), District('Kuşadası', 'kusadasi', 37.8600, 27.2600), District('Didim', 'didim', 37.3756, 27.2678), District('Nazilli', 'nazilli', 37.9125, 28.3206)]),
    City('Balıkesir', 'balikesir', 39.6484, 27.8826, districts: [District('Karesi', 'karesi', 39.6484, 27.8826), District('Altıeylül', 'altieylul', 39.6500, 27.8833), District('Bandırma', 'bandirma', 40.3500, 27.9833), District('Edremit', 'edremit', 39.5969, 27.0189), District('Ayvalık', 'ayvalik', 39.3167, 26.7000)]),
    City('Bartın', 'bartin', 41.6344, 32.3375),
    City('Batman', 'batman', 37.8828, 41.1275),
    City('Bayburt', 'bayburt', 40.2550, 40.2240),
    City('Bilecik', 'bilecik', 40.1426, 29.9793),
    City('Bingöl', 'bingol', 38.8844, 40.4933),
    City('Bitlis', 'bitlis', 38.4000, 42.1167),
    City('Bolu', 'bolu', 40.7350, 31.6061),
    City('Burdur', 'burdur', 37.7203, 30.2908),
    City('Bursa', 'bursa', 40.1885, 29.0610, districts: [District('Osmangazi', 'osmangazi', 40.1972, 29.0556), District('Nilüfer', 'nilufer', 40.2167, 28.9833), District('Yıldırım', 'yildirim', 40.1833, 29.0833), District('İnegöl', 'inegol', 40.0764, 29.5083), District('Gemlik', 'gemlik', 40.4333, 29.1500), District('Mudanya', 'mudanya', 40.3500, 28.8833)]),
    City('Çanakkale', 'canakkale', 40.1553, 26.4142),
    City('Çankırı', 'cankiri', 40.6000, 33.6167),
    City('Çorum', 'corum', 40.5486, 34.9533),
    City('Denizli', 'denizli', 37.7765, 29.0864, districts: [District('Merkezefendi', 'merkezefendi', 37.7765, 29.0864), District('Pamukkale', 'pamukkale', 37.9167, 29.1167)]),
    City('Diyarbakır', 'diyarbakir', 37.9246, 40.2119, districts: [District('Bağlar', 'baglar', 37.9167, 40.2000), District('Kayapınar', 'kayapinar', 37.9500, 40.1833), District('Yenişehir', 'yenisehir', 37.9167, 40.2333), District('Sur', 'sur', 37.9108, 40.2367)]),
    City('Düzce', 'duzce', 40.8389, 31.1639),
    City('Edirne', 'edirne', 41.6818, 26.5623),
    City('Elazığ', 'elazig', 38.6742, 39.2228),
    City('Erzincan', 'erzincan', 39.7500, 39.5000),
    City('Erzurum', 'erzurum', 39.9055, 41.2658, districts: [District('Yakutiye', 'yakutiye', 39.9055, 41.2658), District('Palandöken', 'palandoken', 39.8833, 41.2833), District('Aziziye', 'aziziye', 39.9500, 41.1000)]),
    City('Eskişehir', 'eskisehir', 39.7767, 30.5206, districts: [District('Odunpazarı', 'odunpazari', 39.7667, 30.5167), District('Tepebaşı', 'tepebasi', 39.7833, 30.5000)]),
    City('Gaziantep', 'gaziantep', 37.0662, 37.3833, districts: [District('Şahinbey', 'sahinbey', 37.0597, 37.3764), District('Şehitkamil', 'sehitkamil', 37.0764, 37.3903), District('Nizip', 'nizip', 37.0167, 37.7667)]),
    City('Giresun', 'giresun', 40.9167, 38.3875),
    City('Gümüşhane', 'gumushane', 40.4603, 39.4814),
    City('Hakkari', 'hakkari', 37.5774, 43.7367),
    City('Hatay', 'hatay', 36.2000, 36.1500, districts: [District('Antakya', 'antakya', 36.2000, 36.1500), District('İskenderun', 'iskenderun', 36.5833, 36.1667), District('Defne', 'defne', 36.1500, 36.1333)]),
    City('Iğdır', 'igdir', 39.9208, 44.0444),
    City('Isparta', 'isparta', 37.7625, 30.5561),
    City('İstanbul', 'istanbul', 41.0082, 28.9784, districts: [District('Fatih', 'fatih', 41.0200, 28.9400), District('Kadıköy', 'kadikoy', 40.9900, 29.0300), District('Beşiktaş', 'besiktas', 41.0433, 29.0083), District('Şişli', 'sisli', 41.0571, 28.9892), District('Üsküdar', 'uskudar', 41.0244, 29.0328), District('Beyoğlu', 'beyoglu', 41.0383, 28.9778), District('Bağcılar', 'bagcilar', 41.0400, 28.8567), District('Bakırköy', 'bakirkoy', 40.9800, 28.8700), District('Eyüpsultan', 'eyupsultan', 41.0500, 28.9333), District('Beylikdüzü', 'beylikduzu', 40.9900, 28.6500), District('Kartal', 'kartal', 40.9000, 29.1833), District('Maltepe', 'maltepe', 40.9333, 29.1333), District('Pendik', 'pendik', 40.8775, 29.2358), District('Sancaktepe', 'sancaktepe', 41.0042, 29.2472), District('Sultanbeyli', 'sultanbeyli', 40.9667, 29.2667), District('Tuzla', 'tuzla', 40.8500, 29.3167), District('Ümraniye', 'umraniye', 41.0197, 29.1247), District('Ataşehir', 'atasehir', 40.9833, 29.1167), District('Başakşehir', 'basaksehir', 41.0922, 28.8028), District('Esenyurt', 'esenyurt', 41.0333, 28.6667), District('Avcılar', 'avcilar', 40.9833, 28.7167), District('Küçükçekmece', 'kucukcekmece', 41.0167, 28.7833), District('Büyükçekmece', 'buyukcekmece', 41.0167, 28.5833), District('Silivri', 'silivri', 41.0739, 28.2472), District('Çekmeköy', 'cekmekoy', 41.0333, 29.1833), District('Sarıyer', 'sariyer', 41.1667, 29.0500)]),
    City('İzmir', 'izmir', 38.4192, 27.1287, districts: [District('Konak', 'konak', 38.4192, 27.1287), District('Karşıyaka', 'karsiyaka', 38.4564, 27.1189), District('Bornova', 'bornova', 38.4667, 27.2167), District('Buca', 'buca', 38.3833, 27.1667), District('Çiğli', 'cigli', 38.5000, 27.0500), District('Gaziemir', 'gaziemir', 38.3167, 27.1333), District('Karabağlar', 'karabaglar', 38.3833, 27.1167), District('Bayraklı', 'bayrakli', 38.4667, 27.1667), District('Narlıdere', 'narlidere', 38.3833, 27.0167), District('Güzelbahçe', 'guzelbahce', 38.3667, 26.9000), District('Çeşme', 'cesme', 38.3236, 26.3039), District('Aliağa', 'aliaga', 38.8000, 26.9667), District('Selçuk', 'selcuk', 37.9500, 27.3667), District('Torbalı', 'torbali', 38.1500, 27.3500), District('Urla', 'urla', 38.3167, 26.7667), District('Bergama', 'bergama', 39.1167, 27.1833)]),
    City('Kahramanmaraş', 'kahramanmaras', 37.5858, 36.9375, districts: [District('Dulkadiroğlu', 'dulkadiroglu', 37.5833, 36.9333), District('Onikişubat', 'onikisubat', 37.5858, 36.9375), District('Elbistan', 'elbistan', 38.2083, 37.1908)]),
    City('Karabük', 'karabuk', 41.2000, 32.6333),
    City('Karaman', 'karaman', 37.1819, 33.2181),
    City('Kars', 'kars', 40.6167, 43.1000),
    City('Kastamonu', 'kastamonu', 41.3887, 33.7827),
    City('Kayseri', 'kayseri', 38.7205, 35.4826, districts: [District('Melikgazi', 'melikgazi', 38.7205, 35.4826), District('Kocasinan', 'kocasinan', 38.7333, 35.4833), District('Talas', 'talas', 38.6833, 35.5500), District('Develi', 'develi', 38.3883, 35.4917)]),
    City('Kırıkkale', 'kirikkale', 39.8417, 33.5139),
    City('Kırklareli', 'kirklareli', 41.7333, 27.2167),
    City('Kırşehir', 'kirsehir', 39.1458, 34.1639),
    City('Kilis', 'kilis', 36.7184, 37.1212),
    City('Kocaeli', 'kocaeli', 40.7656, 29.9408, districts: [District('İzmit', 'izmit', 40.7656, 29.9408), District('Gebze', 'gebze', 40.8000, 29.4333), District('Darıca', 'darica', 40.7667, 29.3833), District('Körfez', 'korfez', 40.7833, 29.7167)]),
    City('Konya', 'konya', 37.8746, 32.4932, districts: [District('Selçuklu', 'selcuklu', 37.8833, 32.4833), District('Meram', 'meram', 37.8333, 32.4333), District('Karatay', 'karatay', 37.8667, 32.5167), District('Ereğli', 'eregli', 37.5083, 34.0500), District('Akşehir', 'aksehir', 38.3583, 31.4117)]),
    City('Kütahya', 'kutahya', 39.4242, 29.9833),
    City('Malatya', 'malatya', 38.3552, 38.3097, districts: [District('Battalgazi', 'battalgazi', 38.3552, 38.3097), District('Yeşilyurt', 'yesilyurt', 38.3000, 38.2500)]),
    City('Manisa', 'manisa', 38.6128, 27.4297, districts: [District('Şehzadeler', 'sehzadeler', 38.6128, 27.4297), District('Yunusemre', 'yunusemre', 38.6167, 27.4333), District('Akhisar', 'akhisar', 38.9167, 27.8333), District('Salihli', 'salihli', 38.4833, 28.1333), District('Turgutlu', 'turgutlu', 38.5000, 27.7000)]),
    City('Mardin', 'mardin', 37.3129, 40.7340, districts: [District('Artuklu', 'artuklu', 37.3129, 40.7340), District('Nusaybin', 'nusaybin', 37.0703, 41.2172), District('Kızıltepe', 'kiziltepe', 37.1914, 40.5864)]),
    City('Mersin', 'mersin', 36.8000, 34.6333, districts: [District('Akdeniz', 'akdeniz', 36.8000, 34.6333), District('Toroslar', 'toroslar', 36.8167, 34.6167), District('Yenişehir', 'yenisehir-mersin', 36.7833, 34.6000), District('Mezitli', 'mezitli', 36.7500, 34.5333), District('Tarsus', 'tarsus', 36.9167, 34.8833), District('Silifke', 'silifke', 36.3764, 33.9322), District('Erdemli', 'erdemli', 36.6083, 34.3153)]),
    City('Muğla', 'mugla', 37.2181, 28.3667, districts: [District('Menteşe', 'mentese', 37.2181, 28.3667), District('Bodrum', 'bodrum', 37.0333, 27.4333), District('Fethiye', 'fethiye', 36.6167, 29.1167), District('Marmaris', 'marmaris', 36.8500, 28.2667), District('Milas', 'milas', 37.3167, 27.7833)]),
    City('Muş', 'mus', 38.7333, 41.4911),
    City('Nevşehir', 'nevsehir', 38.6250, 34.7122, districts: [District('Merkez', 'merkez', 38.6250, 34.7122), District('Ürgüp', 'urgup', 38.6294, 34.9111)]),
    City('Niğde', 'nigde', 37.9667, 34.6833),
    City('Ordu', 'ordu', 40.9833, 37.8833, districts: [District('Altınordu', 'altinordu', 40.9833, 37.8833), District('Ünye', 'unye', 41.1333, 37.2833), District('Fatsa', 'fatsa', 41.0333, 37.5000)]),
    City('Osmaniye', 'osmaniye', 37.0758, 36.2500),
    City('Rize', 'rize', 41.0208, 40.5219),
    City('Sakarya', 'sakarya', 40.7800, 30.4033, districts: [District('Adapazarı', 'adapazari', 40.7800, 30.4033), District('Serdivan', 'serdivan', 40.7500, 30.3667), District('Hendek', 'hendek', 40.8000, 30.7500)]),
    City('Samsun', 'samsun', 41.2867, 36.3300, districts: [District('İlkadım', 'ilkadim', 41.2867, 36.3300), District('Atakum', 'atakum', 41.3333, 36.2833), District('Canik', 'canik', 41.2500, 36.3500), District('Bafra', 'bafra', 41.5667, 35.8833), District('Çarşamba', 'carsamba', 41.2000, 36.7333)]),
    City('Siirt', 'siirt', 37.9333, 41.9500),
    City('Sinop', 'sinop', 42.0264, 35.1500),
    City('Sivas', 'sivas', 39.7500, 37.0167),
    City('Şanlıurfa', 'sanliurfa', 37.1674, 38.7955, districts: [District('Haliliye', 'haliliye', 37.1674, 38.7955), District('Eyyübiye', 'eyyubiye', 37.1500, 38.7833), District('Karaköprü', 'karakopru', 37.1833, 38.8000), District('Siverek', 'siverek', 37.7500, 39.3167), District('Viranşehir', 'viransehir', 37.2333, 39.7667)]),
    City('Şırnak', 'sirnak', 37.5167, 42.4500),
    City('Tekirdağ', 'tekirdag', 40.9833, 27.5167, districts: [District('Süleymanpaşa', 'suleymanpasa', 40.9833, 27.5167), District('Çorlu', 'corlu', 41.1500, 27.8000), District('Çerkezköy', 'cerkezkoy', 41.2833, 27.9833)]),
    City('Tokat', 'tokat', 40.3139, 36.5544),
    City('Trabzon', 'trabzon', 41.0015, 39.7178, districts: [District('Ortahisar', 'ortahisar', 41.0015, 39.7178), District('Akçaabat', 'akcaabat', 41.0167, 39.5667), District('Of', 'of', 40.9500, 40.2667)]),
    City('Tunceli', 'tunceli', 39.1086, 39.5475),
    City('Uşak', 'usak', 38.6792, 29.4083),
    City('Van', 'van', 38.5000, 43.3833, districts: [District('İpekyolu', 'ipekyolu', 38.5000, 43.3833), District('Tuşba', 'tusba', 38.5000, 43.3667), District('Edremit', 'edremit-van', 38.4167, 43.2500), District('Erciş', 'ercis', 39.0333, 43.3667)]),
    City('Yalova', 'yalova', 40.6550, 29.2753),
    City('Yozgat', 'yozgat', 39.8208, 34.8083),
    City('Zonguldak', 'zonguldak', 41.4500, 31.7833, districts: [District('Merkez', 'merkez', 41.4500, 31.7833), District('Ereğli', 'eregli-zonguldak', 41.2833, 31.4167)]),
  ]),
  Country('Almanya', [
    City('Berlin', 'berlin', 52.5200, 13.4050),
    City('Köln', 'koln', 50.9375, 6.9603),
    City('Frankfurt', 'frankfurt', 50.1109, 8.6821),
    City('Münih', 'munih', 48.1351, 11.5820),
    City('Hamburg', 'hamburg', 53.5511, 9.9937),
    City('Stuttgart', 'stuttgart', 48.7758, 9.1829),
    City('Düsseldorf', 'dusseldorf', 51.2277, 6.7735),
  ]),
  Country('Fransa', [
    City('Paris', 'paris', 48.8566, 2.3522),
    City('Lyon', 'lyon', 45.7640, 4.8357),
    City('Marsilya', 'marsilya', 43.2965, 5.3698),
    City('Strazburg', 'strazburg', 48.5734, 7.7521),
  ]),
  Country('İngiltere', [
    City('Londra', 'londra', 51.5074, -0.1278),
    City('Birmingham', 'birmingham', 52.4862, -1.8904),
    City('Manchester', 'manchester', 53.4808, -2.2426),
  ]),
  Country('ABD', [
    City('New York', 'new-york', 40.7128, -74.0060),
    City('Los Angeles', 'los-angeles', 34.0522, -118.2437),
    City('Chicago', 'chicago', 41.8781, -87.6298),
    City('Houston', 'houston', 29.7604, -95.3698),
  ]),
  Country('Suudi Arabistan', [
    City('Mekke', 'mekke', 21.4225, 39.8262),
    City('Medine', 'medine', 24.5247, 39.5693),
    City('Riyad', 'riyad', 24.7136, 46.6753),
    City('Cidde', 'cidde', 21.5433, 39.1728),
  ]),
  Country('Mısır', [City('Kahire', 'kahire', 30.0444, 31.2357), City('İskenderiye', 'iskenderiye', 31.2001, 29.9187)]),
  Country('Ürdün', [City('Amman', 'amman', 31.9454, 35.9284)]),
  Country('Fas', [City('Kazablanka', 'kazablanka', 33.5731, -7.5898), City('Marakeş', 'marakes', 31.6295, -7.9811), City('Rabat', 'rabat', 34.0209, -6.8416), City('Fes', 'fes', 34.0181, -5.0078)]),
  Country('Cezayir', [City('Cezayir', 'cezayir', 36.7538, 3.0588), City('Vahran', 'vahran', 35.6969, -0.6331)]),
  Country('Tunus', [City('Tunus', 'tunus', 36.8065, 10.1815)]),
  Country('Libya', [City('Trablus', 'trablus', 32.8872, 13.1913), City('Bingazi', 'bingazi', 32.1167, 20.0667)]),
  Country('BAE', [City('Dubai', 'dubai', 25.2048, 55.2708), City('Abu Dabi', 'abu-dabi', 24.4539, 54.3773)]),
  Country('Katar', [City('Doha', 'doha', 25.2854, 51.5310)]),
  Country('Kuveyt', [City('Kuveyt', 'kuveyt', 29.3759, 47.9774)]),
  Country('Umman', [City('Maskat', 'maskat', 23.5880, 58.3829)]),
  Country('Malezya', [City('Kuala Lumpur', 'kuala-lumpur', 3.1390, 101.6869)]),
  Country('Endonezya', [City('Cakarta', 'cakarta', -6.2088, 106.8456), City('Surabaya', 'surabaya', -7.2575, 112.7521), City('Bandung', 'bandung', -6.9147, 107.6098)]),
  Country('Pakistan', [City('İslamabad', 'islamabad', 33.6844, 73.0479), City('Karaçi', 'karaci', 24.8607, 67.0011), City('Lahor', 'lahor', 31.5497, 74.3436)]),
  Country('Bangladeş', [City('Dakka', 'dakka', 23.8103, 90.4125)]),
  Country('İran', [City('Tahran', 'tahran', 35.6892, 51.3890), City('Meşhed', 'meshed', 36.2605, 59.6168), City('İsfahan', 'isfahan', 32.6539, 51.6660), City('Kum', 'kum', 34.6416, 50.8746)]),
  Country('Irak', [City('Bağdat', 'bagdat', 33.3152, 44.3661), City('Necef', 'necef', 31.9961, 44.3146), City('Kerbela', 'kerbela', 32.6025, 44.0200)]),
  Country('Suriye', [City('Şam', 'sam', 33.5138, 36.2765), City('Halep', 'halep', 36.2021, 37.1343)]),
  Country('Lübnan', [City('Beyrut', 'beyrut', 33.8938, 35.5018)]),
  Country('Filistin', [City('Kudüs', 'kudus', 31.7683, 35.2137), City('Gazze', 'gazze', 31.5000, 34.4667)]),
  Country('Yemen', [City('San\'a', 'sana', 15.3694, 44.1910), City('Aden', 'aden', 12.8000, 45.0333)]),
  Country('Sudan', [City('Hartum', 'hartum', 15.5007, 32.5599)]),
  Country('Somali', [City('Mogadişu', 'mogadisu', 2.0469, 45.3182)]),
  Country('Bosna Hersek', [City('Saraybosna', 'saraybosna', 43.8563, 18.4131)]),
  Country('Arnavutluk', [City('Tiran', 'tiran', 41.3275, 19.8187)]),
  Country('Kosova', [City('Priştine', 'pristine', 42.6629, 21.1655)]),
  Country('Azerbaycan', [City('Bakü', 'baku', 40.4093, 49.8671), City('Gence', 'gence', 40.6828, 46.3606)]),
  Country('Kazakistan', [City('Astana', 'astana', 51.1694, 71.4491), City('Almatı', 'almata', 43.2220, 76.8512)]),
  Country('Özbekistan', [City('Taşkent', 'taskent', 41.2995, 69.2401), City('Semerkand', 'semerkand', 39.6270, 66.9750), City('Buhara', 'buhara', 39.7686, 64.4200)]),
  Country('Türkmenistan', [City('Aşkabat', 'askabat', 37.9601, 58.3794)]),
  Country('Kırgızistan', [City('Bişkek', 'biskek', 42.8746, 74.5698)]),
  Country('Afganistan', [City('Kabil', 'kabil', 34.5553, 69.2075)]),
];

// ═══════════════════════════════════════════════════════════════
// SERVİS
// ═══════════════════════════════════════════════════════════════

class LocationService {
  LocationService._();

  static const _keyCountry = 'loc_country';
  static const _keyCity = 'loc_city';
  static const _keyDistrict = 'loc_district';
  static const _keyLat = 'loc_lat';
  static const _keyLng = 'loc_lng';

  // ─── GPS ───
  /// Cihazın GPS konumuna en yakın şehri/ilçeyi bulur.
  static Future<({String country, String city, String? district, double lat, double lng})?>
      fromGps() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.low, timeLimit: Duration(seconds: 5)),
      );
      return _findNearest(pos.latitude, pos.longitude);
    } catch (_) {
      return null;
    }
  }

  /// GPS konumuna en yakın şehri ve ilçeyi bulur.
  static ({String country, String city, String? district, double lat, double lng})
      _findNearest(double lat, double lng) {
    double bestDist = double.infinity;
    String bestCountry = 'Türkiye';
    City bestCity = countries.first.cities.first;
    District? bestDistrict;

    for (final c in countries) {
      for (final city in c.cities) {
        final cityDist = _dist(lat, lng, city.lat, city.lng);
        if (cityDist < bestDist) {
          bestDist = cityDist;
          bestCountry = c.name;
          bestCity = city;
          bestDistrict = null;
          // En yakın ilçeyi de bul
          double bestDistDist = double.infinity;
          for (final d in city.districts) {
            final dd = _dist(lat, lng, d.lat, d.lng);
            if (dd < bestDistDist) { bestDistDist = dd; bestDistrict = d; }
          }
        }
      }
    }
    return (country: bestCountry, city: bestCity.name, district: bestDistrict?.name, lat: bestCity.lat, lng: bestCity.lng);
  }

  static double _dist(double lat1, double lng1, double lat2, double lng2) {
    final dLat = (lat2 - lat1) * (pi / 180);
    final dLng = (lng2 - lng1) * (pi / 180);
    final a = sin(dLat / 2) * sin(dLat / 2) + cos(lat1 * pi / 180) * cos(lat2 * pi / 180) * sin(dLng / 2) * sin(dLng / 2);
    return 6371 * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  // ─── KAYDETME ───
  static Future<void> saveLocation({
    required String country,
    required String city,
    String? district,
    required double lat,
    required double lng,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCountry, country);
    await prefs.setString(_keyCity, city);
    if (district != null) await prefs.setString(_keyDistrict, district);
    await prefs.setDouble(_keyLat, lat);
    await prefs.setDouble(_keyLng, lng);
  }

  // ─── YÜKLEME ───
  static Future<({String country, String city, String? district, double lat, double lng})>
      loadLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final country = prefs.getString(_keyCountry) ?? 'Türkiye';
    final city = prefs.getString(_keyCity) ?? 'İstanbul';
    final district = prefs.getString(_keyDistrict);
    final lat = prefs.getDouble(_keyLat) ?? 41.0082;
    final lng = prefs.getDouble(_keyLng) ?? 28.9784;
    return (country: country, city: city, district: district, lat: lat, lng: lng);
  }

  /// Uygulama ilk açılışta GPS dener, yoksa kayıtlı konumu yükler.
  static Future<({String country, String city, String? district, double lat, double lng})>
      getOrDetect() async {
    final gps = await fromGps();
    if (gps != null) {
      await saveLocation(country: gps.country, city: gps.city, district: gps.district, lat: gps.lat, lng: gps.lng);
      return gps;
    }
    return loadLocation();
  }
}
