import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_colors.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  static Future<bool> shouldShow() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool('onboarding_done') ?? false);
  }

  static Future<void> markDone() async {
    await (await SharedPreferences.getInstance()).setBool('onboarding_done', true);
  }

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageCtrl = PageController();
  int _current = 0;

  void _finish() async {
    await OnboardingScreen.markDone();
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  @override
  void dispose() { _pageCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(children: [
          // Skip
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _finish,
              child: Text('Atla', style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.4), fontSize: 14)),
            ),
          ),

          // Sayfalar
          Expanded(
            child: PageView(
              controller: _pageCtrl,
              onPageChanged: (i) => setState(() => _current = i),
              children: const [
                _OnboardPage(
                  emoji: '🕌',
                  title: 'Namaz Vakitleri\nHer An Yanında',
                  desc: 'İster İstanbul\'da ister Mekke\'de ol,\nbulunduğun şehrin namaz vakitlerini\ncanlı takip et.',
                ),
                _OnboardPage(
                  emoji: '📖',
                  title: 'Kuran-ı Kerim\nMushaf Sayfaları',
                  desc: '604 sayfa tam mushaf. Sayfa çevirme\ngerçek mushaf hissiyatında. Kaldığın\nyerden devam et.',
                ),
                _OnboardPage(
                  emoji: '🤖',
                  title: 'Yapay Zeka ile\nTefsir Deneyimi',
                  desc: 'Merak ettiğin ayetleri AI\'a sor.\nDetaylı tefsir, nüzul sebebi ve\nmeal karşılaştırmaları.',
                ),
                _OnboardPage(
                  emoji: '🏆',
                  title: 'İbadet Takibi &\nKaza Sayacı',
                  desc: 'Namazlarını takip et, istikrarını gör.\nKaza namazlarını hesapla.\nRozetler kazan.',
                ),
              ],
            ),
          ),

          // Noktalar + Buton
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              ...List.generate(4, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: _current == i ? 28 : 8, height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: _current == i ? AppColors.gold : AppColors.gold.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(4),
                ),
              )),
              const Spacer(),
              SizedBox(
                width: 140,
                child: ElevatedButton(
                  onPressed: () {
                    if (_current < 3) {
                      _pageCtrl.animateToPage(_current + 1, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                    } else {
                      _finish();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold, foregroundColor: AppColors.textDark,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(_current < 3 ? 'Devam' : 'Başla', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _OnboardPage extends StatelessWidget {
  final String emoji, title, desc;
  const _OnboardPage({required this.emoji, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 120, height: 120,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [AppColors.gold.withValues(alpha: 0.15), AppColors.gold.withValues(alpha: 0.03)]),
            shape: BoxShape.circle,
          ),
          child: Text(emoji, style: const TextStyle(fontSize: 56)),
        ),
        const SizedBox(height: 40),
        Text(title, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textLight, fontSize: 26, fontWeight: FontWeight.w800, height: 1.3)),
        const SizedBox(height: 20),
        Text(desc, textAlign: TextAlign.center, style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.55), fontSize: 15, height: 1.6)),
      ]),
    );
  }
}
