import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../data/models/daily_worship_record.dart';
import '../data/repositories/worship_repository.dart';

const _prayerKeys = ['İmsak (Sabah)', 'Öğle', 'İkindi', 'Akşam', 'Yatsı'];
const _weekdayLabels = ['P', 'S', 'Ç', 'P', 'C', 'C', 'P'];
const _monthNames = ['Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran', 'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'];

class WorshipTrackerScreen extends StatefulWidget {
  const WorshipTrackerScreen({super.key});
  @override State<WorshipTrackerScreen> createState() => _WorshipTrackerScreenState();
}

class _WorshipTrackerScreenState extends State<WorshipTrackerScreen> with SingleTickerProviderStateMixin {
  final _repo = WorshipRepository();
  late final TabController _tabController;

  bool _isLoading = true;
  late DailyWorshipRecord _today;
  int _streak = 0, _monthTotal = 0;
  int _analyticsTab = 0, _timeOffset = 0;
  bool _isChartLoading = true;
  List<DailyWorshipRecord> _chartRecords = [];

  // Kaza verileri
  Map<String, int> _kazaData = {};
  int _totalRecordedDays = 0;
  int _kazaPeriod = 0; // 0: hafta, 1: ay, 2: yil, 3: tum zamanlar
  int _kazaTimeOffset = 0;
  String _kazaDateRange = '';

