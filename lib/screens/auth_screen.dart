import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  bool _obscure = true;

  @override void dispose() {
    _emailCtrl.dispose(); _passCtrl.dispose(); _nameCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    // TODO Firebase Auth: Email/password sign-in/sign-up
    // Şimdilik direkt geçiş
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const SizedBox(height: 60),

            // Logo
            Center(
              child: Container(
                width: 72, height: 72,
                alignment: Alignment.center,
                decoration: BoxDecoration(gradient: AppColors.premiumGoldGradient, shape: BoxShape.circle),
                child: const Icon(Icons.auto_awesome_rounded, color: AppColors.textDark, size: 36),
              ),
            ),
            const SizedBox(height: 24),
            const Center(child: Text('Tefsir AI', style: TextStyle(color: AppColors.gold, fontSize: 28, fontWeight: FontWeight.w800))),
            const SizedBox(height: 8),
            Center(child: Text('Kuran\'ı anlamak için\nyapay zeka destekli rehberin', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.5), fontSize: 14, height: 1.5))),
            const SizedBox(height: 48),

            // İsim (sadece kayıt)
            if (!_isLogin) ...[
              _buildInput(_nameCtrl, 'Ad Soyad', Icons.person_outline_rounded, TextInputType.name),
              const SizedBox(height: 14),
            ],

            // Email
            _buildInput(_emailCtrl, 'E-posta', Icons.email_outlined, TextInputType.emailAddress),
            const SizedBox(height: 14),

            // Şifre
            _buildInput(_passCtrl, 'Şifre', Icons.lock_outline_rounded, TextInputType.visiblePassword, obscure: _obscure, suffix: IconButton(icon: Icon(_obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: AppColors.gold.withValues(alpha: 0.5), size: 20), onPressed: () => setState(() => _obscure = !_obscure))),
            const SizedBox(height: 24),

            // Buton
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: AppColors.textDark, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
                child: Text(_isLogin ? 'Giriş Yap' : 'Kayıt Ol', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
              ),
            ),
            const SizedBox(height: 16),

            // Geçiş
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(_isLogin ? 'Hesabın yok mu?' : 'Zaten hesabın var mı?', style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.5), fontSize: 14)),
              TextButton(onPressed: () => setState(() { _isLogin = !_isLogin; _obscure = true; }), child: Text(_isLogin ? 'Kayıt Ol' : 'Giriş Yap', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700, fontSize: 14))),
            ]),

            const SizedBox(height: 24),

            // Sosyal giriş
            Row(children: [
              const Expanded(child: Divider(color: AppColors.gold, height: 1)),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text('veya', style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.3), fontSize: 13))),
              const Expanded(child: Divider(color: AppColors.gold, height: 1)),
            ]),
            const SizedBox(height: 20),

            _socialButton('Google ile devam et', Icons.g_mobiledata_rounded, () {
              // TODO: Firebase Google Sign-In
              _submit();
            }),
            const SizedBox(height: 12),
            _socialButton('Apple ile devam et', Icons.apple, () {
              // TODO: Firebase Apple Sign-In
              _submit();
            }),

            const SizedBox(height: 32),

            // Misafir
            Center(
              child: TextButton(
                onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen())),
                child: Text('Şimdilik atla →', style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.4), fontSize: 14)),
              ),
            ),
            const SizedBox(height: 40),
          ]),
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController ctrl, String hint, IconData icon, TextInputType type, {bool obscure = false, Widget? suffix}) {
    return Container(
      decoration: BoxDecoration(color: AppColors.surfaceCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.gold.withValues(alpha: 0.12))),
      child: TextField(
        controller: ctrl, keyboardType: type, obscureText: obscure,
        style: const TextStyle(color: AppColors.textLight, fontSize: 15),
        decoration: InputDecoration(
          hintText: hint, hintStyle: TextStyle(color: AppColors.textLight.withValues(alpha: 0.35)),
          prefixIcon: Icon(icon, color: AppColors.gold.withValues(alpha: 0.6), size: 20),
          suffixIcon: suffix, border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _socialButton(String text, IconData icon, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity, height: 50,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: AppColors.gold, size: 24),
        label: Text(text, style: const TextStyle(color: AppColors.gold, fontSize: 14, fontWeight: FontWeight.w600)),
        style: OutlinedButton.styleFrom(side: BorderSide(color: AppColors.gold.withValues(alpha: 0.3)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
      ),
    );
  }
}
