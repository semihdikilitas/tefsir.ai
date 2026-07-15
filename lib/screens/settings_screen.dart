import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../data/services/language_service.dart';
import 'premium_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _autoLocation = true;
  String _selectedLanguage = 'Türkçe';
  String _selectedTafsirSource = 'Diyanet';

  final List<String> _languages = ['Türkçe', 'English', 'العربية', 'فارسی'];
  final List<String> _tafsirSources = ['Diyanet', 'Elmalılı', 'Kurtubi', 'Taberi'];

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
          'Ayarlar',
          style: TextStyle(color: AppColors.gold, fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // GENEL AYARLAR
              _buildSectionHeader('Genel'),
              const SizedBox(height: 8),
              _buildSettingsCard([
                _buildSwitchTile(
                  icon: Icons.notifications_active_rounded,
                  title: 'Bildirimler',
                  subtitle: 'Namaz vakti ve günlük hatırlatmalar',
                  value: _notificationsEnabled,
                  onChanged: (v) => setState(() => _notificationsEnabled = v),
                ),
                _buildDivider(),
                _buildSelectorTile(
                  icon: Icons.language_rounded,
                  title: 'Dil',
                  subtitle: 'Uygulama dili',
                  value: _selectedLanguage,
                  options: _languages,
                  onSelected: (v) async {
                    setState(() => _selectedLanguage = v);
                    final lang = _languageFromLabel(v);
                    await L10n.setLanguage(lang);
                    if (context.mounted) {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                    }
                  },
                ),
              ]),

              const SizedBox(height: 24),

              // TEFSİR AYARLARI
              _buildSectionHeader('Tefsir'),
              const SizedBox(height: 8),
              _buildSettingsCard([
                _buildSelectorTile(
                  icon: Icons.menu_book_rounded,
                  title: 'Varsayılan Tefsir Kaynağı',
                  subtitle: 'AI tefsirlerde kullanılacak kaynak',
                  value: _selectedTafsirSource,
                  options: _tafsirSources,
                  onSelected: (v) => setState(() => _selectedTafsirSource = v),
                ),
              ]),

              const SizedBox(height: 24),

              // KONUM AYARLARI
              _buildSectionHeader('Konum'),
              const SizedBox(height: 8),
              _buildSettingsCard([
                _buildSwitchTile(
                  icon: Icons.my_location_rounded,
                  title: 'Otomatik Konum',
                  subtitle: 'Namaz vakitleri için konumunu otomatik algıla',
                  value: _autoLocation,
                  onChanged: (v) => setState(() => _autoLocation = v),
                ),
                _buildDivider(),
                _buildTapTile(
                  icon: Icons.edit_location_rounded,
                  title: 'Konumu Elle Seç',
                  subtitle: 'İstanbul, Türkiye',
                  onTap: () {
                    // TODO: Şehir seçme modalı
                  },
                ),
              ]),

              const SizedBox(height: 24),

              // ABONELİK
              _buildSectionHeader('Abonelik'),
              const SizedBox(height: 8),
              _buildSettingsCard([
                _buildTapTile(
                  icon: Icons.workspace_premium_rounded,
                  title: 'Premium\'a Geç',
                  subtitle: 'AI Tefsir, reklamsız deneyim',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumScreen()));
                  },
                ),
                _buildDivider(),
                _buildTapTile(
                  icon: Icons.manage_accounts_rounded,
                  title: 'Aboneliği Yönet',
                  subtitle: 'Plan değiştir veya iptal et',
                  onTap: () {
                    // TODO: App Store / Google Play abonelik yönetimi
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Abonelik yönetimi yakında aktif olacak.')));
                  },
                ),
                _buildDivider(),
                _buildTapTile(
                  icon: Icons.restore_rounded,
                  title: 'Satın Alımları Geri Yükle',
                  subtitle: 'Daha önce aldığın satın alımları geri getir',
                  onTap: () {
                    // TODO: Restore purchases
                  },
                ),
              ]),

              const SizedBox(height: 24),

              // DİĞER
              _buildSectionHeader('Diğer'),
              const SizedBox(height: 8),
              _buildSettingsCard([
                _buildTapTile(
                  icon: Icons.feedback_rounded,
                  title: 'Geri Bildirim Gönder',
                  subtitle: 'Görüş ve önerilerinizi iletin',
                  onTap: () {
                    // TODO: Geri bildirim formu
                  },
                ),
                _buildDivider(),
                _buildTapTile(
                  icon: Icons.star_rounded,
                  title: 'Uygulamayı Puanla',
                  subtitle: 'App Store\'da değerlendirme yapın',
                  onTap: () {
                    // TODO: App Store link
                  },
                ),
                _buildDivider(),
                _buildTapTile(
                  icon: Icons.share_rounded,
                  title: 'Paylaş',
                  subtitle: 'Tefsir AI\'ı sevdiklerinizle paylaşın',
                  onTap: () {
                    // TODO: Paylaşma sayfası
                  },
                ),
                _buildDivider(),
                _buildTapTile(
                  icon: Icons.info_outline_rounded,
                  title: 'Hakkında',
                  subtitle: 'Versiyon 1.0.0',
                  onTap: () => _showAboutDialog(),
                ),
              ]),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  AppLanguage _languageFromLabel(String label) {
    switch (label) {
      case 'English': return AppLanguage.english;
      case 'العربية': return AppLanguage.arabic;
      case 'فارسی': return AppLanguage.persian;
      default: return AppLanguage.turkish;
    }
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome_rounded, color: AppColors.gold, size: 32),
              ),
              const SizedBox(height: 16),
              const Text(
                'Tefsir AI',
                style: TextStyle(color: AppColors.gold, fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'Kuran-ı Kerim\'i anlamak için yapay zeka destekli bir rehber.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.7), fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 20),
              Text(
                'Versiyon 1.0.0',
                style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.4), fontSize: 12),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tamam', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- YARDIMCI WIDGET'LAR ---

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.gold.withValues(alpha: 0.7),
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.1), width: 1),
          ),
          child: Column(children: children),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: AppColors.gold.withValues(alpha: 0.08),
      height: 1,
      indent: 56,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.gold, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppColors.textLight, fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.5), fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.gold,
            activeTrackColor: AppColors.gold.withValues(alpha: 0.3),
            inactiveThumbColor: AppColors.textLight.withValues(alpha: 0.4),
            inactiveTrackColor: Colors.white.withValues(alpha: 0.05),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectorTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required List<String> options,
    required ValueChanged<String> onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.gold, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppColors.textLight, fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.5), fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                dropdownColor: AppColors.surfaceElevated,
                style: const TextStyle(color: AppColors.gold, fontSize: 13, fontWeight: FontWeight.w600),
                icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.gold.withValues(alpha: 0.6), size: 20),
                items: options.map((o) {
                  return DropdownMenuItem(
                    value: o,
                    child: Text(o, style: const TextStyle(color: AppColors.textLight, fontSize: 13)),
                  );
                }).toList(),
                onChanged: (v) {
                  if (v != null) onSelected(v);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTapTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: AppColors.gold.withValues(alpha: 0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.gold, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: AppColors.textLight, fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.5), fontSize: 12)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppColors.textLight.withValues(alpha: 0.3), size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