  @override void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTodayAndStats();
    _loadChartData();
    _loadKaza();
  }

  @override void dispose() { _tabController.dispose(); super.dispose(); }

  bool _getPrayerValue(DailyWorshipRecord r, String key) {
    switch (key) { case 'İmsak (Sabah)': return r.imsak; case 'Öğle': return r.ogle; case 'İkindi': return r.ikindi; case 'Akşam': return r.aksam; case 'Yatsı': return r.yatsi; default: return false; }
  }

  DailyWorshipRecord _copyWithPrayer(DailyWorshipRecord r, String key, bool v) {
    switch (key) { case 'İmsak (Sabah)': return r.copyWith(imsak: v); case 'Öğle': return r.copyWith(ogle: v); case 'İkindi': return r.copyWith(ikindi: v); case 'Akşam': return r.copyWith(aksam: v); case 'Yatsı': return r.copyWith(yatsi: v); default: return r; }
  }

  Future<void> _loadTodayAndStats() async {
    final now = DateTime.now();
    final record = await _repo.getRecordForDate(now);
    final streak = await _repo.getStreak(referenceDate: now);
    final monthTotal = await _repo.getMonthTotal(now);
    if (!mounted) return;
    setState(() { _today = record; _streak = streak; _monthTotal = monthTotal; _isLoading = false; });
  }

  Future<void> _saveToday(DailyWorshipRecord u) async {
    setState(() => _today = u);
    await _repo.upsertRecord(u);
    final now = DateTime.now();
    final streak = await _repo.getStreak(referenceDate: now);
    final monthTotal = await _repo.getMonthTotal(now);
    if (!mounted) return;
    setState(() { _streak = streak; _monthTotal = monthTotal; });
    _loadChartData();
    _loadKaza();
  }

  void _togglePrayer(String key) { final cur = _getPrayerValue(_today, key); _saveToday(_copyWithPrayer(_today, key, !cur)); }
  void _setFasting(bool v) { _saveToday(_today.copyWith(isFasting: v)); }
  void _incrementQuran() { _saveToday(_today.copyWith(quranPages: _today.quranPages + 1)); }
  void _decrementQuran() { if (_today.quranPages <= 0) return; _saveToday(_today.copyWith(quranPages: _today.quranPages - 1)); }
  void _incrementDhikr() { _saveToday(_today.copyWith(dhikrCount: _today.dhikrCount + 33)); }
  void _decrementDhikr() { if (_today.dhikrCount <= 0) return; _saveToday(_today.copyWith(dhikrCount: (_today.dhikrCount - 33).clamp(0, 1 << 31))); }

  DateTime _rangeStart() {
    final now = DateTime.now();
    if (_analyticsTab == 0) {
      final mon = now.subtract(Duration(days: now.weekday - 1));
      return DateTime(mon.year, mon.month, mon.day).add(Duration(days: 7 * _timeOffset));
    } else {
      return DateTime(now.year, now.month + _timeOffset, 1);
    }
  }

  DateTime _rangeEnd(DateTime start) => _analyticsTab == 0 ? start.add(const Duration(days: 6)) : DateTime(start.year, start.month + 1, 0);

  Future<void> _loadChartData() async {
    setState(() => _isChartLoading = true);
    final start = _rangeStart(); final end = _rangeEnd(start);
    final records = await _repo.getRecordsInRange(start, end);
    if (!mounted) return;
    setState(() { _chartRecords = records; _isChartLoading = false; });
  }

  String _dateRangeText() {
    final start = _rangeStart(); final end = _rangeEnd(start);
    if (_analyticsTab == 0) return '${start.day} - ${end.day} ${_monthNames[end.month - 1]} ${end.year}';
    return '${_monthNames[start.month - 1]} ${start.year}';
  }

  Future<void> _loadKaza() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Ilk kayit tarihi
    final firstDate = await _repo.getFirstRecordDate();
    final firstDay = DateTime(firstDate.year, firstDate.month, firstDate.day);

    DateTime rangeStart, rangeEnd;
    if (_kazaPeriod == 0) {
      // Haftalik: bu hafta + offset
      final weekStart = today.subtract(Duration(days: now.weekday - 1));
      rangeStart = DateTime(weekStart.year, weekStart.month, weekStart.day + 7 * _kazaTimeOffset);
      rangeEnd = DateTime(rangeStart.year, rangeStart.month, rangeStart.day + 6);
    } else if (_kazaPeriod == 1) {
      // Aylik
      final m = DateTime(now.year, now.month + _kazaTimeOffset, 1);
      rangeStart = m;
      rangeEnd = DateTime(m.year, m.month + 1, 0);
    } else if (_kazaPeriod == 2) {
      // Yillik
      rangeStart = DateTime(now.year + _kazaTimeOffset, 1, 1);
      rangeEnd = DateTime(now.year + _kazaTimeOffset, 12, 31);
    } else {
      // Tum zamanlar
      rangeStart = firstDay;
      rangeEnd = today;
    }

    // Ilk kayit tarihinden once baslamasin
    final from = rangeStart.isAfter(firstDay) ? rangeStart : firstDay;
    final to = rangeEnd.isAfter(today) ? today : rangeEnd;

    // Tum gunler icin kayit uret
    final data = await _repo.getRecordsInRange(from, to);
    final realRecords = await _repo.getExistingRecordsInRange(from, to);

    if (!mounted) return;
    setState(() {
      _kazaData = _calcKaza(data);
      _totalRecordedDays = realRecords.length;
      _kazaDateRange = '${from.day} ${_monthNames[from.month-1]} - ${to.day} ${_monthNames[to.month-1]} ${to.year}';
    });
  }

  Map<String, int> _calcKaza(List<DailyWorshipRecord> records) {
    final missed = <String, int>{'İmsak (Sabah)': 0, 'Öğle': 0, 'İkindi': 0, 'Akşam': 0, 'Yatsı': 0};
    for (final r in records) {
      if (!r.imsak) missed['İmsak (Sabah)'] = missed['İmsak (Sabah)']! + 1;
      if (!r.ogle) missed['Öğle'] = missed['Öğle']! + 1;
      if (!r.ikindi) missed['İkindi'] = missed['İkindi']! + 1;
      if (!r.aksam) missed['Akşam'] = missed['Akşam']! + 1;
      if (!r.yatsi) missed['Yatsı'] = missed['Yatsı']! + 1;
    }
    return missed;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background, scrolledUnderElevation: 0, elevation: 0, centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.trackerAmberLight), onPressed: () => Navigator.pop(context)),
        title: const Text('İbadet Takibi', style: TextStyle(color: AppColors.trackerAmberLight, fontSize: 20, fontWeight: FontWeight.w600)),
        bottom: TabBar(
          controller: _tabController, indicatorColor: AppColors.trackerAmberLight, indicatorWeight: 2,
          labelColor: AppColors.trackerAmberLight, unselectedLabelColor: AppColors.textLight.withValues(alpha: 0.5),
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          tabs: const [Tab(text: 'Bugün'), Tab(text: 'Kaza Takibi')],
        ),
      ),
      body: _isLoading ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
          : TabBarView(controller: _tabController, children: [
              _buildTodayTab(),
              _buildKazaTab(),
            ]),
    );
  }

  // ═══ BUGÜN SEKME — ESKİ TASARIM ═══
  Widget _buildTodayTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _buildStreakCard(), const SizedBox(height: 24),
        const Text('Aktivite Grafiği', style: TextStyle(color: AppColors.textLight, fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        _buildAppleHealthStyleAnalytics(), const SizedBox(height: 28),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.end, children: [
          const Text('Bugünün Bereketi', style: TextStyle(color: AppColors.textLight, fontSize: 16, fontWeight: FontWeight.w600)),
          Text('${_today.completedPrayers} / 5 Vakit', style: const TextStyle(color: AppColors.gold, fontSize: 14, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 12),
        ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: _today.progress, backgroundColor: Colors.white.withValues(alpha: 0.05), valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold), minHeight: 6)),
        const SizedBox(height: 16),
        ..._prayerKeys.map((p) => _buildTrackerTile(p)),
        const SizedBox(height: 24),
        const Text('Günlük İbadet Sayacı', style: TextStyle(color: AppColors.textLight, fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        _buildFastingCard(), const SizedBox(height: 12),
        _buildCounterCard(title: 'Okunan Kur\'an Sayfası', value: _today.quranPages, unit: 'Sayfa', icon: Icons.menu_book_rounded, onIncrement: _incrementQuran, onDecrement: _decrementQuran),
        const SizedBox(height: 12),
        _buildCounterCard(title: 'Çekilen Zikir Sayısı', value: _today.dhikrCount, unit: 'Zikir', icon: Icons.fingerprint_rounded, onIncrement: _incrementDhikr, onDecrement: _decrementDhikr),
        const SizedBox(height: 40),
      ]),
    );
  }

  Widget _buildStreakCard() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.gold.withValues(alpha: 0.15), width: 1)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _buildStatColumn('İstikrar', '$_streak', 'Gün', Icons.local_fire_department_rounded),
        Container(height: 40, width: 1, color: AppColors.gold.withValues(alpha: 0.15)),
        _buildStatColumn('Bu Ay Toplam', '$_monthTotal', 'Vakit', Icons.task_alt_rounded),
      ]),
    );
  }

  Widget _buildStatColumn(String label, String value, String unit, IconData icon) {
    return Column(children: [
      Icon(icon, color: AppColors.gold, size: 26), const SizedBox(height: 8),
      Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
        Text(value, style: const TextStyle(color: AppColors.textLight, fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(width: 4),
        Text(unit, style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.5), fontSize: 12)),
      ]),
      const SizedBox(height: 4),
      Text(label, style: TextStyle(color: AppColors.gold.withValues(alpha: 0.7), fontSize: 11, fontWeight: FontWeight.w600)),
    ]);
  }

  Widget _buildAppleHealthStyleAnalytics() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.03), borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.gold.withValues(alpha: 0.15), width: 1)),
          child: Column(children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
              child: Row(children: [
                Expanded(child: GestureDetector(
                  onTap: () { setState(() { _analyticsTab = 0; _timeOffset = 0; }); _loadChartData(); },
                  child: Container(padding: const EdgeInsets.symmetric(vertical: 6), decoration: BoxDecoration(color: _analyticsTab == 0 ? AppColors.surface : Colors.transparent, borderRadius: BorderRadius.circular(8)), alignment: Alignment.center,
                    child: Text('Hafta', style: TextStyle(color: _analyticsTab == 0 ? AppColors.textLight : AppColors.textLight.withValues(alpha: 0.5), fontWeight: _analyticsTab == 0 ? FontWeight.w600 : FontWeight.w400))),
                )),
                Expanded(child: GestureDetector(
                  onTap: () { setState(() { _analyticsTab = 1; _timeOffset = 0; }); _loadChartData(); },
                  child: Container(padding: const EdgeInsets.symmetric(vertical: 6), decoration: BoxDecoration(color: _analyticsTab == 1 ? AppColors.surface : Colors.transparent, borderRadius: BorderRadius.circular(8)), alignment: Alignment.center,
                    child: Text('Ay', style: TextStyle(color: _analyticsTab == 1 ? AppColors.textLight : AppColors.textLight.withValues(alpha: 0.5), fontWeight: _analyticsTab == 1 ? FontWeight.w600 : FontWeight.w400))),
                )),
              ]),
            ),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              IconButton(padding: EdgeInsets.zero, constraints: const BoxConstraints(), icon: Icon(Icons.chevron_left_rounded, color: AppColors.gold, size: 28), onPressed: () { setState(() => _timeOffset--); _loadChartData(); }),
              Text(_dateRangeText(), style: const TextStyle(color: AppColors.textLight, fontSize: 16, fontWeight: FontWeight.w600)),
              IconButton(padding: EdgeInsets.zero, constraints: const BoxConstraints(), icon: Icon(Icons.chevron_right_rounded, color: _timeOffset < 0 ? AppColors.gold : AppColors.gold.withValues(alpha: 0.2), size: 28), onPressed: _timeOffset < 0 ? () { setState(() => _timeOffset++); _loadChartData(); } : null),
            ]),
            const SizedBox(height: 24),
            _isChartLoading ? const SizedBox(height: 140, child: Center(child: CircularProgressIndicator(color: AppColors.gold))) : _buildBarChart(),
          ]),
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    List<String> labels;
    if (_analyticsTab == 0) {
      labels = _chartRecords.map((r) => _weekdayLabels[r.date.weekday - 1]).toList();
    } else {
      labels = _chartRecords.map((r) { final d = r.date.day; return (d == 1 || d % 7 == 1) ? '$d' : ''; }).toList();
    }
    return SizedBox(height: 140, child: Column(children: [
      Expanded(child: Row(crossAxisAlignment: CrossAxisAlignment.end, mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _chartRecords.map((r) {
          final val = r.progress;
          return Flexible(child: Padding(padding: EdgeInsets.symmetric(horizontal: _analyticsTab == 0 ? 4.0 : 1.0),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _showDayDetail(r),
              child: FractionallySizedBox(heightFactor: val == 0 ? 0.02 : val,
                child: Container(decoration: BoxDecoration(color: val == 0 ? AppColors.gold.withValues(alpha: 0.15) : AppColors.gold, borderRadius: BorderRadius.circular(4))),
              ),
            ),
          ));
        }).toList(),
      )),
      const SizedBox(height: 10),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: labels.map((l) => Text(l, style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.5), fontSize: 12))).toList()),
    ]));
  }

  Widget _buildTrackerTile(String title) {
    final done = _getPrayerValue(_today, title);
    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Material(color: Colors.transparent,
            child: InkWell(borderRadius: BorderRadius.circular(16), onTap: () => _togglePrayer(title),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(color: done ? AppColors.gold.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.02), borderRadius: BorderRadius.circular(16), border: Border.all(color: done ? AppColors.gold.withValues(alpha: 0.4) : AppColors.gold.withValues(alpha: 0.1))),
                child: Row(children: [
                  Container(width: 24, height: 24, decoration: BoxDecoration(shape: BoxShape.circle, color: done ? AppColors.gold : Colors.transparent, border: Border.all(color: done ? AppColors.gold : AppColors.gold.withValues(alpha: 0.3), width: 1.5)), child: done ? const Icon(Icons.check_rounded, color: AppColors.background, size: 14) : null),
                  const SizedBox(width: 14),
                  Text(title, style: TextStyle(color: done ? AppColors.gold : AppColors.textLight, fontSize: 15, fontWeight: done ? FontWeight.w600 : FontWeight.w500)),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFastingCard() {
    final isFasting = _today.isFasting;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(color: isFasting ? AppColors.gold.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.02), borderRadius: BorderRadius.circular(16), border: Border.all(color: isFasting ? AppColors.gold.withValues(alpha: 0.4) : AppColors.gold.withValues(alpha: 0.1))),
          child: Row(children: [
            Icon(Icons.wb_sunny_outlined, color: isFasting ? AppColors.gold : AppColors.gold.withValues(alpha: 0.5), size: 24),
            const SizedBox(width: 14),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Bugün Oruçluyum', style: TextStyle(color: AppColors.textLight, fontSize: 15, fontWeight: FontWeight.w500))])),
            Switch(value: isFasting, activeThumbColor: AppColors.gold, activeTrackColor: AppColors.gold.withValues(alpha: 0.2), inactiveThumbColor: AppColors.textLight.withValues(alpha: 0.4), inactiveTrackColor: Colors.white.withValues(alpha: 0.05), onChanged: _setFasting),
          ]),
        ),
      ),
    );
  }

  Widget _buildCounterCard({required String title, required int value, required String unit, required IconData icon, required VoidCallback onIncrement, required VoidCallback onDecrement}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.02), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.gold.withValues(alpha: 0.1), width: 1)),
          child: Row(children: [
            Icon(icon, color: AppColors.gold.withValues(alpha: 0.6), size: 24), const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.6), fontSize: 12)), const SizedBox(height: 4),
              Text('$value $unit', style: const TextStyle(color: AppColors.textLight, fontSize: 16, fontWeight: FontWeight.w700)),
            ])),
            IconButton(icon: Icon(Icons.remove_circle_outline_rounded, color: AppColors.gold.withValues(alpha: 0.5), size: 28), onPressed: onDecrement),
            IconButton(icon: const Icon(Icons.add_circle_rounded, color: AppColors.gold, size: 28), onPressed: onIncrement),
          ]),
        ),
      ),
    );
  }

  void _showDayDetail(DailyWorshipRecord record) {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (_) => _buildDayDetailSheet(record),
    );
  }

  Widget _buildDayDetailSheet(DailyWorshipRecord record) {
    final missed = _prayerKeys.where((k) => !_getPrayerValue(record, k)).toList();
    final dateText = '${record.date.day} ${_monthNames[record.date.month - 1]} ${record.date.year}';
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          decoration: BoxDecoration(color: AppColors.surface.withValues(alpha: 0.98), borderRadius: const BorderRadius.vertical(top: Radius.circular(28)), border: Border.all(color: AppColors.gold.withValues(alpha: 0.15), width: 1)),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 16), decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)))),
            Text(dateText, style: const TextStyle(color: AppColors.textLight, fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('${record.completedPrayers} / 5 vakit kılındı', style: TextStyle(color: AppColors.gold.withValues(alpha: 0.8), fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            const Text('Namaz Durumu', style: TextStyle(color: AppColors.textLight, fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Wrap(spacing: 8, runSpacing: 8, children: _prayerKeys.map((key) {
              final done = _getPrayerValue(record, key);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: done ? AppColors.gold.withValues(alpha: 0.12) : Colors.red.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(20), border: Border.all(color: done ? AppColors.gold.withValues(alpha: 0.4) : Colors.red.withValues(alpha: 0.3))),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(done ? Icons.check_circle_rounded : Icons.cancel_rounded, size: 14, color: done ? AppColors.gold : Colors.red.withValues(alpha: 0.7)),
                  const SizedBox(width: 6),
                  Text(key, style: TextStyle(color: done ? AppColors.textLight : AppColors.textLight.withValues(alpha: 0.6), fontSize: 12, fontWeight: FontWeight.w500)),
                ]),
              );
            }).toList()),
            if (missed.isNotEmpty) ...[const SizedBox(height: 8), Text('Kaçırılan: ${missed.join(', ')}', style: TextStyle(color: Colors.red.withValues(alpha: 0.6), fontSize: 11))],
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: _detailStat('Kur\'an', '${record.quranPages}', 'Sayfa', Icons.menu_book_rounded)),
              const SizedBox(width: 12),
              Expanded(child: _detailStat('Zikir', '${record.dhikrCount}', 'Adet', Icons.fingerprint_rounded)),
              const SizedBox(width: 12),
              Expanded(child: _detailStat('Oruç', record.isFasting ? 'Evet' : 'Hayır', '', Icons.wb_sunny_outlined)),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _detailStat(String label, String value, String unit, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.03), borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.gold.withValues(alpha: 0.1))),
      child: Column(children: [
        Icon(icon, color: AppColors.gold.withValues(alpha: 0.7), size: 20), const SizedBox(height: 8),
        Text(unit.isEmpty ? value : '$value $unit', style: const TextStyle(color: AppColors.textLight, fontSize: 14, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.5), fontSize: 11)),
      ]),
    );
  }

  // ═══ KAZA TAKİBİ SEKME ═══
  Widget _buildKazaTab() {
    final periods = ['Hafta', 'Ay', 'Yıl', 'Tümü'];
    final total = _kazaData.values.fold<int>(0, (a, b) => a + b);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // TOPLAM ÖZET
        Container(
          width: double.infinity, padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.gold.withValues(alpha: 0.1), AppColors.gold.withValues(alpha: 0.02)]), borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.gold.withValues(alpha: 0.18))),
          child: Column(children: [
            const Icon(Icons.access_time_rounded, color: AppColors.gold, size: 36),
            const SizedBox(height: 10),
            Text('Toplam Kaza Namazı', style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.7), fontSize: 14)),
            const SizedBox(height: 6),
            Text('$total', style: const TextStyle(color: AppColors.gold, fontSize: 48, fontWeight: FontWeight.w800)),
            Text('$_totalRecordedDays günlük kayıt üzerinden', style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.35), fontSize: 12)),
          ]),
        ),

        const SizedBox(height: 20),

        // PERIOD SEÇİCİ
        Row(children: List.generate(4, (i) {
          final sel = _kazaPeriod == i;
          return Expanded(
            child: GestureDetector(
              onTap: () { setState(() { _kazaPeriod = i; _kazaTimeOffset = 0; }); _loadKaza(); },
              child: Container(
                margin: EdgeInsets.only(left: i > 0 ? 4 : 0),
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: sel ? AppColors.gold : AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: sel ? AppColors.gold : AppColors.gold.withValues(alpha: 0.15)),
                ),
                child: Text(periods[i], style: TextStyle(color: sel ? AppColors.textDark : AppColors.textLight.withValues(alpha: 0.7), fontSize: 13, fontWeight: FontWeight.w700)),
              ),
            ),
          );
        })),

        const SizedBox(height: 12),

        // NAVIGASYON OKLARI (hafta/ay/yil icin)
        if (_kazaPeriod < 3)
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            IconButton(
              icon: const Icon(Icons.chevron_left_rounded, color: AppColors.gold, size: 28),
              onPressed: () { setState(() => _kazaTimeOffset--); _loadKaza(); },
            ),
            Text(_kazaDateRange, style: const TextStyle(color: AppColors.textLight, fontSize: 15, fontWeight: FontWeight.w600)),
            IconButton(
              icon: Icon(Icons.chevron_right_rounded, color: _kazaTimeOffset < 0 ? AppColors.gold : AppColors.gold.withValues(alpha: 0.2), size: 28),
              onPressed: _kazaTimeOffset < 0 ? () { setState(() => _kazaTimeOffset++); _loadKaza(); } : null,
            ),
          ]),

        const SizedBox(height: 12),

        // GRAFIK KARTI
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: AppColors.surfaceCard, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.gold.withValues(alpha: 0.1))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(periods[_kazaPeriod], style: const TextStyle(color: AppColors.textLight, fontSize: 16, fontWeight: FontWeight.w600)),
              const Spacer(),
              Text('Toplam $total', style: TextStyle(color: AppColors.gold.withValues(alpha: 0.6), fontSize: 14, fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 18),
            ..._prayerKeys.map((name) {
              final count = _kazaData[name] ?? 0;
              final maxVal = _kazaData.values.isEmpty ? 1 : _kazaData.values.reduce((a, b) => a > b ? a : b);
              final ratio = maxVal > 0 ? count / maxVal : 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(children: [
                  SizedBox(width: 70, child: Text(name, style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.7), fontSize: 14))),
                  Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: ratio, minHeight: 28, backgroundColor: Colors.white.withValues(alpha: 0.05), valueColor: AlwaysStoppedAnimation<Color>(count > 0 ? AppColors.gold.withValues(alpha: 0.7) : Colors.transparent)))),
                  const SizedBox(width: 12),
                  SizedBox(width: 36, child: Text('$count', textAlign: TextAlign.right, style: TextStyle(color: count > 0 ? AppColors.textLight : AppColors.textLight.withValues(alpha: 0.3), fontSize: 16, fontWeight: FontWeight.w700))),
                ]),
              );
            }),
          ]),
        ),
      ]),
    );
  }
}
