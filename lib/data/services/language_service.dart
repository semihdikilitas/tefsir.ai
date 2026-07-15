import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Desteklenen diller.
enum AppLanguage {
  turkish('tr', 'Türkçe', TextDirection.ltr),
  english('en', 'English', TextDirection.ltr),
  arabic('ar', 'العربية', TextDirection.rtl),
  persian('fa', 'فارسی', TextDirection.rtl);

  final String code;
  final String label;
  final TextDirection direction;
  const AppLanguage(this.code, this.label, this.direction);

  Locale get locale => Locale(code);
}

/// Basit JSON tabanlı çeviri sistemi. Context gerektirmez.
class L10n {
  L10n._();

  static const _supported = AppLanguage.values;
  static AppLanguage _current = AppLanguage.turkish;

  static AppLanguage get current => _current;
  static Locale get locale => _current.locale;
  static TextDirection get direction => _current.direction;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('app_language') ?? 'tr';
    _current = _supported.firstWhere((l) => l.code == code, orElse: () => AppLanguage.turkish);
  }

  static Future<void> setLanguage(AppLanguage lang) async {
    _current = lang;
    await (await SharedPreferences.getInstance()).setString('app_language', lang.code);
  }

  /// Ana çeviri fonksiyonu. [key] → çeviri.
  static String t(String key) => _translations[key]?[_current.code] ?? key;

  // TODO: Diğer widget'lardan L10n.t('key') şeklinde çağrılır.
  // Örnek: L10n.t('greeting') → 'Selamun Aleyküm' (TR), 'As-salamu alaykum' (EN)

  static const Map<String, Map<String, String>> _translations = {
    // ───── APP BAR / NAVIGATION ─────
    'app_title': {'tr': 'Tefsir AI', 'en': 'Tafsir AI', 'ar': 'تفسير AI', 'fa': 'تفسیر AI'},
    'greeting': {'tr': 'Selamun Aleyküm,', 'en': 'As-salamu alaykum,', 'ar': 'السلام عليكم،', 'fa': 'السلام علیکم،'},
    'loading': {'tr': 'Yükleniyor...', 'en': 'Loading...', 'ar': 'جاري التحميل...', 'fa': 'در حال بارگذاری...'},

    // ───── DRAWER ─────
    'menu_quran': {'tr': 'Kur\'an-ı Kerim', 'en': 'The Holy Quran', 'ar': 'القرآن الكريم', 'fa': 'قرآن کریم'},
    'menu_worship': {'tr': 'İbadet Takibi', 'en': 'Worship Tracker', 'ar': 'متابعة العبادات', 'fa': 'پیگیری عبادات'},
    'menu_dhikr': {'tr': 'Akıllı Zikirmatik', 'en': 'Smart Dhikr', 'ar': 'عداد الذكر', 'fa': 'ذکر شمار'},
    'menu_esma': {'tr': 'Esmaül Hüsna', 'en': 'Names of Allah', 'ar': 'أسماء الله الحسنى', 'fa': 'اسماء الهی'},
    'menu_duas': {'tr': 'Günlük Dualar', 'en': 'Daily Prayers', 'ar': 'الأدعية اليومية', 'fa': 'دعاهای روزانه'},
    'menu_hadith': {'tr': 'Hadis-i Şerif', 'en': 'Hadith', 'ar': 'الأحاديث', 'fa': 'احادیث'},
    'menu_history': {'tr': 'Geçmiş & Kaydedilenler', 'en': 'History & Saved', 'ar': 'المحفوظات', 'fa': 'تاریخچه و ذخیره‌ها'},
    'menu_premium': {'tr': 'Premium\'a Geç', 'en': 'Go Premium', 'ar': 'النسخة المميزة', 'fa': 'نسخه ویژه'},
    'menu_settings': {'tr': 'Ayarlar', 'en': 'Settings', 'ar': 'الإعدادات', 'fa': 'تنظیمات'},
    'menu_about': {'tr': 'Hakkında / Geri Bildirim', 'en': 'About / Feedback', 'ar': 'حول / ملاحظات', 'fa': 'درباره / بازخورد'},
    'menu_profile': {'tr': 'Profili Görüntüle', 'en': 'View Profile', 'ar': 'عرض الملف', 'fa': 'مشاهده پروفایل'},

    // ───── HOME ─────
    'prayer_times': {'tr': 'Namaz Vakitleri', 'en': 'Prayer Times', 'ar': 'أوقات الصلاة', 'fa': 'اوقات نماز'},
    'quran_kerim': {'tr': 'Kuran-ı Kerim', 'en': 'Holy Quran', 'ar': 'القرآن الكريم', 'fa': 'قرآن کریم'},
    'qibla_compass': {'tr': 'Kıble Pusulası', 'en': 'Qibla Compass', 'ar': 'اتجاه القبلة', 'fa': 'قبله نما'},
    'ai_tafsir': {'tr': 'Yapay Zeka ile Tefsir', 'en': 'AI Tafsir', 'ar': 'تفسير بالذكاء الاصطناعي', 'fa': 'تفسیر با هوش مصنوعی'},
    'ai_desc': {'tr': 'Kuran\'a dair sorularını sor', 'en': 'Ask questions about the Quran', 'ar': 'اسأل عن القرآن', 'fa': 'سوالات خود را بپرسید'},
    'verse_of_day': {'tr': 'Günün Ayeti', 'en': 'Verse of the Day', 'ar': 'آية اليوم', 'fa': 'آیه روز'},
    'time_remaining': {'tr': 'Vaktine Kalan Süre', 'en': 'Time Remaining for', 'ar': 'الوقت المتبقي لـ', 'fa': 'زمان باقی‌مانده تا'},

    // ───── PRAYER TIMES ─────
    'prayer_detail': {'tr': 'Namaz Vakitleri', 'en': 'Prayer Times', 'ar': 'أوقات الصلاة', 'fa': 'اوقات نماز'},
    'change_city': {'tr': 'Değiştir', 'en': 'Change', 'ar': 'تغيير', 'fa': 'تغییر'},
    'select_country': {'tr': 'Ülke Seç', 'en': 'Select Country', 'ar': 'اختر البلد', 'fa': 'انتخاب کشور'},
    'select_city': {'tr': 'Şehir Seç', 'en': 'Select City', 'ar': 'اختر المدينة', 'fa': 'انتخاب شهر'},
    'select_district': {'tr': 'İlçe', 'en': 'District', 'ar': 'المنطقة', 'fa': 'منطقه'},
    'search_city': {'tr': 'Şehir ara...', 'en': 'Search city...', 'ar': 'ابحث عن مدينة...', 'fa': 'جستجوی شهر...'},
    'fajr': {'tr': 'İmsak', 'en': 'Fajr', 'ar': 'الفجر', 'fa': 'فجر'},
    'sunrise': {'tr': 'Güneş', 'en': 'Sunrise', 'ar': 'الشروق', 'fa': 'طلوع'},
    'dhuhr': {'tr': 'Öğle', 'en': 'Dhuhr', 'ar': 'الظهر', 'fa': 'ظهر'},
    'asr': {'tr': 'İkindi', 'en': 'Asr', 'ar': 'العصر', 'fa': 'عصر'},
    'maghrib': {'tr': 'Akşam', 'en': 'Maghrib', 'ar': 'المغرب', 'fa': 'مغرب'},
    'isha': {'tr': 'Yatsı', 'en': 'Isha', 'ar': 'العشاء', 'fa': 'عشاء'},
    'next_prayer': {'tr': 'Sıradaki', 'en': 'Next', 'ar': 'التالي', 'fa': 'بعدی'},
    'nafilah': {'tr': 'Nafile', 'en': 'Voluntary', 'ar': 'نافلة', 'fa': 'نافله'},
    'today': {'tr': 'Bugün', 'en': 'Today', 'ar': 'اليوم', 'fa': 'امروز'},
    'date_picker': {'tr': 'Tarih seç', 'en': 'Pick date', 'ar': 'اختر التاريخ', 'fa': 'انتخاب تاریخ'},

    // ───── WORSHIP TRACKER ─────
    'worship_tracker': {'tr': 'İbadet Takibi', 'en': 'Worship Tracker', 'ar': 'متابعة العبادات', 'fa': 'پیگیری عبادات'},
    'tab_today': {'tr': 'Bugün', 'en': 'Today', 'ar': 'اليوم', 'fa': 'امروز'},
    'tab_qada': {'tr': 'Kaza Takibi', 'en': 'Missed Prayers', 'ar': 'قضاء الصلوات', 'fa': 'نمازهای قضا'},
    'streak': {'tr': 'İstikrar', 'en': 'Streak', 'ar': 'التواصل', 'fa': 'مداومت'},
    'month_total': {'tr': 'Bu Ay Toplam', 'en': 'This Month', 'ar': 'هذا الشهر', 'fa': 'کل این ماه'},
    'daily_worship': {'tr': 'Bugünün Bereketi', 'en': 'Today\'s Worship', 'ar': 'عبادات اليوم', 'fa': 'عبادت امروز'},
    'quran_pages': {'tr': 'Okunan Kur\'an Sayfası', 'en': 'Quran Pages Read', 'ar': 'صفحات القرآن', 'fa': 'صفحات قرآن'},
    'dhikr_count': {'tr': 'Çekilen Zikir Sayısı', 'en': 'Dhikr Count', 'ar': 'عدد الذكر', 'fa': 'تعداد ذکر'},
    'fasting_today': {'tr': 'Bugün Oruçluyum', 'en': 'Fasting Today', 'ar': 'صائم اليوم', 'fa': 'امروز روزه‌ام'},
    'activity_chart': {'tr': 'Aktivite Grafiği', 'en': 'Activity Chart', 'ar': 'مخطط النشاط', 'fa': 'نمودار فعالیت'},
    'week': {'tr': 'Hafta', 'en': 'Week', 'ar': 'أسبوع', 'fa': 'هفته'},
    'month': {'tr': 'Ay', 'en': 'Month', 'ar': 'شهر', 'fa': 'ماه'},
    'total_qada': {'tr': 'Toplam Kaza Namazı', 'en': 'Total Missed Prayers', 'ar': 'مجموع القضاء', 'fa': 'کل نمازهای قضا'},
    'this_week': {'tr': 'Bu Hafta', 'en': 'This Week', 'ar': 'هذا الأسبوع', 'fa': 'این هفته'},
    'this_month': {'tr': 'Bu Ay', 'en': 'This Month', 'ar': 'هذا الشهر', 'fa': 'این ماه'},
    'this_year': {'tr': 'Bu Yıl', 'en': 'This Year', 'ar': 'هذه السنة', 'fa': 'امسال'},
    'all_time': {'tr': 'Tüm Zamanlar', 'en': 'All Time', 'ar': 'كل الوقت', 'fa': 'همه زمان‌ها'},

    // ───── PREMIUM ─────
    'premium_title': {'tr': 'Tefsir AI Premium', 'en': 'Tafsir AI Premium', 'ar': 'تفسير AI المميز', 'fa': 'تفسیر AI ویژه'},
    'premium_monthly': {'tr': 'Aylık', 'en': 'Monthly', 'ar': 'شهري', 'fa': 'ماهانه'},
    'premium_yearly': {'tr': 'Yıllık', 'en': 'Yearly', 'ar': 'سنوي', 'fa': 'سالیانه'},
    'premium_saving': {'tr': 'Tasarruf', 'en': 'Save', 'ar': 'توفير', 'fa': 'صرفه‌جویی'},

    // ───── SETTINGS ─────
    'settings': {'tr': 'Ayarlar', 'en': 'Settings', 'ar': 'الإعدادات', 'fa': 'تنظیمات'},
    'general': {'tr': 'Genel', 'en': 'General', 'ar': 'عام', 'fa': 'عمومی'},
    'notifications': {'tr': 'Bildirimler', 'en': 'Notifications', 'ar': 'الإشعارات', 'fa': 'اعلان‌ها'},
    'language': {'tr': 'Dil', 'en': 'Language', 'ar': 'اللغة', 'fa': 'زبان'},
    'subscription': {'tr': 'Abonelik', 'en': 'Subscription', 'ar': 'الاشتراك', 'fa': 'اشتراک'},
    'manage_sub': {'tr': 'Aboneliği Yönet', 'en': 'Manage Subscription', 'ar': 'إدارة الاشتراك', 'fa': 'مدیریت اشتراک'},
    'restore': {'tr': 'Satın Alımları Geri Yükle', 'en': 'Restore Purchases', 'ar': 'استعادة المشتريات', 'fa': 'بازگردانی خریدها'},
    'feedback': {'tr': 'Geri Bildirim Gönder', 'en': 'Send Feedback', 'ar': 'إرسال ملاحظات', 'fa': 'ارسال بازخورد'},
    'rate': {'tr': 'Uygulamayı Puanla', 'en': 'Rate the App', 'ar': 'تقييم التطبيق', 'fa': 'امتیاز به برنامه'},
    'share': {'tr': 'Paylaş', 'en': 'Share', 'ar': 'مشاركة', 'fa': 'اشتراک‌گذاری'},
    'about': {'tr': 'Hakkında', 'en': 'About', 'ar': 'حول', 'fa': 'درباره'},
    'logout': {'tr': 'Çıkış Yap', 'en': 'Logout', 'ar': 'تسجيل الخروج', 'fa': 'خروج'},
    'profile': {'tr': 'Profil', 'en': 'Profile', 'ar': 'الملف الشخصي', 'fa': 'پروفایل'},
    'edit_profile': {'tr': 'Profili Düzenle', 'en': 'Edit Profile', 'ar': 'تعديل الملف', 'fa': 'ویرایش پروفایل'},
    'guest': {'tr': 'Misafir Kullanıcı', 'en': 'Guest User', 'ar': 'مستخدم ضيف', 'fa': 'کاربر مهمان'},
    'free_account': {'tr': 'Ücretsiz Hesap', 'en': 'Free Account', 'ar': 'حساب مجاني', 'fa': 'حساب رایگان'},
    'premium_account': {'tr': 'Premium Üye', 'en': 'Premium Member', 'ar': 'عضو مميز', 'fa': 'عضو ویژه'},

    // ───── AUTH ─────
    'sign_in': {'tr': 'Giriş Yap', 'en': 'Sign In', 'ar': 'تسجيل الدخول', 'fa': 'ورود'},
    'sign_up': {'tr': 'Kayıt Ol', 'en': 'Sign Up', 'ar': 'إنشاء حساب', 'fa': 'ثبت نام'},
    'email': {'tr': 'E-posta', 'en': 'Email', 'ar': 'البريد الإلكتروني', 'fa': 'ایمیل'},
    'password': {'tr': 'Şifre', 'en': 'Password', 'ar': 'كلمة المرور', 'fa': 'رمز عبور'},
    'name': {'tr': 'Ad Soyad', 'en': 'Full Name', 'ar': 'الاسم الكامل', 'fa': 'نام کامل'},
    'skip': {'tr': 'Şimdilik atla →', 'en': 'Skip for now →', 'ar': 'تخطي ←', 'fa': 'بعداً ←'},
    'google_signin': {'tr': 'Google ile devam et', 'en': 'Continue with Google', 'ar': 'المتابعة مع Google', 'fa': 'ورود با گوگل'},
    'apple_signin': {'tr': 'Apple ile devam et', 'en': 'Continue with Apple', 'ar': 'المتابعة مع Apple', 'fa': 'ورود با اپل'},
    'no_account': {'tr': 'Hesabın yok mu?', 'en': 'Don\'t have an account?', 'ar': 'ليس لديك حساب؟', 'fa': 'حساب ندارید؟'},
    'has_account': {'tr': 'Zaten hesabın var mı?', 'en': 'Already have an account?', 'ar': 'لديك حساب؟', 'fa': 'حساب دارید؟'},

    // ───── AI CHAT ─────
    'ai_question_hint': {'tr': 'Kuran\'a dair bir soru sor...', 'en': 'Ask a question about the Quran...', 'ar': 'اسأل عن القرآن...', 'fa': 'سوال درباره قرآن بپرسید...'},
    'ai_no_access': {'tr': 'AI Tefsir için Premium\'a geç', 'en': 'Get Premium for AI Tafsir', 'ar': 'احصل على المميز للتفسير', 'fa': 'برای تفسیر ویژه شوید'},
    'watch_ad': {'tr': '3 Reklam İzle, 1 Soru Kazan', 'en': 'Watch 3 Ads, Get 1 Question', 'ar': '3 إعلانات = سؤال واحد', 'fa': '۳ تبلیغ = ۱ سوال'},
    'buy_tokens': {'tr': 'Token Paketi Satın Al', 'en': 'Buy Token Pack', 'ar': 'شراء حزمة', 'fa': 'خرید بسته'},
    'questions_earned': {'tr': 'soru hakkın var', 'en': 'questions available', 'ar': 'أسئلة متاحة', 'fa': 'سوال در دسترس'},
    'clear_chat': {'tr': 'Sohbeti Temizle', 'en': 'Clear Chat', 'ar': 'مسح المحادثة', 'fa': 'پاک کردن گفتگو'},

    // ───── ONBOARDING ─────
    'onboard_1_title': {'tr': 'Namaz Vakitleri\nHer An Yanında', 'en': 'Prayer Times\nAlways With You', 'ar': 'أوقات الصلاة\nمعك دائماً', 'fa': 'اوقات نماز\nهمراه شما'},
    'onboard_2_title': {'tr': 'Kuran-ı Kerim\nMushaf Sayfaları', 'en': 'Holy Quran\nMushaf Pages', 'ar': 'القرآن الكريم\nصفحات المصحف', 'fa': 'قرآن کریم\nصفحات مصحف'},
    'onboard_3_title': {'tr': 'Yapay Zeka ile\nTefsir Deneyimi', 'en': 'AI-Powered\nTafsir Experience', 'ar': 'تفسير\nبالذكاء الاصطناعي', 'fa': 'تفسیر\nبا هوش مصنوعی'},
    'onboard_4_title': {'tr': 'İbadet Takibi &\nKaza Sayacı', 'en': 'Worship Tracker &\nMissed Prayer Counter', 'ar': 'متابعة العبادات\nوعداد القضاء', 'fa': 'پیگیری عبادات\nو شمارش قضا'},
    'continue_btn': {'tr': 'Devam', 'en': 'Continue', 'ar': 'متابعة', 'fa': 'ادامه'},
    'start_btn': {'tr': 'Başla', 'en': 'Start', 'ar': 'ابدأ', 'fa': 'شروع'},

    // ───── COMMON ─────
    'cancel': {'tr': 'Vazgeç', 'en': 'Cancel', 'ar': 'إلغاء', 'fa': 'انصراف'},
    'save': {'tr': 'Kaydet', 'en': 'Save', 'ar': 'حفظ', 'fa': 'ذخیره'},
    'delete': {'tr': 'Sil', 'en': 'Delete', 'ar': 'حذف', 'fa': 'حذف'},
    'confirm': {'tr': 'Tamam', 'en': 'OK', 'ar': 'موافق', 'fa': 'باشه'},
    'retry': {'tr': 'Tekrar Dene', 'en': 'Retry', 'ar': 'إعادة', 'fa': 'تلاش مجدد'},
    'day': {'tr': 'Gün', 'en': 'Day', 'ar': 'يوم', 'fa': 'روز'},
    'days': {'tr': 'Gün', 'en': 'Days', 'ar': 'يوم', 'fa': 'روز'},
    'page': {'tr': 'Sayfa', 'en': 'Page', 'ar': 'صفحة', 'fa': 'صفحه'},
    'completed': {'tr': 'Tamamlandı', 'en': 'Completed', 'ar': 'مكتمل', 'fa': 'کامل شد'},
    'not_found': {'tr': 'Sonuç bulunamadı.', 'en': 'No results found.', 'ar': 'لا توجد نتائج.', 'fa': 'نتیجه‌ای یافت نشد.'},
  };
}
