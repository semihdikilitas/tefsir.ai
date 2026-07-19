import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/constants/app_colors.dart';
import '../data/services/ad_service.dart';
import '../data/services/api_service.dart';
import 'surah_detail_screen.dart';
import 'premium_screen.dart';

class _AyahRef {
  final int surahNumber;
  final int ayahNumber;
  const _AyahRef(this.surahNumber, this.ayahNumber);
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;
  final List<_AyahRef> refs;
  final List<Map<String, dynamic>>? sources; // Kaynak referanslari

  const _ChatMessage({
    required this.text,
    required this.isUser,
    required this.time,
    this.refs = const [],
    this.sources,
  });
}

class TafsirChatScreen extends StatefulWidget {
  const TafsirChatScreen({super.key});

  @override
  State<TafsirChatScreen> createState() => _TafsirChatScreenState();
}

class _TafsirChatScreenState extends State<TafsirChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isLoading = false;

  bool _isPremium = false;
  int _earnedQuestions = 0;
  DateTime _lastDate = DateTime.now();

  final List<Map<String, String>> _conversationHistory = [];

  @override
  void initState() {
    super.initState();
    if (!_isPremium) {
      WidgetsBinding.instance.addPostFrameCallback((_) => InterstitialAd.show(context));
    }
    _messages.add(_ChatMessage(
      text: 'Esselamu aleykum. Ben Tefsir AI asistaniniz. 🕌\n\n'
          'Kur\'an-i Kerim, tefsir, hadis ve Islami konularda size yardimci olmak icin buradayim. '
          'Cevaplarimi yalnizca guvenilir Islam kaynaklarina dayandiririm.\n\n'
          '💡 Ipucu: Cevabimda gecen 📖 ayet referanslarina tiklayarak dogrudan ilgili sureye gidebilirsiniz.',
      isUser: false,
      time: DateTime.now(),
    ));
  }

  static const String _systemPrompt =
    'Sen Tefsir AI asistanisin. Amacin, kullanicilara Islam dini hakkinda '
    'yalnizca Kuran-i Kerim, sahih hadisler ve guvenilir tefsir kaynaklarina dayanarak bilgi vermektir.\n\n'
    'KESIN KURALLAR:\n'
    '1. SADECE sana verilen kaynaklara (Kuran ayetleri, tefsir, hadis) dayanarak cevap ver.\n'
    '2. KENDI GORUSUNU ASLA BELIRTME. Fikir yurutme, yorum yapma. HALUSINASYON YAPMA.\n'
    '3. Islam\'in hak din oldugu temel bir gercektir, bunu tartisma konusu yapma.\n'
    '4. Bir sorunun cevabi verilen kaynaklarda yoksa "Bu konuda kaynaklarimizda yeterli bilgi bulunmamaktadir" de.\n'
    '5. Cevaplarinda mutlaka hangi kaynagi kullandigini belirt (ayet numarasi, tefsir adi).\n'
    '6. KISA ve OZ cevap ver. Gereksiz uzatma.\n'
    '7. Turkce cevap ver.\n\n'
    'AYET REFERANS FORMATI:\n'
    'Bir ayetten bahsederken su formati kullan: 📖[[sureNo:ayetNo]]\n'
    'Ornek: "...Bakara 255 📖[[2:255]] bu konuda..."';

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  List<_AyahRef> _extractRefs(String text) {
    final regex = RegExp(r'📖\[\[(\d{1,3}):(\d{1,3})\]\]');
    return regex.allMatches(text).map((m) {
      final surah = int.tryParse(m.group(1)!) ?? 0;
      final ayah = int.tryParse(m.group(2)!) ?? 0;
      return _AyahRef(surah, ayah);
    }).where((r) => r.surahNumber >= 1 && r.surahNumber <= 114 && r.ayahNumber >= 1).toList();
  }

  String _cleanText(String text) {
    return text.replaceAll(RegExp(r'📖\[\[\d{1,3}:\d{1,3}\]\]'), '').trim();
  }

  /// Sunucudan ilgili kaynaklari arar
  Future<Map<String, dynamic>> _fetchContext(String query) async {
    final baseUrl = ApiService.baseUrl;
    final dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 8), receiveTimeout: const Duration(seconds: 8)));
    final results = <String, dynamic>{
      'quran': <Map<String, dynamic>>[],
      'tafsir': <Map<String, dynamic>>[],
    };

    try {
      // Kuran'da arama
      final quranResp = await dio.get('$baseUrl/api/quran/search?q=${Uri.encodeComponent(query)}');
      results['quran'] = (quranResp.data as List).take(5).toList();

      // Ilgili tefsirleri getir
      for (final ayah in (results['quran'] as List).take(3)) {
        final sId = ayah['surah']?['id'];
        final aId = ayah['ayah']?['id'];
        if (sId != null && aId != null) {
          try {
            final tafsirResp = await dio.get('$baseUrl/api/tafsir/$sId/$aId');
            if (tafsirResp.data is Map && tafsirResp.data['text'] != null) {
              results['tafsir'].add(tafsirResp.data as Map<String, dynamic>);
            }
          } catch (_) {}
        }
      }
    } catch (_) {
      // Internet yoksa context olmadan devam et
    }

    return results;
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) return;

    final today = DateTime.now();
    if (today.day != _lastDate.day || today.month != _lastDate.month || today.year != _lastDate.year) {
      _saveDayToHistory();
      setState(() {
        _messages.clear();
        _messages.add(_ChatMessage(
          text: 'Yeni bir gun, yeni bir sohbet. 🕌',
          isUser: false, time: DateTime.now(),
        ));
        _lastDate = today;
      });
    }

    if (!_isPremium && _earnedQuestions <= 0) {
      _showNoAccessSheet();
      return;
    }

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true, time: DateTime.now()));
      _isLoading = true;
    });

    _controller.clear();
    _scrollToBottom();

    try {
      // 1. Kaynaklari sunucudan getir (HER ZAMAN - bedava)
      final context = await _fetchContext(text);
      // 2. Kaynak sonuclarini ve AI promptunu hazirla
      final contextParts = <String>[];
      final sources = <Map<String, dynamic>>[];
      final refs = <_AyahRef>[];

      if ((context['quran'] as List).isNotEmpty) {
        final ayahs = context['quran'] as List;
        contextParts.add('--- ILGILI KURAN AYETLERI ---');
        for (final a in ayahs.take(5)) {
          final surah = a['surah'] ?? {};
          final ayah = a['ayah'] ?? {};
          contextParts.add('${surah['name'] ?? ''} ${ayah['id']}: ${ayah['text']}\nMeal: ${ayah['translation']}');
          sources.add({'type': 'ayet', 'surah': surah['id'], 'ayah': ayah['id'], 'text': ayah['translation']});
          refs.add(_AyahRef((surah['id'] as num).toInt(), (ayah['id'] as num).toInt()));
        }
      }

      if ((context['tafsir'] as List).isNotEmpty) {
        contextParts.add('\n--- ILGILI TEFSIR ---');
        for (final t in (context['tafsir'] as List).take(3)) {
          contextParts.add('${t['source']}: ${t['text']}');
          sources.add({'type': 'tefsir', 'source': t['source'], 'text': t['text']});
        }
      }

      // 3. Claude'a her zaman sor — ama kaynaklari context olarak ver
      String prompt = text;
      if (contextParts.isNotEmpty) {
        contextParts.add('\nYUKARIDAKI KAYNAKLARI kullanarak soruyu cevapla. Kaynaklarda yoksa "Bu konuda kaynaklarimizda yeterli bilgi bulunmamaktadir" de.');
        prompt = '${contextParts.join('\n')}\n\nSORU: $text';
      }

      final dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 30), receiveTimeout: const Duration(seconds: 30)));

      // Kendi sunucumuz uzerinden Claude'a sor (API key sunucuda guvende)
      final response = await dio.post(
        '${ApiService.baseUrl}/api/ai/ask',
        data: jsonEncode({
          'messages': [{ 'role': 'user', 'content': prompt }],
          'systemPrompt': _systemPrompt,
        }),
        options: Options(headers: {
          'content-type': 'application/json',
          'x-premium': _isPremium ? 'true' : 'false',
        }),
      );

      if (response.statusCode == 429) {
        if (!mounted) return;
        setState(() {
          _messages.add(_ChatMessage(
            text: 'Gunluk soru limitiniz doldu. Premium ile sinirsiz devam edebilirsiniz.',
            isUser: false, time: DateTime.now(),
          ));
          _isLoading = false;
        });
        _scrollToBottom();
        return;
      }

      final result = response.data as Map<String, dynamic>;
      if (result['error'] != null) throw Exception(result['error']);
      final aiReply = result['reply'] as String;
      final aiRefs = _extractRefs(aiReply);

      _conversationHistory.add({'role': 'user', 'content': prompt});
      _conversationHistory.add({'role': 'assistant', 'content': aiReply});
      if (_conversationHistory.length > 20) _conversationHistory.removeRange(0, 2);

      if (!mounted) return;
      setState(() {
        _messages.add(_ChatMessage(text: aiReply, isUser: false, time: DateTime.now(),
            refs: aiRefs.isNotEmpty ? aiRefs : refs, sources: sources.isNotEmpty ? sources : null));
        _isLoading = false;
      });

      if (!_isPremium) _earnedQuestions--;
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(_ChatMessage(
          text: 'Uzgunum, bir hata olustu. Lutfen internet baglantinizi kontrol edip tekrar deneyin.',
          isUser: false,
          time: DateTime.now(),
        ));
        _isLoading = false;
      });
    }

    _scrollToBottom();
  }

  void _saveDayToHistory() {
    // TODO: Save chat to history when HistoryService is integrated
  }

  void _showNoAccessSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.lock_rounded, color: AppColors.gold, size: 40),
          const SizedBox(height: 16),
          const Text('Premium Gerekiyor', style: TextStyle(color: AppColors.textLight, fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Aylik soru hakkiniz doldu. Premium\'a gecerek sinirsiz soru sorabilirsiniz.',
              textAlign: TextAlign.center, style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.6), fontSize: 13)),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, child: TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumScreen()));
            },
            style: TextButton.styleFrom(backgroundColor: AppColors.gold, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            child: const Text('Premium\'a Gec', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700)),
          )),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background, elevation: 0, centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.gold), onPressed: () => Navigator.pop(context)),
        title: const Text('Tefsir AI', style: TextStyle(color: AppColors.gold, fontSize: 20, fontWeight: FontWeight.w600)),
      ),
      body: Column(children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: _messages.length,
            itemBuilder: (context, index) => _buildMessageBubble(_messages[index]),
          ),
        ),
        if (_isLoading) const Padding(padding: EdgeInsets.all(8), child: LinearProgressIndicator(color: AppColors.gold, backgroundColor: Colors.transparent)),
        _buildInputBar(),
      ]),
    );
  }

  Widget _buildMessageBubble(_ChatMessage msg) {
    if (msg.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(top: 8, bottom: 8, left: 60),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(18)),
          child: Text(msg.text, style: const TextStyle(color: AppColors.textLight, fontSize: 14, height: 1.5)),
        ),
      );
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        margin: const EdgeInsets.only(top: 8, bottom: 4, right: 40),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.surfaceCard, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.gold.withValues(alpha: 0.1))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_cleanText(msg.text), style: const TextStyle(color: AppColors.textLight, fontSize: 14, height: 1.5)),
          if (msg.refs.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(spacing: 6, runSpacing: 6, children: msg.refs.map((ref) => GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SurahDetailScreen(surahNumber: ref.surahNumber))),
              child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.gold.withValues(alpha: 0.2))),
                child: Text('📖 ${ref.surahNumber}:${ref.ayahNumber}', style: const TextStyle(color: AppColors.gold, fontSize: 12))),
            )).toList()),
          ],
        ]),
      ),
    ]);
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(color: AppColors.surfaceCard, border: Border(top: BorderSide(color: AppColors.gold.withValues(alpha: 0.1)))),
      child: Row(children: [
        Expanded(
          child: TextField(
            controller: _controller,
            style: const TextStyle(color: AppColors.textLight),
            decoration: InputDecoration(
              hintText: 'Kuran hakkinda soru sor...',
              hintStyle: TextStyle(color: AppColors.textLight.withValues(alpha: 0.4)),
              filled: true, fillColor: AppColors.background,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => _sendMessage(),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(14)),
          child: IconButton(
            icon: const Icon(Icons.send_rounded, color: AppColors.textDark, size: 20),
            onPressed: _isLoading ? null : _sendMessage,
          ),
        ),
      ]),
    );
  }
}
