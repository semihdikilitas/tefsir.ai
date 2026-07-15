import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  final _feedbackController = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _sendFeedback() {
    final text = _feedbackController.text.trim();
    if (text.isEmpty) return;
    // TODO: Gerçek gönderim (API / e-posta)
    setState(() => _sent = true);
    _feedbackController.clear();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _sent = false);
    });
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
          'Hakkında & Geri Bildirim',
          style: TextStyle(color: AppColors.gold, fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── LOGO & UYGULAMA BİLGİSİ ───
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80, height: 80,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: AppColors.premiumGoldGradient,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: AppColors.gold.withValues(alpha: 0.3), blurRadius: 20)],
                      ),
                      child: const Icon(Icons.auto_awesome_rounded, color: AppColors.textDark, size: 40),
                    ),
                    const SizedBox(height: 20),
                    const Text('Tefsir AI', style: TextStyle(color: AppColors.gold, fontSize: 26, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    Text(
                      'Kuran-ı Kerim\'i anlamak için yapay zeka destekli bir rehber.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.7), fontSize: 14, height: 1.5),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('Versiyon 1.0.0 · 2026', style: TextStyle(color: AppColors.gold, fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ─── ÖZELLİKLER ───
              _sectionTitle('Uygulama Özellikleri'),
              const SizedBox(height: 8),
              _buildFeatureList(),

              const SizedBox(height: 28),

              // ─── GERİ BİLDİRİM ───
              _sectionTitle('Geri Bildirim'),
              const SizedBox(height: 8),
              _buildFeedbackCard(),

              const SizedBox(height: 28),

              // ─── BAĞLANTILAR ───
              _sectionTitle('Bağlantılar'),
              const SizedBox(height: 8),
              _buildLinkTile(Icons.star_rounded, 'App Store\'da Puanla', () {}),
              _buildLinkTile(Icons.share_rounded, 'Arkadaşlarınla Paylaş', () {}),
              _buildLinkTile(Icons.privacy_tip_outlined, 'Gizlilik Politikası', () {}),

              const SizedBox(height: 40),
              Center(
                child: Text(
                  '🤲 Allah razı olsun.',
                  style: TextStyle(color: AppColors.gold.withValues(alpha: 0.5), fontSize: 13),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(title, style: TextStyle(color: AppColors.gold.withValues(alpha: 0.7), fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
    );
  }

  Widget _buildFeatureList() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.1)),
      ),
      child: const Column(
        children: [
          _FeatureRow(Icons.menu_book_rounded, 'Kuran-ı Kerim', 'Tam sayfa mushaf görüntüleyici'),
          _Divider(),
          _FeatureRow(Icons.auto_awesome_rounded, 'Yapay Zeka Tefsir', 'Gemini AI ile ayet açıklamaları'),
          _Divider(),
          _FeatureRow(Icons.explore_rounded, 'Kıble Pusulası', 'Gerçek zamanlı kıble yönü'),
          _Divider(),
          _FeatureRow(Icons.schedule_rounded, 'Namaz Vakitleri', '81 il ve dünya şehirleri'),
          _Divider(),
          _FeatureRow(Icons.track_changes_rounded, 'İbadet Takibi', 'Namaz, oruç, zikir takibi'),
          _Divider(),
          _FeatureRow(Icons.volunteer_activism_rounded, 'Dualar & Hadisler', 'Günlük dualar ve hadis koleksiyonu'),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Görüş ve önerilerinizi bekliyoruz.', style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.8), fontSize: 14)),
          const SizedBox(height: 12),
          TextField(
            controller: _feedbackController,
            maxLines: 4,
            style: const TextStyle(color: AppColors.textLight, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Düşüncelerinizi yazın...',
              hintStyle: TextStyle(color: AppColors.textLight.withValues(alpha: 0.3), fontSize: 14),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.03),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.gold, width: 1)),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _feedbackController.text.trim().isEmpty ? null : _sendFeedback,
              icon: _sent
                  ? const Icon(Icons.check_rounded, color: AppColors.textDark, size: 20)
                  : const Icon(Icons.send_rounded, color: AppColors.textDark, size: 18),
              label: Text(_sent ? 'Gönderildi!' : 'Gönder', style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _sent ? AppColors.success : AppColors.gold,
                disabledBackgroundColor: AppColors.gold.withValues(alpha: 0.2),
                disabledForegroundColor: AppColors.gold.withValues(alpha: 0.4),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkTile(IconData icon, String title, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.gold, size: 22),
              const SizedBox(width: 14),
              Expanded(child: Text(title, style: const TextStyle(color: AppColors.textLight, fontSize: 15, fontWeight: FontWeight.w500))),
              Icon(Icons.chevron_right_rounded, color: AppColors.textLight.withValues(alpha: 0.3), size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  const _FeatureRow(this.icon, this.title, this.desc);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: AppColors.gold, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppColors.textLight, fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(desc, style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.5), fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) => Divider(color: AppColors.gold.withValues(alpha: 0.08), height: 1, indent: 66);
}
