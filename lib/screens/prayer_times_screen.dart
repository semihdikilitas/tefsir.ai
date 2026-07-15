import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../data/services/prayer_times_service.dart';
import '../data/services/ad_service.dart';
import '../data/services/location_service.dart';
import '../data/services/remote_asset_service.dart';
// City, District, Country, countries LocationService'ten geliyor.
class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  String _countryName = 'Türkiye';
  City _city = countries.firstWhere((c) => c.name == 'Türkiye').cities.first;
  District? _district;
  String? _cityImagePath;
  bool _imageLoaded = false;

  DateTime _selectedDate = DateTime.now();
  PrayerDay? _prayerDay;
  bool _loading = false;
  String? _error;

  Timer? _countdownTimer;
  String _countdownLabel = '';
  String _countdownTime = '';

  @override
  void initState() {
    super.initState();
    _initLocation();
    // TODO: Premium kontrolü — premium kullanıcılara gösterme
    // if (!isPremium) { ... }
    WidgetsBinding.instance.addPostFrameCallback((_) => InterstitialAd.show(context, daily: true));
  }

  Future<void> _initLocation() async {
    final loc = await LocationService.loadLocation();
    final country = countries.firstWhere((c) => c.name == loc.country, orElse: () => countries.first);
    final city = country.cities.firstWhere((c) => c.name == loc.city, orElse: () => country.cities.first);
    District? district;
    if (loc.district != null) {
      final match = city.districts.where((d) => d.name == loc.district);
      district = match.isNotEmpty ? match.first : (city.districts.isNotEmpty ? city.districts.first : null);
    }
    setState(() {
      _countryName = country.name;
      _city = city;
      _district = district;
    });
    _loadCityImage();
    _fetchPrayerTimes();
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadCityImage() async {
    final remote = await RemoteAssetService.cityBackground(_city.slug);
    if (!mounted) return;
    if (remote != null && await File(remote).exists()) {
      setState(() { _cityImagePath = remote; _imageLoaded = true; });
    } else {
      setState(() { _cityImagePath = 'assets/istanbul.png'; _imageLoaded = true; });
    }
  }

  Future<void> _fetchPrayerTimes() async {
    setState(() { _loading = true; _error = null; });
    try {
      final lat = _district?.lat ?? _city.lat;
      final lng = _district?.lng ?? _city.lng;
      final day = await PrayerTimesService.fetch(lat: lat, lng: lng, date: _selectedDate);
      if (!mounted) return;
      setState(() { _prayerDay = day; _loading = false; });
      _updateCountdown(day);
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = 'Vakitler alınamadı.\nİnternet bağlantınızı kontrol edin.'; _loading = false; });
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_prayerDay != null) _updateCountdown(_prayerDay!);
    });
  }

  void _updateCountdown(PrayerDay day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final times = <MapEntry<String, String>>[
      MapEntry('İmsak', day.imsak),
      MapEntry('Güneş', day.gunes),
      MapEntry('Öğle', day.ogle),
      MapEntry('İkindi', day.ikindi),
      MapEntry('Akşam', day.aksam),
      MapEntry('Yatsı', day.yatsi),
    ];

    // Bugünün geçmiş/gelecek vakitlerini tara
    String? nextName;
    int nextSeconds = 0;

    for (final t in times) {
      final parts = t.value.split(':');
      final timeDate = DateTime(today.year, today.month, today.day, int.parse(parts[0]), int.parse(parts[1]));
      final diff = timeDate.difference(now).inSeconds;
      if (diff > 0) {
        nextName = t.key;
        nextSeconds = diff;
        break;
      }
    }

    if (nextName == null) {
      // Tüm vakitler geçmişse → yarının imsakı
      final fajrParts = day.imsak.split(':');
      final tomorrowFajr = DateTime(today.year, today.month, today.day + 1, int.parse(fajrParts[0]), int.parse(fajrParts[1]));
      nextName = 'İmsak (yarın)';
      nextSeconds = tomorrowFajr.difference(now).inSeconds;
    }

    final h = nextSeconds ~/ 3600;
    final m = (nextSeconds % 3600) ~/ 60;
    final s = (nextSeconds % 60).toString().padLeft(2, '0');

    setState(() {
      _countdownLabel = '$nextName Vaktine Kalan Süre';
      _countdownTime = '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:$s';
    });
  }

  void _onCitySelected(String country, City city, {District? district}) {
    Navigator.pop(context);
    setState(() {
      _countryName = country;
      _city = city;
      _district = district;
      _prayerDay = null;
      _imageLoaded = false;
    });
    LocationService.saveLocation(
      country: country, city: city.name, district: district?.name, lat: city.lat, lng: city.lng,
    );
    _loadCityImage();
    _fetchPrayerTimes();
  }

  void _showCityPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _CountryCityPicker(
        selectedCountry: _countryName,
        selectedCity: _city.name,
        selectedDistrict: _district?.name,
        onSelected: _onCitySelected,
      ),
    );
  }

  Future<void> _showDatePickerDialog() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2028),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: AppColors.gold, onPrimary: AppColors.textDark, surface: AppColors.surfaceCard, onSurface: AppColors.textLight),
          dialogTheme: const DialogThemeData(backgroundColor: AppColors.surfaceCard),
        ),
        child: child!,
      ),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      _fetchPrayerTimes();
    }
  }

  // Bugün mü?
  bool _isToday(DateTime d) =>
      d.day == DateTime.now().day && d.month == DateTime.now().month && d.year == DateTime.now().year;

  List<DateTime> get _weekDays {
    final monday = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
    return List.generate(7, (i) => monday.add(Duration(days: i)));
  }

  static const _dayNames = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
  static const _months = ['Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran', 'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'];
  static const _weekDaysTR = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];

  String _fmt(DateTime d) {
    const m = ['Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'];
    return '${d.day} ${m[d.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final day = _prayerDay;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          if (_imageLoaded && _cityImagePath != null)
            Positioned.fill(
              child: _cityImagePath!.startsWith('assets/')
                  ? Image.asset(_cityImagePath!, fit: BoxFit.cover, errorBuilder: (_, _, _) => _buildFallbackBg())
                  : Image.file(File(_cityImagePath!), fit: BoxFit.cover, errorBuilder: (_, _, _) => _buildFallbackBg()),
            )
          else
            _buildFallbackBg(),

          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Colors.black.withValues(alpha: 0.65), Colors.black.withValues(alpha: 0.80), Colors.black.withValues(alpha: 0.92)],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ÜST BAR
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: Row(
                    children: [
                      IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.gold), onPressed: () => Navigator.pop(context)),
                      const Spacer(),
                      IconButton(icon: const Icon(Icons.calendar_today_rounded, color: AppColors.gold, size: 22), tooltip: 'Tarih seç', onPressed: _showDatePickerDialog),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ŞEHİR
                GestureDetector(
                  onTap: _showCityPicker,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on_rounded, color: AppColors.gold, size: 22),
                      const SizedBox(width: 8),
                      Text('${_district != null ? "${_district!.name}, " : ""}${_city.name}, $_countryName', style: const TextStyle(color: AppColors.textLight, fontSize: 20, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.gold.withValues(alpha: 0.25))),
                        child: const Text('Değiştir', style: TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // GERİ SAYIM
                if (_loading)
                  const Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: AppColors.gold))
                else if (_error != null)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(children: [
                      Icon(Icons.cloud_off_rounded, color: AppColors.gold.withValues(alpha: 0.5), size: 40),
                      const SizedBox(height: 12),
                      Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.6), fontSize: 14)),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: _fetchPrayerTimes,
                        icon: const Icon(Icons.refresh_rounded, color: AppColors.gold, size: 18),
                        label: const Text('Tekrar Dene', style: TextStyle(color: AppColors.gold)),
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.gold)),
                      ),
                    ]),
                  )
                else ...[
                  Text(_countdownLabel, style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.6), fontSize: 15)),
                  const SizedBox(height: 12),
                  Text(_countdownTime, style: const TextStyle(color: AppColors.textLight, fontSize: 64, fontWeight: FontWeight.w200, letterSpacing: 3)),
                  const SizedBox(height: 8),
                  if (day != null)
                    Text('${_selectedDate.day} ${_months[_selectedDate.month - 1]} ${_selectedDate.year} ${_weekDaysTR[_selectedDate.weekday - 1]} · ${day.hijriDate}',
                        style: TextStyle(color: AppColors.gold.withValues(alpha: 0.5), fontSize: 13)),
                ],

                const SizedBox(height: 20),

                // TARİH ÇİPLERİ
                SizedBox(
                  height: 78,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: _weekDays.map((d) {
                      final sel = d.day == _selectedDate.day && d.month == _selectedDate.month && d.year == _selectedDate.year;
                      return _chip(_isToday(d) ? 'Bugün' : _dayNames[d.weekday - 1], _fmt(d), sel, () { setState(() => _selectedDate = d); _fetchPrayerTimes(); });
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 16),

                // VAKİT LİSTESİ
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.45), borderRadius: const BorderRadius.vertical(top: Radius.circular(28)), border: Border.all(color: AppColors.gold.withValues(alpha: 0.12))),
                    child: day != null
                        ? ListView(
                            physics: const BouncingScrollPhysics(),
                            children: [
                              _row('İmsak', day.imsak, Icons.nights_stay_rounded),
                              _row('Güneş', day.gunes, Icons.wb_twilight_rounded),
                              _row('Kuşluk', day.kusluk, Icons.flare_rounded, nafile: true),
                              _row('Öğle', day.ogle, Icons.wb_sunny_rounded),
                              _row('İkindi', day.ikindi, Icons.brightness_high_rounded),
                              _row('Akşam', day.aksam, Icons.brightness_4_rounded),
                              _row('Yatsı', day.yatsi, Icons.bedtime_rounded),
                              _row('Teheccüd', day.teheccud, Icons.mode_night_rounded, nafile: true),
                            ],
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackBg() => Container(decoration: const BoxDecoration(gradient: AppColors.backgroundGradient));

  Widget _chip(String day, String date, bool sel, VoidCallback? onTap) {
    return Container(
      margin: const EdgeInsets.only(right: 10), width: 68,
      decoration: BoxDecoration(color: sel ? AppColors.gold : Colors.black.withValues(alpha: 0.35), borderRadius: BorderRadius.circular(18), border: Border.all(color: sel ? AppColors.gold : AppColors.gold.withValues(alpha: 0.15), width: sel ? 1.5 : 1)),
      child: Material(color: Colors.transparent, borderRadius: BorderRadius.circular(18),
        child: InkWell(borderRadius: BorderRadius.circular(18), onTap: onTap,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(day, style: TextStyle(color: sel ? AppColors.textDark : AppColors.textLight.withValues(alpha: 0.6), fontSize: 12, fontWeight: sel ? FontWeight.w700 : FontWeight.w500)),
            const SizedBox(height: 4),
            Text(date, style: TextStyle(color: sel ? AppColors.textDark : AppColors.textLight, fontSize: 14, fontWeight: sel ? FontWeight.w700 : FontWeight.w500)),
          ]),
        ),
      ),
    );
  }

  Widget _row(String name, String time, IconData icon, {bool nafile = false}) {
    // Bugünkü saate göre geçmiş/gelecek vurgusu (sadece bugün için)
    final isToday = _isToday(_selectedDate);
    bool isPast = false, isNext = false;
    if (isToday && _prayerDay != null) {
      final now = DateTime.now();
      final parts = time.split(':');
      final timeDate = DateTime(now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
      isPast = timeDate.isBefore(now);
      // Sıradaki vakit = ilk geçmemiş vakit
      final allTimes = <MapEntry<String, String>>[
        MapEntry('İmsak', _prayerDay!.imsak), MapEntry('Güneş', _prayerDay!.gunes), MapEntry('Öğle', _prayerDay!.ogle), MapEntry('İkindi', _prayerDay!.ikindi), MapEntry('Akşam', _prayerDay!.aksam), MapEntry('Yatsı', _prayerDay!.yatsi),
      ];
      for (final t in allTimes) {
        final p = t.value.split(':');
        final td = DateTime(now.year, now.month, now.day, int.parse(p[0]), int.parse(p[1]));
        if (td.isAfter(now)) {
          isNext = t.key == name;
          break;
        }
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(color: isNext ? AppColors.gold.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.025), borderRadius: BorderRadius.circular(16), border: Border.all(color: isNext ? AppColors.gold.withValues(alpha: 0.35) : AppColors.gold.withValues(alpha: 0.08))),
      child: Row(children: [
        Opacity(opacity: isPast ? 0.3 : 1.0, child: Icon(icon, color: isNext ? AppColors.gold : AppColors.gold.withValues(alpha: 0.7), size: 26)),
        const SizedBox(width: 18),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Opacity(opacity: isPast ? 0.35 : 1.0, child: Text(name, style: TextStyle(color: isNext ? AppColors.gold : (nafile ? AppColors.textLight.withValues(alpha: 0.6) : AppColors.textLight), fontSize: 17, fontWeight: isNext ? FontWeight.w700 : FontWeight.w500))),
          if (nafile) Text('Nafile', style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.3), fontSize: 11)),
        ]),
        const Spacer(),
        if (isNext) Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3), decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)), child: const Text('Sıradaki', style: TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.w700))),
        const SizedBox(width: 12),
        Opacity(opacity: isPast ? 0.3 : 1.0, child: Text(time, style: TextStyle(color: isNext ? AppColors.gold : AppColors.textLight, fontSize: 20, fontWeight: isNext ? FontWeight.w800 : FontWeight.w600))),
      ]),
    );
  }
}

