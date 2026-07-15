import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../data/services/history_service.dart';
import 'surah_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  List<ChatHistorySession> _sessions = [];
  List<SavedTafsir> _saved = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final sessions = await HistoryService.getSessions();
    final saved = await HistoryService.getSaved();
    if (!mounted) return;
    setState(() { _sessions = sessions; _saved = saved; _loading = false; });
  }

  Future<void> _deleteSession(String id) async {
    await HistoryService.deleteSession(id);
    _load();
  }

  Future<void> _deleteSaved(String id) async {
    await HistoryService.removeSaved(id);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.gold), onPressed: () => Navigator.pop(context)),
        title: const Text('Geçmiş & Kaydedilenler', style: TextStyle(color: AppColors.gold, fontSize: 20, fontWeight: FontWeight.w600)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.gold,
          indicatorWeight: 2,
          labelColor: AppColors.gold,
          unselectedLabelColor: AppColors.textLight.withValues(alpha: 0.5),
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          tabs: const [
            Tab(text: 'Sohbet Geçmişi'),
            Tab(text: 'Kaydedilenler'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
          : TabBarView(controller: _tabController, children: [
              _buildSessionsTab(),
              _buildSavedTab(),
            ]),
    );
  }

  Widget _buildSessionsTab() {
    if (_sessions.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.chat_bubble_outline_rounded, color: AppColors.gold.withValues(alpha: 0.3), size: 56),
          const SizedBox(height: 16),
          Text('Henüz sohbet geçmişiniz yok.', style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.5), fontSize: 15)),
          const SizedBox(height: 8),
          Text('Yapay Zeka Tefsir ile sohbet ettiğinizde\nburada görünecek.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.3), fontSize: 13, height: 1.5)),
        ]),
      );
    }
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      itemCount: _sessions.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final s = _sessions[index];
        return _buildSessionCard(s);
      },
    );
  }

  Widget _buildSessionCard(ChatHistorySession s) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 42, height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.chat_bubble_rounded, color: AppColors.gold, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.textLight, fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(s.preview, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.45), fontSize: 13)),
              const SizedBox(height: 6),
              Text(_fmt(s.date), style: TextStyle(color: AppColors.gold.withValues(alpha: 0.4), fontSize: 11)),
            ]),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, size: 20),
            color: AppColors.textLight.withValues(alpha: 0.3),
            onPressed: () => _deleteSession(s.id),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedTab() {
    if (_saved.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.bookmark_outline_rounded, color: AppColors.gold.withValues(alpha: 0.3), size: 56),
          const SizedBox(height: 16),
          Text('Henüz kaydedilmiş tefsir yok.', style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.5), fontSize: 15)),
          const SizedBox(height: 8),
          Text('Tefsir sohbetinde bir cevabı kaydettiğinizde\nburada görünecek.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.3), fontSize: 13, height: 1.5)),
        ]),
      );
    }
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      itemCount: _saved.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final t = _saved[index];
        return _buildSavedCard(t);
      },
    );
  }

  Widget _buildSavedCard(SavedTafsir t) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.1)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 42, height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.bookmark_rounded, color: AppColors.gold, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(t.question, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.textLight, fontSize: 14, fontWeight: FontWeight.w600))),
        ]),
        const SizedBox(height: 12),
        Text(t.answer, maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.55), fontSize: 13, height: 1.5)),
        if (t.surahRefs.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(spacing: 6, runSpacing: 6, children: t.surahRefs.split(',').where((r) => r.trim().isNotEmpty).map((ref) {
            final parts = ref.trim().split(' ');
            final surah = int.tryParse(parts.length > 2 ? parts[1] : '0') ?? 0;
            return GestureDetector(
              onTap: () => surah > 0 ? Navigator.push(context, MaterialPageRoute(builder: (_) => SurahDetailScreen(surahNumber: surah))) : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.gold.withValues(alpha: 0.15))),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.menu_book_rounded, color: AppColors.gold, size: 12),
                  const SizedBox(width: 4),
                  Text(ref.trim(), style: const TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.w600)),
                ]),
              ),
            );
          }).toList()),
        ],
        const SizedBox(height: 10),
        Row(children: [
          Text(_fmt(t.date), style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.3), fontSize: 11)),
          const Spacer(),
          GestureDetector(
            onTap: () => _deleteSaved(t.id),
            child: Icon(Icons.delete_outline_rounded, color: AppColors.textLight.withValues(alpha: 0.25), size: 18),
          ),
        ]),
      ]),
    );
  }

  String _fmt(DateTime d) {
    final now = DateTime.now();
    if (d.day == now.day && d.month == now.month && d.year == now.year) {
      return 'Bugün ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (d.day == yesterday.day && d.month == yesterday.month && d.year == yesterday.year) return 'Dün';
    return '${d.day}.${d.month}.${d.year}';
  }
}
