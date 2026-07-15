import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../data/services/location_service.dart';
import '../data/services/prayer_times_service.dart';
import '../widgets/ad_banner.dart';
import '../widgets/app_drawer.dart';
import 'prayer_times_screen.dart';
import 'quran_screen.dart';
import 'tafsir_chat_screen.dart';
import 'qibla_compass_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PrayerDay? _prayerDay;
  String _countdownLabel = '';
  String _countdownTime = '';
  String _cityDisplay = 'İstanbul, Türkiye';
  Timer? _timer;
  bool _loading = true;

  double _lat = 41.0082;
  double _lng = 28.9784;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _initLocation() async {
    final loc = await LocationService.getOrDetect();
    final districtPart = loc.district != null ? ', ${loc.district}' : '';
    setState(() {
      _lat = loc.lat; _lng = loc.lng;
      _cityDisplay = '${loc.city}$districtPart, ${loc.country}';
    });
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final day = await PrayerTimesService.fetch(lat: _lat, lng: _lng);
      if (!mounted) return;
      setState(() { _prayerDay = day; _loading = false; });
      _startCountdown(day);
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _startCountdown(PrayerDay day) {
    _timer?.cancel();
    _tick(day);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick(day));
  }

  void _tick(PrayerDay day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final times = [
      ('İmsak', day.imsak),
      ('Güneş', day.gunes),
      ('Öğle', day.ogle),
      ('İkindi', day.ikindi),
      ('Akşam', day.aksam),
      ('Yatsı', day.yatsi),
    ];

    String? nextName; int nextSec = 0;
    for (final t in times) {
      final p = t.$2.split(':'); final td = DateTime(today.year, today.month, today.day, int.parse(p[0]), int.parse(p[1]));
      final d = td.difference(now).inSeconds;
      if (d > 0) { nextName = t.$1; nextSec = d; break; }
    }
    if (nextName == null) {
      final fp = day.imsak.split(':'); final tf = DateTime(today.year, today.month, today.day + 1, int.parse(fp[0]), int.parse(fp[1]));
      nextName = 'İmsak (yarın)'; nextSec = tf.difference(now).inSeconds;
    }

    final h = nextSec ~/ 3600; final m = (nextSec % 3600) ~/ 60; final s = (nextSec % 60).toString().padLeft(2, '0');

    setState(() {
      _countdownLabel = '$nextName Vaktine Kalan Süre';
      _countdownTime = '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:$s';
    });
  }

  @override
  Widget build(BuildContext context) {
    final day = _prayerDay;
    return Scaffold(
      backgroundColor: AppColors.background,
      endDrawer: const AppDrawer(),
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Karşılama
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Selamun Aleyküm,', style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.6), fontSize: 15, fontWeight: FontWeight.w400)),
                        const SizedBox(height: 6),
                        Text(
                          day != null ? day.hijriDate : 'Yükleniyor...',
                          style: const TextStyle(color: AppColors.gold, fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                        ),
                      ],
                    ),
                    Builder(
                      builder: (context) => IconButton(
                        icon: const Icon(Icons.menu_rounded, color: AppColors.gold, size: 30),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => Scaffold.of(context).openEndDrawer(),
                      ),
                    ),
                  ],
                ),

                const Spacer(flex: 3),

                // ═══ NAMAZ VAKİTLERİ KARTI (DİNAMİK) ═══
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrayerTimesScreen())),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24.0),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppColors.gold.withValues(alpha: 0.15), width: 1),
                          ),
                          child: _loading
                              ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
                              : day == null
                                  ? Column(children: [
                                      Icon(Icons.cloud_off_rounded, color: AppColors.gold.withValues(alpha: 0.4), size: 32),
                                      const SizedBox(height: 8),
                                      Text('Vakitler alınamadı', style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.5), fontSize: 13)),
                                    ])
                                  : Column(children: [
                                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                        const Icon(Icons.location_on_rounded, color: AppColors.gold, size: 16),
                                        const SizedBox(width: 6),
                                        Text(_cityDisplay, style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.8), fontSize: 14, fontWeight: FontWeight.w500)),
                                      ]),
                                      const SizedBox(height: 20),
                                      Text(_countdownLabel, style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.5), fontSize: 13)),
                                      const SizedBox(height: 12),
                                      Text(_countdownTime, style: const TextStyle(color: AppColors.textLight, fontSize: 56, fontWeight: FontWeight.w200, letterSpacing: 2)),
                                      const SizedBox(height: 28),
                                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                        Expanded(child: _mini('İmsak', day.imsak, next: _nextKey(day) == 'İmsak')),
                                        Expanded(child: _mini('Güneş', day.gunes, next: _nextKey(day) == 'Güneş')),
                                        Expanded(child: _mini('Öğle', day.ogle, next: _nextKey(day) == 'Öğle')),
                                        Expanded(child: _mini('İkindi', day.ikindi, next: _nextKey(day) == 'İkindi')),
                                        Expanded(child: _mini('Akşam', day.aksam, next: _nextKey(day) == 'Akşam')),
                                        Expanded(child: _mini('Yatsı', day.yatsi, next: _nextKey(day) == 'Yatsı')),
                                      ]),
                                    ]),
                        ),
                      ),
                    ),
                  ),
                ),

                const Spacer(flex: 1),

                // Reklam Banner
                const AdBanner(),
                const Spacer(flex: 1),
                // Günün Ayeti
                Expanded(
                  flex: 12,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.gold.withValues(alpha: 0.1), width: 1),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Stack(
                        children: [
                          Positioned.fill(child: Image.asset('assets/kabe.png', fit: BoxFit.cover)),
                          Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.55))),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.format_quote_rounded, color: AppColors.gold, size: 28),
                                SizedBox(height: 12),
                                Text('"Şüphesiz güçlükle beraber bir kolaylık vardır."', style: TextStyle(color: AppColors.textLight, fontSize: 16, height: 1.5, fontWeight: FontWeight.w400)),
                                SizedBox(height: 12),
                                Align(alignment: Alignment.centerRight, child: Text('İnşirah Suresi, 5', style: TextStyle(color: AppColors.gold, fontSize: 13, fontWeight: FontWeight.w500))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const Spacer(flex: 2),

                // Çiftli Menü
                Row(children: [
                  Expanded(child: _buildActionCard(Icons.menu_book_rounded, 'Kuran-ı Kerim', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuranScreen())))),
                  const SizedBox(width: 16),
                  Expanded(child: _buildActionCard(Icons.explore_rounded, 'Kıble Pusulası', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QiblaCompassScreen())))),
                ]),

                const Spacer(flex: 2),

                // AI Tefsir Butonu
                Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TafsirChatScreen())),
                    child: Ink(
                      decoration: const BoxDecoration(gradient: AppColors.blackGoldButtonGradient, borderRadius: BorderRadius.all(Radius.circular(24))),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 24),
                        child: Row(children: const [
                          Icon(Icons.auto_awesome, color: AppColors.textLight, size: 32),
                          SizedBox(width: 20),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('Yapay Zeka ile Tefsir', style: TextStyle(color: AppColors.textLight, fontSize: 18, fontWeight: FontWeight.w700)),
                            SizedBox(height: 4),
                            Text('Kuran\'a dair sorularını sor', style: TextStyle(color: AppColors.textLight, fontSize: 13, fontWeight: FontWeight.w500)),
                          ])),
                          Icon(Icons.arrow_forward_rounded, color: AppColors.textDark, size: 28),
                        ]),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Bulunduğumuz gün için sıradaki vaktin anahtarını döndürür.
  String? _nextKey(PrayerDay day) {
    final now = DateTime.now(); final today = DateTime(now.year, now.month, now.day);
    for (final t in [('İmsak', day.imsak), ('Güneş', day.gunes), ('Öğle', day.ogle), ('İkindi', day.ikindi), ('Akşam', day.aksam), ('Yatsı', day.yatsi)]) {
      final p = t.$2.split(':'); final td = DateTime(today.year, today.month, today.day, int.parse(p[0]), int.parse(p[1]));
      if (td.isAfter(now)) return t.$1;
    }
    return null;
  }

  Widget _mini(String name, String time, {bool next = false}) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      FittedBox(fit: BoxFit.scaleDown, child: Text(name, style: TextStyle(color: next ? AppColors.gold : AppColors.textLight.withValues(alpha: 0.5), fontSize: 12, fontWeight: next ? FontWeight.w600 : FontWeight.w400))),
      const SizedBox(height: 6),
      FittedBox(fit: BoxFit.scaleDown, child: Text(time, style: TextStyle(color: next ? AppColors.gold : AppColors.textLight, fontSize: 15, fontWeight: next ? FontWeight.bold : FontWeight.w500))),
    ]);
  }

  Widget _buildActionCard(IconData icon, String title, {VoidCallback? onTap}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
        child: Container(
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.04), borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.gold.withValues(alpha: 0.15), width: 1)),
          child: Material(color: Colors.transparent, child: InkWell(borderRadius: BorderRadius.circular(24), onTap: onTap,
            child: Padding(padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0), child: Column(children: [
              Icon(icon, color: AppColors.gold, size: 32), const SizedBox(height: 16),
              Text(title, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textLight, fontSize: 15, fontWeight: FontWeight.w600)),
            ])),
          )),
        ),
      ),
    );
  }
}