// ─── ÜLKE/ŞEHİR SEÇİCİ (değişmedi) ───

class _CountryCityPicker extends StatefulWidget {
  final String selectedCountry;
  final String selectedCity;
  final String? selectedDistrict;
  final void Function(String country, City city, {District? district}) onSelected;
  const _CountryCityPicker({required this.selectedCountry, required this.selectedCity, this.selectedDistrict, required this.onSelected});
  @override
  State<_CountryCityPicker> createState() => _CountryCityPickerState();
}

class _CountryCityPickerState extends State<_CountryCityPicker> {
  String? _activeCountry;
  City? _activeCity;
  final _searchCtrl = TextEditingController();
  String _q = '';

  @override void initState() { super.initState(); _searchCtrl.addListener(() => setState(() => _q = _searchCtrl.text.trim().toLowerCase())); }
  @override void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (_activeCity != null) return _districtList(_activeCity!);
    if (_activeCountry != null) return _cityList(_activeCountry!);
    return _countryList();
  }

  List<Country> get _sorted {
    final list = List<Country>.from(countries);
    list.sort((a, b) {
      if (a.name == 'Türkiye') return -1;
      if (b.name == 'Türkiye') return 1;
      return a.name.compareTo(b.name);
    });
    return list;
  }

  Country _findCountry(String name) => countries.firstWhere((c) => c.name == name, orElse: () => countries.first);

  Widget _countryList() {
    return Container(
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(28)), border: Border.all(color: AppColors.gold.withValues(alpha: 0.15))),
      child: SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, margin: const EdgeInsets.only(top: 12, bottom: 16), decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
          const Text('Ülke Seç', style: TextStyle(color: AppColors.gold, fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          SizedBox(height: 480,
            child: ListView.separated(physics: const BouncingScrollPhysics(), padding: const EdgeInsets.fromLTRB(16, 0, 16, 24), itemCount: _sorted.length,
              separatorBuilder: (_, _) => Divider(color: AppColors.gold.withValues(alpha: 0.08), height: 1),
              itemBuilder: (context, index) {
                final c = _sorted[index];
                final sel = c.name == widget.selectedCountry;
                return ListTile(
                  leading: Icon(sel ? Icons.public_rounded : Icons.public_outlined, color: sel ? AppColors.gold : AppColors.gold.withValues(alpha: 0.4)),
                  title: Text(c.name, style: TextStyle(color: sel ? AppColors.gold : AppColors.textLight, fontWeight: sel ? FontWeight.w700 : FontWeight.w500)),
                  trailing: Icon(Icons.chevron_right_rounded, color: AppColors.gold.withValues(alpha: 0.5)),
                  onTap: () => setState(() => _activeCountry = c.name),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }

  Widget _cityList(String countryName) {
    final country = _findCountry(countryName);
    return Container(
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(28)), border: Border.all(color: AppColors.gold.withValues(alpha: 0.15))),
      child: SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, margin: const EdgeInsets.only(top: 12, bottom: 8), decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Row(children: [
            IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.gold, size: 20), onPressed: () => setState(() => _activeCountry = null)),
            Text('$countryName — Şehir', style: const TextStyle(color: AppColors.gold, fontSize: 16, fontWeight: FontWeight.w700)),
          ])),
          // Arama
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchCtrl, style: const TextStyle(color: AppColors.textLight, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Şehir ara...', hintStyle: TextStyle(color: AppColors.textLight.withValues(alpha: 0.3), fontSize: 14),
                prefixIcon: Icon(Icons.search_rounded, color: AppColors.gold.withValues(alpha: 0.5), size: 20),
                suffixIcon: _q.isNotEmpty ? IconButton(icon: Icon(Icons.close_rounded, color: AppColors.textLight.withValues(alpha: 0.4), size: 16), onPressed: () => _searchCtrl.clear()) : null,
                filled: true, fillColor: Colors.white.withValues(alpha: 0.03),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(height: 400,
            child: ListView.separated(physics: const BouncingScrollPhysics(), padding: const EdgeInsets.fromLTRB(16, 0, 16, 24), itemCount: country.cities.where((c) => _q.isEmpty || c.name.toLowerCase().contains(_q)).length,
              separatorBuilder: (_, _) => Divider(color: AppColors.gold.withValues(alpha: 0.08), height: 1),
              itemBuilder: (context, index) {
                final filtered = country.cities.where((c) => _q.isEmpty || c.name.toLowerCase().contains(_q)).toList()
                  ..sort((a, b) {
                    const pinned = ['İstanbul', 'Ankara', 'İzmir'];
                    final aPinned = pinned.contains(a.name);
                    final bPinned = pinned.contains(b.name);
                    if (aPinned && bPinned) return pinned.indexOf(a.name).compareTo(pinned.indexOf(b.name));
                    if (aPinned) return -1;
                    if (bPinned) return 1;
                    return a.name.compareTo(b.name);
                  });
                final city = filtered[index];
                final sel = city.name == widget.selectedCity;
                final hasDistricts = city.districts.isNotEmpty;
                return ListTile(
                  leading: Icon(sel ? Icons.location_on_rounded : Icons.location_on_outlined, color: sel ? AppColors.gold : AppColors.gold.withValues(alpha: 0.4)),
                  title: Text(city.name, style: TextStyle(color: sel ? AppColors.gold : AppColors.textLight, fontWeight: sel ? FontWeight.w700 : FontWeight.w500)),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    if (sel) const Padding(padding: EdgeInsets.only(right: 4), child: Icon(Icons.check_rounded, color: AppColors.gold, size: 20)),
                    Icon(hasDistricts ? Icons.chevron_right_rounded : Icons.check_rounded, color: AppColors.gold.withValues(alpha: hasDistricts ? 0.5 : 0), size: 20),
                  ]),
                  onTap: () {
                    if (hasDistricts) {
                      setState(() { _activeCity = city; _activeCountry = countryName; });
                    } else {
                      widget.onSelected(countryName, city);
                    }
                  },
                );
              },
            ),
          ),
        ]),
      ),
    );
  }

  Widget _districtList(City city) {
    final countryName = _activeCountry!;
    return Container(
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(28)), border: Border.all(color: AppColors.gold.withValues(alpha: 0.15))),
      child: SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, margin: const EdgeInsets.only(top: 12, bottom: 8), decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Row(children: [
            IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.gold, size: 20), onPressed: () => setState(() => _activeCity = null)),
            Text('${city.name} — İlçe', style: const TextStyle(color: AppColors.gold, fontSize: 16, fontWeight: FontWeight.w700)),
          ])),
          const SizedBox(height: 8),
          // "Tüm Şehir" seçeneği
          ListTile(
            leading: Icon(widget.selectedDistrict == null ? Icons.check_circle_rounded : Icons.circle_outlined, color: AppColors.gold.withValues(alpha: widget.selectedDistrict == null ? 1 : 0.4), size: 22),
            title: Text('Tüm ${city.name}', style: TextStyle(color: widget.selectedDistrict == null ? AppColors.gold : AppColors.textLight)),
            onTap: () => widget.onSelected(countryName, city),
          ),
          Divider(color: AppColors.gold.withValues(alpha: 0.08)),
          SizedBox(height: 400,
            child: ListView.separated(physics: const BouncingScrollPhysics(), padding: const EdgeInsets.fromLTRB(16, 0, 16, 24), itemCount: city.districts.length,
              separatorBuilder: (_, _) => Divider(color: AppColors.gold.withValues(alpha: 0.08), height: 1),
              itemBuilder: (context, index) {
                final sorted = List<District>.from(city.districts)..sort((a, b) {
                  const pinned = ['Merkez', 'Fatih', 'Çankaya', 'Konak', 'Osmangazi', 'Muratpaşa', 'Seyhan', 'Şahinbey', 'Melikgazi', 'Selçuklu', 'İlkadım', 'Ortahisar'];
                  final aPinned = pinned.contains(a.name);
                  final bPinned = pinned.contains(b.name);
                  if (aPinned && bPinned) return pinned.indexOf(a.name).compareTo(pinned.indexOf(b.name));
                  if (aPinned) return -1;
                  if (bPinned) return 1;
                  return a.name.compareTo(b.name);
                });
                final d = sorted[index];
                final sel = d.name == widget.selectedDistrict;
                return ListTile(
                  leading: Icon(sel ? Icons.location_on_rounded : Icons.location_on_outlined, color: sel ? AppColors.gold : AppColors.gold.withValues(alpha: 0.4), size: 20),
                  title: Text(d.name, style: TextStyle(color: sel ? AppColors.gold : AppColors.textLight, fontWeight: sel ? FontWeight.w700 : FontWeight.w500, fontSize: 15)),
                  trailing: sel ? const Icon(Icons.check_rounded, color: AppColors.gold, size: 20) : null,
                  onTap: () => widget.onSelected(countryName, city, district: d),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}
