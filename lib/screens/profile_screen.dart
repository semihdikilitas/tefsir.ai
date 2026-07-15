// ignore_for_file: dead_code // isPremium placeholder - Firebase gelince kalkacak
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import 'auth_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = 'Misafir Kullanıcı';

  void _editProfile() {
    final ctrl = TextEditingController(text: _name);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: AppColors.gold.withValues(alpha: 0.2))),
        title: const Text('Profili Düzenle', style: TextStyle(color: AppColors.gold, fontSize: 18, fontWeight: FontWeight.w700)),
        content: TextField(
          controller: ctrl, style: const TextStyle(color: AppColors.textLight, fontSize: 15),
          decoration: InputDecoration(
            hintText: 'Ad Soyad', hintStyle: TextStyle(color: AppColors.textLight.withValues(alpha: 0.3)),
            filled: true, fillColor: Colors.white.withValues(alpha: 0.03),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.gold)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('İptal', style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.5)))),
          TextButton(onPressed: () { setState(() => _name = ctrl.text.isNotEmpty ? ctrl.text : _name); Navigator.pop(context); }, child: const Text('Kaydet', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700))),
        ],
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: AppColors.gold.withValues(alpha: 0.2))),
        title: const Text('Çıkış Yap', style: TextStyle(color: AppColors.textLight)),
        content: Text('Hesabından çıkış yapmak istediğine emin misin?', style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.7))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Vazgeç', style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.5)))),
          TextButton(onPressed: () { Navigator.pop(context); Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AuthScreen())); }, child: const Text('Çıkış Yap', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w700))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO Firebase Auth: gerçek kullanıcı bilgileri ile değiştir
    const isPremium = false;
    const email = 'misafir@tefsirai.com';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background, elevation: 0, centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.gold), onPressed: () => Navigator.pop(context)),
        title: const Text('Profil', style: TextStyle(color: AppColors.gold, fontSize: 20, fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              // Avatar
              Container(
                width: 88, height: 88,
                alignment: Alignment.center,
                decoration: BoxDecoration(gradient: AppColors.premiumGoldGradient, shape: BoxShape.circle),
                child: Text(_name[0].toUpperCase(), style: const TextStyle(color: AppColors.textDark, fontSize: 38, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(height: 20),
              Text(_name, style: const TextStyle(color: AppColors.textLight, fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(email, style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.5), fontSize: 14)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                decoration: BoxDecoration(
                  color: isPremium ? AppColors.gold.withValues(alpha: 0.15) : AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isPremium ? AppColors.gold : AppColors.gold.withValues(alpha: 0.2)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(isPremium ? Icons.workspace_premium_rounded : Icons.person_outline_rounded, color: isPremium ? AppColors.gold : AppColors.textLight.withValues(alpha: 0.5), size: 16),
                  const SizedBox(width: 6),
                  Text(isPremium ? 'Premium Üye' : 'Ücretsiz Hesap', style: TextStyle(color: isPremium ? AppColors.gold : AppColors.textLight.withValues(alpha: 0.5), fontSize: 13, fontWeight: FontWeight.w600)),
                ]),
              ),
              const SizedBox(height: 48),

              // Profili Düzenle
              _btn(Icons.edit_rounded, 'Profili Düzenle', _editProfile),
              const SizedBox(height: 16),

              // Çıkış Yap
              _btn(Icons.logout_rounded, 'Çıkış Yap', _confirmLogout, highlight: true),

              const Spacer(),
              Text('Tefsir AI v1.0.0', style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.25), fontSize: 12)),
              const SizedBox(height: 40),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _btn(IconData icon, String title, VoidCallback onTap, {bool highlight = false}) {
    return SizedBox(
      width: double.infinity, height: 54,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: highlight ? Colors.redAccent.withValues(alpha: 0.7) : AppColors.gold, size: 20),
        label: Text(title, style: TextStyle(color: highlight ? Colors.redAccent.withValues(alpha: 0.8) : AppColors.textLight, fontSize: 15, fontWeight: FontWeight.w600)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: (highlight ? Colors.redAccent : AppColors.gold).withValues(alpha: 0.25)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}
