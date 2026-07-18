import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/app_colors.dart';
import '../data/models/daily_worship_record.dart';
import '../data/repositories/worship_repository.dart';

/// Tek bir zikir çeşidini (adı, Arapça yazılışı, hedef adedi) temsil eder.
class _DhikrPreset {
  final String name;
  final String arabic;
  final int target;
  final bool isCustom;

  const _DhikrPreset(this.name, this.arabic, this.target, {this.isCustom = false});

  _DhikrPreset copyWithTarget(int newTarget) =>
      _DhikrPreset(name, arabic, newTarget, isCustom: isCustom);
}

class ZikirmatikScreen extends StatefulWidget {
  const ZikirmatikScreen({super.key});

  @override
  State<ZikirmatikScreen> createState() => _ZikirmatikScreenState();
}

class _ZikirmatikScreenState extends State<ZikirmatikScreen>
    with SingleTickerProviderStateMixin {
  final WorshipRepository _repo = WorshipRepository();

  static const List<_DhikrPreset> _defaultPresets = [
    _DhikrPreset('Sübhanallah', 'سُبْحَانَ اللّٰه', 33),
    _DhikrPreset('Elhamdülillah', 'اَلْحَمْدُ لِلّٰه', 33),
    _DhikrPreset('Allahu Ekber', 'اَللّٰهُ أَكْبَرُ', 34),
    _DhikrPreset('Estağfirullah', 'أَسْتَغْفِرُ اللّٰه', 100),
    _DhikrPreset('La ilahe illallah', 'لَا إِلٰهَ إِلَّا اللّٰه', 100),
    _DhikrPreset('Salavat-ı Şerife', 'صَلَّى اللّٰهُ عَلَيْهِ وَسَلَّم', 100),
  ];

  late List<_DhikrPreset> _presets;
  int _selectedIndex = 0;

  bool _isLoading = true;
  late DailyWorshipRecord _today;

  int _currentCount = 0; 
  int _sessionCount = 0; 
  int _completedCycles = 0; 
  final List<int> _undoStack = [];

  late final AnimationController _bounceController;

  @override
  void initState() {
    super.initState();
    _presets = List.of(_defaultPresets);
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
    );
    _loadToday();
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  Future<void> _loadToday() async {
    final record = await _repo.getRecordForDate(DateTime.now());
    if (!mounted) return;
    setState(() {
      _today = record;
      _isLoading = false;
    });
  }

  _DhikrPreset get _selected => _presets[_selectedIndex];

  Future<void> _persistDelta(int delta) async {
    final newTotal = (_today.dhikrCount + delta).clamp(0, 1 << 30);
    final updated = _today.copyWith(dhikrCount: newTotal);
    setState(() => _today = updated);
    await _repo.upsertRecord(updated);
  }

  void _onTapCounter() {
    HapticFeedback.lightImpact();
    _bounceController.forward(from: 0).then((_) {
      if (mounted) _bounceController.reverse();
    });

    setState(() {
      _undoStack.add(_currentCount);
      _currentCount++;
      _sessionCount++;
    });
    _persistDelta(1);

    if (_currentCount >= _selected.target) {
      HapticFeedback.mediumImpact();
      setState(() {
        _completedCycles++;
        _currentCount = 0;
      });
      _showCycleCompleteBanner();
    }
  }

  void _showCycleCompleteBanner() {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.gold.withValues(alpha: 0.3)),
        ),
        duration: const Duration(seconds: 2),
        content: Row(
          children: [
            const Icon(Icons.auto_awesome_rounded, color: AppColors.gold, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${_selected.name} — bir tur tamamlandı! ($_completedCycles. tur)',
                style: const TextStyle(color: AppColors.textLight, fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _undo() {
    if (_undoStack.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() {
      _currentCount = _undoStack.removeLast();
      _sessionCount = (_sessionCount - 1).clamp(0, 1 << 30);
    });
    _persistDelta(-1);
  }

  Future<void> _confirmReset() async {
    if (_currentCount == 0) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.gold.withValues(alpha: 0.2)),
        ),
        title: const Text('Turu Sıfırla?', style: TextStyle(color: AppColors.textLight, fontSize: 20)),
        content: Text(
          'Bu turdaki $_currentCount zikir sıfırlanacak. Bugünün toplam zikir sayısı etkilenmez.',
          style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.8), fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Vazgeç', style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.6), fontSize: 16)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sıfırla', style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      setState(() {
        _currentCount = 0;
        _undoStack.clear();
      });
    }
  }

  void _selectPreset(int index) {
    if (_selectedIndex == index) return;
    HapticFeedback.selectionClick();
    setState(() {
      _selectedIndex = index;
      _currentCount = 0;
      _undoStack.clear();
    });
  }

  Future<void> _editTarget(int index) async {
    final controller = TextEditingController(text: '${_presets[index].target}');
    final newTarget = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.gold.withValues(alpha: 0.2)),
        ),
        title: Text('${_presets[index].name} — Hedef', style: const TextStyle(color: AppColors.textLight, fontSize: 20)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: AppColors.textLight, fontSize: 18),
          decoration: InputDecoration(
            hintText: 'Örn. 33',
            hintStyle: TextStyle(color: AppColors.textLight.withValues(alpha: 0.3)),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.gold.withValues(alpha: 0.3))),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.gold)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Vazgeç', style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.6), fontSize: 16)),
          ),
          TextButton(
            onPressed: () {
              final parsed = int.tryParse(controller.text.trim());
              Navigator.pop(context, parsed);
            },
            child: const Text('Kaydet', style: TextStyle(color: AppColors.gold, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (newTarget != null && newTarget > 0) {
      setState(() {
        _presets[index] = _presets[index].copyWithTarget(newTarget);
        if (_selectedIndex == index) _currentCount = 0;
      });
    }
  }

  // YENİ: Genişletilmiş ve Rahat Zikir Ekleme Modalı
  Future<void> _addCustomDhikr() async {
    final nameController = TextEditingController();
    final targetController = TextEditingController(text: '33');
    final result = await showDialog<_DhikrPreset>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: AppColors.gold.withValues(alpha: 0.2)),
        ),
        title: const Text('Özel Zikir Ekle', style: TextStyle(color: AppColors.textLight, fontSize: 20)),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Çok satırlı, ferah metin kutusu
              TextField(
                controller: nameController,
                minLines: 3,
                maxLines: 6,
                textInputAction: TextInputAction.newline,
                style: const TextStyle(color: AppColors.textLight, fontSize: 16, height: 1.4),
                decoration: InputDecoration(
                  hintText: 'Okumak istediğiniz uzun bir duayı veya zikri buraya yazabilirsiniz...',
                  hintStyle: TextStyle(color: AppColors.textLight.withValues(alpha: 0.3), fontSize: 15),
                  contentPadding: const EdgeInsets.all(16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColors.gold.withValues(alpha: 0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Hedef Adet Kutusu
              TextField(
                controller: targetController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.textLight, fontSize: 18),
                decoration: InputDecoration(
                  labelText: 'Hedef Adet',
                  labelStyle: TextStyle(color: AppColors.gold.withValues(alpha: 0.8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColors.gold.withValues(alpha: 0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Vazgeç', style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.6), fontSize: 16)),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final target = int.tryParse(targetController.text.trim()) ?? 0;
              if (name.isEmpty || target <= 0) return;
              Navigator.pop(context, _DhikrPreset(name, '', target, isCustom: true));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.background,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text('Ekle', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (result != null) {
      setState(() {
        _presets.add(result);
        _selectedIndex = _presets.length - 1;
        _currentCount = 0;
        _undoStack.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.gold),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Zikirmatik',
          style: TextStyle(color: AppColors.gold, fontSize: 20, fontWeight: FontWeight.w600),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton.icon(
              onPressed: _addCustomDhikr,
              icon: const Icon(Icons.add_rounded, color: AppColors.gold, size: 24),
              label: const Text(
                'Yeni Zikir',
                style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
          : SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  _buildPresetSelector(),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildSelectedDhikrLabel(),
                            const SizedBox(height: 32),
                            _buildCounter(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  _buildStatsRow(),
                  const SizedBox(height: 24),
                  _buildActionRow(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildPresetSelector() {
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _presets.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final preset = _presets[index];
          final selected = index == _selectedIndex;
          
          // Kart içi Dinamik Punto Algoritması
          final double cardFontSize = preset.name.length > 30 ? 12 : (preset.name.length > 15 ? 14 : 16);

          return GestureDetector(
            onTap: () => _selectPreset(index),
            onLongPress: () => _showPresetOptions(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 150, 
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: selected ? AppColors.gold.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: selected ? AppColors.gold : AppColors.gold.withValues(alpha: 0.15),
                  width: selected ? 2.0 : 1.0, 
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    preset.name,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected ? AppColors.gold : AppColors.textLight.withValues(alpha: 0.9),
                      fontSize: cardFontSize, 
                      fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${preset.target} adet',
                    style: TextStyle(
                      color: selected ? AppColors.gold.withValues(alpha: 0.8) : AppColors.textLight.withValues(alpha: 0.5),
                      fontSize: 13, 
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // YENİ: Dinamik Punto ile Zikir Gösterimi
  Widget _buildSelectedDhikrLabel() {
    // Ana ekrandaki yazının uzunluğuna göre punto küçülür
    final int textLen = _selected.name.length;
    final double dynamicFontSize = textLen > 70 ? 17 : (textLen > 40 ? 20 : 26);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(
            _selected.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textLight, 
              fontSize: dynamicFontSize, 
              fontWeight: FontWeight.w800,
              height: 1.3,
            ),
          ),
          if (_selected.arabic.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              _selected.arabic,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.gold, fontSize: 24, fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showPresetOptions(int index) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPresetOptionsSheet(_presets[index]),
    );
    if (!mounted || action == null) return;
    if (action == 'edit') {
      await _editTarget(index);
    } else if (action == 'delete') {
      await _confirmDeletePreset(index);
    }
  }

  Widget _buildPresetOptionsSheet(_DhikrPreset preset) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.15)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Text(
                preset.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.textLight, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(height: 20),
            ListTile(
              leading: Icon(Icons.tune_rounded, color: AppColors.gold.withValues(alpha: 0.85), size: 28),
              title: const Text('Hedefi Düzenle', style: TextStyle(color: AppColors.textLight, fontSize: 16)),
              onTap: () => Navigator.pop(context, 'edit'),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 28),
              title: const Text('Zikri Sil', style: TextStyle(color: Colors.redAccent, fontSize: 16)),
              onTap: () => Navigator.pop(context, 'delete'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeletePreset(int index) async {
    if (_presets.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('En az bir zikir kalmalı.')),
      );
      return;
    }
    final preset = _presets[index];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.gold.withValues(alpha: 0.2)),
        ),
        title: const Text('Zikri Sil', style: TextStyle(color: AppColors.textLight, fontSize: 20)),
        content: Text(
          '"${preset.name}" listeden tamamen silinecek. Bu işlem geri alınamaz.',
          style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.8), fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Vazgeç', style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.6), fontSize: 16)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sil', style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      _deletePresetAt(index);
    }
  }

  void _deletePresetAt(int index) {
    final wasSelected = index == _selectedIndex;
    setState(() {
      _presets.removeAt(index);
      if (wasSelected) {
        _currentCount = 0;
        _undoStack.clear();
        _selectedIndex = _selectedIndex.clamp(0, _presets.length - 1);
      } else if (index < _selectedIndex) {
        _selectedIndex -= 1;
      }
    });
  }

  Widget _buildCounter() {
    final progress = _selected.target == 0 ? 0.0 : (_currentCount / _selected.target).clamp(0.0, 1.0);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _onTapCounter,
      child: AnimatedBuilder(
        animation: _bounceController,
        builder: (context, child) {
          final scale = 1 - (_bounceController.value * 0.05);
          return Transform.scale(scale: scale, child: child);
        },
        child: SizedBox(
          width: 300, 
          height: 300,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 300,
                height: 300,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 14, 
                  backgroundColor: Colors.white.withValues(alpha: 0.06),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
                ),
              ),
              Container(
                width: 240, 
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.2), width: 2), 
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$_currentCount',
                      style: const TextStyle(color: AppColors.gold, fontSize: 84, fontWeight: FontWeight.w800), 
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '/ ${_selected.target}',
                      style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.6), fontSize: 20, fontWeight: FontWeight.w700), 
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(child: _buildStatChip(Icons.timelapse_rounded, 'Bu Oturum', '$_sessionCount')),
          const SizedBox(width: 16),
          Expanded(child: _buildStatChip(Icons.loop_rounded, 'Biten Tur', '$_completedCycles')),
          const SizedBox(width: 16),
          Expanded(child: _buildStatChip(Icons.today_rounded, 'Bugün', '${_today.dhikrCount}')),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8), 
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.gold.withValues(alpha: 0.8), size: 24), 
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: AppColors.textLight, fontSize: 20, fontWeight: FontWeight.bold)), 
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.6), fontSize: 13, fontWeight: FontWeight.w500), 
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _undoStack.isEmpty ? null : _undo,
              icon: const Icon(Icons.undo_rounded, size: 22),
              label: const Text('Geri Al', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textLight.withValues(alpha: 0.9),
                side: BorderSide(color: AppColors.gold.withValues(alpha: 0.3)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _currentCount == 0 ? null : _confirmReset,
              icon: const Icon(Icons.refresh_rounded, size: 22),
              label: const Text('Sıfırla', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent.withValues(alpha: 0.9),
                side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.4)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}