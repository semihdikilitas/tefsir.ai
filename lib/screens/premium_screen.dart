import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class _PremiumFeature {
  final IconData icon;
  final String title;
  final String description;
  const _PremiumFeature({required this.icon, required this.title, required this.description});
}

const _features = [
  _PremiumFeature(
    icon: Icons.auto_awesome_rounded,
    title: 'Aylık 100 Yapay Zeka Tefsir Sorusu',
    description: 'Her ay 100 soru hakkın olur. Bitince token paketi alabilirsin.',
  ),
  _PremiumFeature(
    icon: Icons.block_flipped,
    title: 'Rahatsız Edici Reklamlar Yok',
    description: 'Interstitial ve video reklamlar kalkar. Sadece ana ekranda küçük banner kalır.',
  ),
  _PremiumFeature(
    icon: Icons.wallpaper_rounded,
    title: 'Özel Duvar Kağıtları',
    description: 'Premium koleksiyona tam erişim.',
  ),
];

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  int _selectedPlan = 1; // 0 = Aylık, 1 = Yıllık

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const Row(children: [BackButton(color: AppColors.gold)]),
            const SizedBox(height: 4),
            _buildHero(),
            const SizedBox(height: 28),
            ..._features.map((f) => Padding(padding: const EdgeInsets.only(bottom: 10), child: _buildFeatureTile(f))),
            const SizedBox(height: 24),
            _buildPlanSelector(),
            const SizedBox(height: 12),
            _buildFootNote(),
            const SizedBox(height: 16),
            _buildCtaButton(),
            const SizedBox(height: 8),
            _buildRestoreButton(),
            const SizedBox(height: 12),
          ]),
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Column(children: [
      ShaderMask(
        shaderCallback: (b) => AppColors.premiumGoldGradient.createShader(b),
        child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 56),
      ),
      const SizedBox(height: 16),
      ShaderMask(
        shaderCallback: (b) => AppColors.premiumGoldGradient.createShader(b),
        child: const Text('Tefsir AI Premium', textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
      ),
      const SizedBox(height: 10),
      Text('Yapay zeka tefsirine sınırsız yakın erişim.\nReklamsız, kesintisiz Kur\'an deneyimi.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.6), fontSize: 14, height: 1.5)),
    ]);
  }

  Widget _buildFeatureTile(_PremiumFeature f) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      decoration: BoxDecoration(color: AppColors.surfaceCard, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.gold.withValues(alpha: 0.15))),
      child: Row(children: [
        Container(width: 44, height: 44, alignment: Alignment.center, decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)), child: Icon(f.icon, color: AppColors.gold, size: 22)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text(f.title, style: const TextStyle(color: AppColors.textLight, fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 3),
          Text(f.description, style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.55), fontSize: 12.5, height: 1.3)),
        ])),
        const Icon(Icons.check_circle_rounded, color: AppColors.gold, size: 20),
      ]),
    );
  }

  Widget _buildPlanSelector() {
    return Row(children: [
      Expanded(child: _planCard(0, 'Aylık', '₺49,99', '/ ay')),
      const SizedBox(width: 12),
      Expanded(child: _planCard(1, 'Yıllık', '₺24,99', '/ ay', badge: '%40 Tasarruf', footNote: 'Yıllık ₺299,99')),
    ]);
  }

  Widget _planCard(int index, String title, String price, String suffix, {String? badge, String? footNote}) {
    final sel = _selectedPlan == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = index),
      child: Stack(clipBehavior: Clip.none, children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 14),
          decoration: BoxDecoration(
            color: sel ? AppColors.gold.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: sel ? AppColors.gold : AppColors.gold.withValues(alpha: 0.2), width: sel ? 1.6 : 1),
            boxShadow: sel ? [BoxShadow(color: AppColors.gold.withValues(alpha: 0.3), blurRadius: 20, spreadRadius: -4)] : null,
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(title, style: const TextStyle(color: AppColors.textLight, fontSize: 14, fontWeight: FontWeight.w700)),
              Icon(sel ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded, color: sel ? AppColors.gold : AppColors.textLight.withValues(alpha: 0.3), size: 20),
            ]),
            const SizedBox(height: 10),
            RichText(text: TextSpan(children: [
              TextSpan(text: price, style: const TextStyle(color: AppColors.gold, fontSize: 20, fontWeight: FontWeight.w800)),
              TextSpan(text: ' $suffix', style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.5), fontSize: 12)),
            ])),
            if (footNote != null) ...[const SizedBox(height: 6), Text(footNote, style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.45), fontSize: 10.5))],
          ]),
        ),
        if (badge != null)
          Positioned(top: -10, left: 12, child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(gradient: AppColors.premiumGoldGradient, borderRadius: BorderRadius.circular(20)),
            child: Text(badge, style: const TextStyle(color: AppColors.textDark, fontSize: 10.5, fontWeight: FontWeight.w800)),
          )),
      ]),
    );
  }

  Widget _buildFootNote() {
    return Text('Abonelik iptal edilmediği sürece otomatik yenilenir. Dilediğin an iptal edebilirsin.',
        textAlign: TextAlign.center, style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.35), fontSize: 11));
  }

  Widget _buildCtaButton() {
    return Material(
      color: Colors.transparent, borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => showDialog(
          context: context,
          builder: (_) => Dialog(
            backgroundColor: AppColors.surfaceCard,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: AppColors.gold.withValues(alpha: 0.2))),
            child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.workspace_premium_rounded, color: AppColors.gold, size: 44), const SizedBox(height: 14),
              const Text('Satın alma yakında aktif olacak', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 8),
              Text('Ödeme altyapısı entegre edildiğinde bu ekrandan Premium\'a geçebileceksin.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.6), fontSize: 13, height: 1.4)),
              const SizedBox(height: 18),
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tamam', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700))),
            ])),
          ),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: AppColors.blackGoldButtonGradient,
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            boxShadow: [BoxShadow(color: AppColors.gold.withValues(alpha: 0.35), blurRadius: 22, spreadRadius: -4)],
          ),
          child: Container(
            width: double.infinity, alignment: Alignment.center, padding: const EdgeInsets.symmetric(vertical: 17),
            child: Text(_selectedPlan == 1 ? 'Yıllık Planla Başla' : 'Aylık Planla Başla',
                style: const TextStyle(color: AppColors.textLight, fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    );
  }

  Widget _buildRestoreButton() {
    return TextButton(
      onPressed: () {},
      style: TextButton.styleFrom(minimumSize: Size.zero, padding: const EdgeInsets.symmetric(vertical: 4), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
      child: Text('Satın Alımları Geri Yükle', style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.5), fontSize: 12.5)),
    );
  }
}
