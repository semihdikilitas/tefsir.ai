import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../core/constants/app_colors.dart';
import '../data/services/ad_service.dart';
import '../data/services/history_service.dart';
import 'surah_detail_screen.dart';
import 'quran_screen.dart';
import 'premium_screen.dart';

/// Referans: AI'ın cevabından parse edilen sure:ayet ikilisi.
class _AyahRef {
  final int surahNumber;
  final int ayahNumber;
  const _AyahRef(this.surahNumber, this.ayahNumber);
}

/// Sohbet baloncuğu.
class _ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;
  final List<_AyahRef> refs; // bu mesaja ait sure:ayet referansları

  const _ChatMessage({
    required this.text,
    required this.isUser,
    required this.time,
    this.refs = const [],
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

  // TODO: Gerçek uygulamada anahtar güvenli bir kaynaktan gelmeli.
  static const String _apiKey = 'YOUR_GEMINI_API_KEY';

  // Premium / reklam durumu (simülasyon — gerçekte backend/SharedPrefs)
  // ignore: prefer_final_fields
  bool _isPremium = false; // TODO: SharedPreferences'ten oku
  int _freeAdViews = 0;
  int _earnedQuestions = 0;

  // Günlük reset
  DateTime _lastDate = DateTime.now();

  late final GenerativeModel _model;
  late final ChatSession _chat;

  @override
  void initState() {
    super.initState();
    // Premium kullanıcılara AI girişinde interstitial gösterme
    if (!_isPremium) {
      WidgetsBinding.instance.addPostFrameCallback((_) => InterstitialAd.show(context));
    }
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey,
      systemInstruction: Content.text(
        'Sen bir İslam alimi ve tefsir uzmanısın. Kullanıcılara Kur\'an-ı Kerim '
        'ayetleri hakkında derinlemesine tefsir yapıyorsun. Cevaplarında '
        'Ehl-i Sünnet çizgisinde, güvenilir tefsir kaynaklarına (Taberi, Kurtubi, '
        'İbn Kesir, Diyanet vb.) dayanarak açıklamalar yap.\n\n'
        'ÖNEMLİ KURAL: Cevabında bir ayetten bahsederken, ayetin hemen yanına '
        'şu özel etiketi EKLEMEYİ UNUTMA: 📖[[sureNo:ayetNo]]\n'
        'Örnek: "Bakara Suresi 255. ayette 📖[[2:255]] Allah şöyle buyurur..."\n'
        'Sure numarası 1-114 arası, ayet numarası sure içindeki sıradır.\n'
        'Her ayet referansı için bu etiketi mutlaka kullan. Türkçe cevap ver.',
      ),
    );
    _chat = _model.startChat();

    _messages.add(_ChatMessage(
      text: 'Esselamu aleyküm. Ben Tefsir AI asistanınız. 🕌\n\n'
          'Kur\'an-ı Kerim hakkında merak ettiğiniz her şeyi sorabilirsiniz. '
          'Bir ayetin tefsirini, nüzul sebebini, sureler arası bağlantıları '
          'veya İslami konularda bilgi almak istediğiniz her şeyi bana '
          'yöneltebilirsiniz.\n\n'
          '💡 İpucu: Cevabımda geçen 📖 ayet referanslarına tıklayarak '
          'doğrudan ilgili sureye gidebilirsiniz.\n\n'
          'Örnek sorular:\n'
          '• İhlas Suresi\'nin tefsirini yapar mısın?\n'
          '• Bakara 255. ayet neden Ayet-el Kürsi olarak bilinir?\n'
          '• Hangi sureler Medine\'de indirilmiştir?\n'
          '• Sabır ile ilgili ayetleri açıklar mısın?',
      isUser: false,
      time: DateTime.now(),
    ));
  }

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

  /// AI cevabından 📖[[sure:ayet]] kalıplarını çıkarır.
  List<_AyahRef> _extractRefs(String text) {
    final regex = RegExp(r'📖\[\[(\d{1,3}):(\d{1,3})\]\]');
    return regex.allMatches(text).map((m) {
      final surah = int.tryParse(m.group(1)!) ?? 0;
      final ayah = int.tryParse(m.group(2)!) ?? 0;
      return _AyahRef(surah, ayah);
    }).where((r) => r.surahNumber >= 1 && r.surahNumber <= 114 && r.ayahNumber >= 1).toList();
  }

  /// Referans etiketlerini metinden temizler.
  String _cleanText(String text) {
    return text.replaceAll(RegExp(r'📖\[\[\d{1,3}:\d{1,3}\]\]'), '').trim();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) return;

    // Günlük reset: yeni gün başladıysa dünkü sohbeti geçmişe kaydet, temizle
    final today = DateTime.now();
    if (today.day != _lastDate.day || today.month != _lastDate.month || today.year != _lastDate.year) {
      _saveDayToHistory();
      setState(() {
        _messages.clear();
        _messages.add(_ChatMessage(
          text: 'Yeni bir gün, yeni bir sohbet. 🕌\nKuran\'a dair merak ettiğin her şeyi sorabilirsin.',
          isUser: false, time: DateTime.now(),
        ));
        _lastDate = today;
      });
    }

    // Ücretsiz kullanıcı kontrolü
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
      final response = await _chat.sendMessage(Content.text(text));
      final rawReply = response.text ?? 'Üzgünüm, şu anda cevap veremiyorum.';

      final refs = _extractRefs(rawReply);
      final cleanReply = _cleanText(rawReply);

      if (!mounted) return;
      final msg = _ChatMessage(text: cleanReply, isUser: false, time: DateTime.now(), refs: refs);
      setState(() {
        _messages.add(msg);
        _isLoading = false;
        // Reklamla kazanılan soruyu düş
        if (!_isPremium && _earnedQuestions > 0) _earnedQuestions--;
      });
      _saveSession(text, cleanReply);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(_ChatMessage(
          text: '⚠️ Bağlantı hatası: ${e.toString()}\n\n'
              'Lütfen internet bağlantınızı kontrol edip tekrar deneyin. '
              'Eğer sorun devam ederse API anahtarınızı kontrol edin.',
          isUser: false,
          time: DateTime.now(),
        ));
        _isLoading = false;
      });
    }
    _scrollToBottom();
  }

  void _showNoAccessSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.15)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
              Icon(Icons.workspace_premium_rounded, color: AppColors.gold, size: 44),
              const SizedBox(height: 12),
              const Text('Yapay Zeka Tefsir Premium', style: TextStyle(color: AppColors.textLight, fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text('AI tefsir sormak için Premium üye ol\nveya reklam izleyerek soru kazan.',
                  textAlign: TextAlign.center, style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.6), fontSize: 14, height: 1.5)),
              const SizedBox(height: 24),
              // Reklam izle
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () { Navigator.pop(context); _watchAd(); },
                  icon: const Icon(Icons.play_circle_outline_rounded, color: AppColors.gold),
                  label: Text('3 Reklam İzle, 1 Soru Kazan ($_freeAdViews/3)', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w600, fontSize: 15)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.gold),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Premium'a geç
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumScreen()));
                  },
                  icon: const Icon(Icons.workspace_premium_rounded, color: AppColors.textDark),
                  label: const Text('Premium\'a Geç (100 Soru/Ay)', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700, fontSize: 15)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Token satın al
              TextButton.icon(
                onPressed: () { Navigator.pop(context); _buyTokens(); },
                icon: Icon(Icons.shopping_bag_rounded, color: AppColors.gold.withValues(alpha: 0.7), size: 18),
                label: Text('Token Paketi Satın Al', style: TextStyle(color: AppColors.gold.withValues(alpha: 0.7), fontSize: 14)),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  void _watchAd() {
    setState(() => _freeAdViews++);
    if (_freeAdViews >= 3) {
      setState(() { _freeAdViews = 0; _earnedQuestions++; });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating, backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppColors.gold.withValues(alpha: 0.3))),
        duration: const Duration(seconds: 2),
        content: const Row(children: [
          Icon(Icons.check_circle_rounded, color: AppColors.gold, size: 20),
          SizedBox(width: 8),
          Text('1 soru hakkı kazandın!', style: TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w600)),
        ]),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating, backgroundColor: AppColors.surface,
        duration: const Duration(milliseconds: 800),
        content: Text('${3 - _freeAdViews} reklam daha izlemelisin.', style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.7))),
      ));
    }
  }

  void _buyTokens() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.15)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 16), decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
              const Text('Token Paketi Satın Al', style: TextStyle(color: AppColors.gold, fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('Premium üyeliğin olsa da olmasa da ek soru alabilirsin.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.5), fontSize: 13)),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(child: _tokenCard('50 Soru', '₺19,99', Icons.chat_bubble_outline_rounded)),
                const SizedBox(width: 10),
                Expanded(child: _tokenCard('200 Soru', '₺49,99', Icons.auto_awesome_rounded, popular: true)),
                const SizedBox(width: 10),
                Expanded(child: _tokenCard('500 Soru', '₺99,99', Icons.diamond_rounded)),
              ]),
              const SizedBox(height: 16),
              Text('Satın alma şu an simülasyonda. Yakında App Store / Google Play üzerinden aktif olacak.',
                  textAlign: TextAlign.center, style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.35), fontSize: 11)),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _tokenCard(String title, String price, IconData icon, {bool popular = false}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: popular ? AppColors.gold : AppColors.gold.withValues(alpha: 0.12), width: popular ? 1.5 : 1),
      ),
      child: Column(children: [
        if (popular)
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), margin: const EdgeInsets.only(bottom: 8), decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)), child: const Text('Popüler', style: TextStyle(color: AppColors.gold, fontSize: 9, fontWeight: FontWeight.w800))),
        Icon(icon, color: popular ? AppColors.gold : AppColors.gold.withValues(alpha: 0.5), size: 22),
        const SizedBox(height: 8),
        Text(title, style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.7), fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(price, style: const TextStyle(color: AppColors.gold, fontSize: 18, fontWeight: FontWeight.w800)),
      ]),
    );
  }

  void _saveDayToHistory() {
    // Sadece kullanıcı mesajları varsa kaydet (hoşgeldin mesajı hariç)
    final userMessages = _messages.where((m) => m.isUser).toList();
    if (userMessages.isEmpty) return;

    final title = userMessages.first.text;
    final preview = _messages.where((m) => !m.isUser).lastOrNull?.text ?? '';
    final id = 'day_${_lastDate.year}${_lastDate.month}${_lastDate.day}';

    HistoryService.addSession(ChatHistorySession(
      id: id,
      title: title.length > 50 ? '${title.substring(0, 50)}...' : title,
      preview: preview.length > 80 ? '${preview.substring(0, 80)}...' : preview,
      date: _lastDate,
    ));
  }

  // Her soru-cevapta çağrılan session kaydı yerine artık günlük kayıt
  void _saveSession(String question, String answer) {
    final id = 'day_${_lastDate.year}${_lastDate.month}${_lastDate.day}';
    // Tüm mesajları topla
    final allUser = _messages.where((m) => m.isUser).map((m) => m.text).join(' | ');
    final allAi = _messages.where((m) => !m.isUser && !m.text.startsWith('Yeni bir gün') && !m.text.startsWith('Esselamu')).map((m) => m.text).join(' | ');

    HistoryService.addSession(ChatHistorySession(
      id: id,
      title: allUser.length > 50 ? '${allUser.substring(0, 50)}...' : allUser,
      preview: allAi.length > 80 ? '${allAi.substring(0, 80)}...' : allAi,
      date: _lastDate,
    ));
  }

  Future<void> _toggleBookmark(int index) async {
    final msg = _messages[index];
    final id = 'bm_${msg.time.millisecondsSinceEpoch}';
    final already = await HistoryService.isSaved(id);
    if (already) {
      await HistoryService.removeSaved(id);
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating, backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppColors.gold.withValues(alpha: 0.2))),
        duration: const Duration(seconds: 1),
        content: const Text('Kaydedilenlerden çıkarıldı', style: TextStyle(color: AppColors.textLight)),
      )); }
    } else {
      // Önceki kullanıcı mesajını bul
      String question = msg.text;
      for (int i = index - 1; i >= 0; i--) {
        if (_messages[i].isUser) { question = _messages[i].text; break; }
      }
      final refs = msg.refs.map((r) => 'Sure ${r.surahNumber}, Ayet ${r.ayahNumber}').join(', ');
      await HistoryService.addSaved(SavedTafsir(id: id, question: question, answer: msg.text, surahRefs: refs, date: DateTime.now()));
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating, backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppColors.gold.withValues(alpha: 0.3))),
        duration: const Duration(seconds: 1),
        content: const Row(children: [
          Icon(Icons.bookmark_rounded, color: AppColors.gold, size: 18),
          SizedBox(width: 8),
          Text('Tefsir kaydedildi', style: TextStyle(color: AppColors.textLight)),
        ]),
      )); }
    }
  }

  void _navigateToSurah(int surahNumber) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SurahDetailScreen(surahNumber: surahNumber),
      ),
    );
  }

  void _navigateToQuran() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QuranScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.gold),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome_rounded, color: AppColors.gold, size: 22),
            SizedBox(width: 8),
            Text(
              'Yapay Zeka ile Tefsir',
              style: TextStyle(color: AppColors.gold, fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Kuran\'ı Aç',
            icon: const Icon(Icons.menu_book_rounded, color: AppColors.gold, size: 22),
            onPressed: _navigateToQuran,
          ),
          IconButton(
            tooltip: 'Sohbeti Temizle',
            icon: Icon(Icons.delete_outline_rounded, color: AppColors.textLight.withValues(alpha: 0.6)),
            onPressed: () => _confirmClearChat(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // ═══════ ÖZEL GOLD/SİYAH ARKA PLAN ═══════
          Positioned.fill(
            child: _buildPremiumBackground(),
          ),

          // İçerik
          SafeArea(
            child: Column(
              children: [
                // Premium / Ücretsiz durum çubuğu
                if (!_isPremium)
                  GestureDetector(
                    onTap: _showNoAccessSheet,
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [AppColors.gold.withValues(alpha: 0.12), AppColors.gold.withValues(alpha: 0.04)]),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.gold.withValues(alpha: 0.18)),
                      ),
                      child: Row(children: [
                        const Icon(Icons.workspace_premium_rounded, color: AppColors.gold, size: 20),
                        const SizedBox(width: 8),
                        Expanded(child: Text(
                          _earnedQuestions > 0 ? '$_earnedQuestions soru hakkın var' : 'AI Tefsir için Premium\'a geç',
                          style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.8), fontSize: 13, fontWeight: FontWeight.w600))),
                        const Icon(Icons.chevron_right_rounded, color: AppColors.gold, size: 18),
                      ]),
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length) {
                        return _buildTypingIndicator();
                      }
                      return _buildMessageBubble(_messages[index], index);
                    },
                  ),
                ),
                _buildInputBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Altın parçacıklı, koyu premium arka plan.
  Widget _buildPremiumBackground() {
    return CustomPaint(
      painter: _PremiumBgPainter(),
      child: Container(),
    );
  }

  void _confirmClearChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.gold.withValues(alpha: 0.2)),
        ),
        title: const Text('Sohbeti Temizle', style: TextStyle(color: AppColors.textLight)),
        content: Text(
          'Tüm sohbet geçmişi silinecek. Devam etmek istiyor musunuz?',
          style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Vazgeç', style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.6))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _messages.clear();
                _messages.add(_ChatMessage(
                  text: 'Sohbet temizlendi. Yeni bir soru sorabilirsiniz.',
                  isUser: false,
                  time: DateTime.now(),
                ));
              });
            },
            child: const Text('Temizle', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(_ChatMessage msg, int index) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.80),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: msg.isUser
              ? AppColors.gold.withValues(alpha: 0.12)
              : Colors.black.withValues(alpha: 0.45),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: msg.isUser ? const Radius.circular(18) : const Radius.circular(4),
            bottomRight: msg.isUser ? const Radius.circular(4) : const Radius.circular(18),
          ),
          border: Border.all(
            color: msg.isUser
                ? AppColors.gold.withValues(alpha: 0.30)
                : AppColors.gold.withValues(alpha: 0.12),
          ),
        ),
        child: Column(
          crossAxisAlignment: msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              msg.text,
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: 15,
                height: 1.55,
              ),
            ),
            // 📖 Ayet referans çipleri
            if (msg.refs.isNotEmpty) ...[
              const SizedBox(height: 12),
              Divider(color: AppColors.gold.withValues(alpha: 0.1), height: 1),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: msg.refs.map((ref) {
                  return GestureDetector(
                    onTap: () => _navigateToSurah(ref.surahNumber),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.gold.withValues(alpha: 0.20),
                            AppColors.gold.withValues(alpha: 0.06),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.menu_book_rounded, color: AppColors.gold, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'Sure ${ref.surahNumber}, Ayet ${ref.ayahNumber}',
                            style: const TextStyle(
                              color: AppColors.gold,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.arrow_forward_rounded, color: AppColors.gold.withValues(alpha: 0.7), size: 14),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
            // Yer imi butonu (sadece AI mesajlarında)
            if (!msg.isUser) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => _toggleBookmark(index),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.bookmark_add_outlined, color: AppColors.gold, size: 18),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
          ),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.12)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _TypingDot(delayMs: 0),
            _TypingDot(delayMs: 300),
            _TypingDot(delayMs: 600),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: AppColors.textLight, fontSize: 15),
              maxLines: 4,
              minLines: 1,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              decoration: InputDecoration(
                hintText: 'Kuran\'a dair bir soru sor...',
                hintStyle: TextStyle(color: AppColors.textLight.withValues(alpha: 0.35), fontSize: 15),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              gradient: _controller.text.trim().isNotEmpty
                  ? AppColors.blackGoldButtonGradient
                  : null,
              color: _controller.text.trim().isNotEmpty ? null : AppColors.gold.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.send_rounded,
                color: _controller.text.trim().isNotEmpty ? AppColors.textLight : AppColors.gold.withValues(alpha: 0.35),
                size: 22,
              ),
              onPressed: _controller.text.trim().isNotEmpty ? _sendMessage : null,
            ),
          ),
        ],
      ),
    );
  }
}

