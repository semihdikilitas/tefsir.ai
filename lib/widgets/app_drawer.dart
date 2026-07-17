import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../data/services/language_service.dart';
import '../screens/worship_tracker_screen.dart';
import '../screens/quran_screen.dart';
import '../screens/zikirmatik_screen.dart';
import '../screens/esmaul_husna_screen.dart';
import '../screens/gunluk_dualar_screen.dart';
import '../screens/hadis_i_serif_screen.dart';
import '../screens/premium_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/about_screen.dart';
import '../screens/history_screen.dart';
import '../screens/profile_screen.dart';
import '../features/wallpapers/presentation/wallpaper_browser_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PROFİL
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(children: [
                  Container(
                    width: 48, height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(gradient: AppColors.premiumGoldGradient, shape: BoxShape.circle),
                    child: const Text('M', style: TextStyle(color: AppColors.textDark, fontSize: 22, fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(width: 14),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Misafir Kullanıcı', style: TextStyle(color: AppColors.textLight, fontSize: 16, fontWeight: FontWeight.w700)),
                    Text('Profili Görüntüle', style: TextStyle(color: AppColors.gold.withValues(alpha: 0.6), fontSize: 12)),
                  ]),
                ]),
              ),
            ),
            const SizedBox(height: 16),
            Divider(color: AppColors.gold.withValues(alpha: 0.15), height: 1),
            const SizedBox(height: 8),

            // HAFTANIN BEREKETİ KARTI (Daha kompakt hale getirildi)
            _buildCollectiveGoalPanel(),

            const SizedBox(height: 12),
            Divider(color: AppColors.gold.withValues(alpha: 0.15), height: 1),
            const SizedBox(height: 8),

            // ÇEKİRDEK ÖZELLİKLER
            _buildDrawerItem(
              context,
              icon: Icons.menu_book_rounded,
              title: L10n.t('menu_quran'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const QuranScreen()),
                );
              },
            ),
            _buildDrawerItem(
              context,
              icon: Icons.track_changes_rounded,
              title: L10n.t('menu_worship'),
              onTap: () {
                Navigator.pop(context); // Önce drawer'ı kapat
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WorshipTrackerScreen()),
                );
              },
            ),
            _buildDrawerItem(context, icon: Icons.fingerprint_rounded, title: 'Akıllı Zikirmatik', onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ZikirmatikScreen()),
              );
            }),
            _buildDrawerItem(context, icon: Icons.auto_awesome_mosaic_rounded, title: 'Esmaül Hüsna', onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EsmaulHusnaScreen()),
              );
            }),
            _buildDrawerItem(context, icon: Icons.volunteer_activism_rounded, title: 'Günlük Dualar', onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GunlukDualarScreen()),
              );
            }),
            _buildDrawerItem(context, icon: Icons.article_rounded, title: 'Hadis-i Şerif', onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HadisiSerifScreen()),
              );
            }),
            _buildDrawerItem(context, icon: Icons.wallpaper_rounded, title: 'Duvar Kağıtları', onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WallpaperBrowserScreen()),
              );
            }),

            const SizedBox(height: 4),
            Divider(color: AppColors.gold.withValues(alpha: 0.15), height: 1),
            const SizedBox(height: 4),

            // YAPAY ZEKA VE PREMİUM
            _buildDrawerItem(context, icon: Icons.history_rounded, title: 'Geçmiş & Kaydedilenler', onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
            }),
            _buildDrawerItem(
              context,
              icon: Icons.workspace_premium_rounded,
              title: 'Premium\'a Geç',
              highlighted: true,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PremiumScreen()),
                );
              },
            ),

            // Kalan tüm boşluğu esnek olarak doldurup, Ayarları en alta iter
            const Spacer(),

            // SABİT SİSTEM AYARLARI
            Divider(color: AppColors.gold.withValues(alpha: 0.15), height: 1),
            _buildDrawerItem(context, icon: Icons.settings_rounded, title: 'Ayarlar', onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            }),
            _buildDrawerItem(context, icon: Icons.info_outline_rounded, title: 'Hakkında / Geri Bildirim', onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutScreen()),
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // Kolektif Ümmet Hedefi Kart Tasarımı (Ekrana tam sığması için daraltıldı)
  Widget _buildCollectiveGoalPanel() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.15), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.groups_rounded, color: AppColors.gold, size: 20),
              const SizedBox(width: 10),
              const Text(
                'Haftanın Bereketi',
                style: TextStyle(
                  color: AppColors.gold,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Tefsir AI topluluğu bu hafta toplam 42.500 ayet tefsiri okudu.',
            style: TextStyle(
              color: AppColors.textLight.withValues(alpha: 0.7),
              fontSize: 12,
              height: 1.4,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 0.72,
              backgroundColor: Colors.white.withValues(alpha: 0.05),
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold.withValues(alpha: 0.8)),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  // Standart Menü Elemanı Tasarımı (Padding ve boyutlar optimize edildi)
  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool highlighted = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.gold.withValues(alpha: 0.1),
        highlightColor: AppColors.gold.withValues(alpha: 0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0), // 16'dan 12'ye düşürüldü
          child: Row(
            children: [
              Icon(
                icon,
                color: AppColors.gold,
                size: 24, // 26'dan 24'e düşürüldü
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  color: highlighted ? AppColors.gold : AppColors.textLight,
                  fontSize: 16, // 17'den 16'ya düşürüldü
                  fontWeight: highlighted ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}