/// ─── Yazma animasyon noktası ───
class _TypingDot extends StatelessWidget {
  final int delayMs;
  const _TypingDot({required this.delayMs});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 1.0),
      duration: const Duration(milliseconds: 800),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: const BoxDecoration(
              color: AppColors.gold,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}

/// ─── Özel premium arka plan çizici ───
/// Siyah zemin üzerinde derinlikli altın radial glow ve
/// zarif altın parçacık/çizgi detayları.
class _PremiumBgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Zemin — saf siyah
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF000000),
    );

    // 2. Üstte büyük altın radial glow (daha belirgin)
    final topGlow = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.6),
        radius: 1.3,
        colors: [
          const Color(0xFFD4AF37).withValues(alpha: 0.22),
          const Color(0xFFD4AF37).withValues(alpha: 0.10),
          const Color(0xFF8B6914).withValues(alpha: 0.04),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), topGlow);

    // 3. Sağ üstte ikinci glow
    final rightGlow = Paint()
      ..shader = RadialGradient(
        center: const Alignment(1.0, -0.3),
        radius: 0.8,
        colors: [
          const Color(0xFFC9A227).withValues(alpha: 0.12),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), rightGlow);

    // 4. Altta geniş yumuşak glow
    final bottomGlow = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.2, 1.3),
        radius: 1.1,
        colors: [
          const Color(0xFFD4AF37).withValues(alpha: 0.08),
          const Color(0xFF8B6914).withValues(alpha: 0.03),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bottomGlow);

    // 5. İnce altın yatay çizgiler (belirginleşti)
    _drawGoldLine(canvas, size, 0.10, 0.14, 0.35);
    _drawGoldLine(canvas, size, 0.22, 0.08, 0.55);
    _drawGoldLine(canvas, size, 0.50, 0.10, 0.40);
    _drawGoldLine(canvas, size, 0.68, 0.06, 0.50);
    _drawGoldLine(canvas, size, 0.85, 0.12, 0.30);

    // 6. Altın parçacıklar (daha büyük ve parlak)
    final rng = Random(42);
    for (int i = 0; i < 90; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final r = 0.6 + rng.nextDouble() * 2.0;
      final alpha = 0.06 + rng.nextDouble() * 0.18;
      canvas.drawCircle(
        Offset(x, y),
        r,
        Paint()..color = const Color(0xFFD4AF37).withValues(alpha: alpha),
      );
    }
  }

  void _drawGoldLine(Canvas canvas, Size size, double yRatio, double alpha, double widthRatio) {
    final paint = Paint()
      ..color = const Color(0xFFD4AF37).withValues(alpha: alpha)
      ..strokeWidth = 0.5;
    final y = size.height * yRatio;
    final startX = size.width * ((1 - widthRatio) / 2);
    final endX = size.width * (1 - (1 - widthRatio) / 2);
    canvas.drawLine(Offset(startX, y), Offset(endX, y), paint);
  }

  @override
  bool shouldRepaint(covariant _PremiumBgPainter oldDelegate) => false;
}
