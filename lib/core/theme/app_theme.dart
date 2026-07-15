import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      // quran_library paketi Material 2 varsayımıyla çalışıyor;
      // bu satır olmadan Mushaf sayfalarında dizilim/görünüm sorunları
      // oluşabiliyor (paketin kendi belgesinde bu şart açıkça belirtiliyor).
      useMaterial3: false,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.pureBlack, 
      colorScheme: const ColorScheme.dark( // Siyah konsept olduğu için dark şema daha uyumlu çalışır
        primary: AppColors.gold,
        secondary: AppColors.gold,
        surface: AppColors.surface,
        surfaceContainerLowest: AppColors.background,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.textLight),
        bodyMedium: TextStyle(color: AppColors.textLight),
        bodySmall: TextStyle(color: AppColors.textLight),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background, 
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.gold),
        titleTextStyle: TextStyle(
          color: AppColors.gold,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface, 
        selectedItemColor: AppColors.gold,
        unselectedItemColor: AppColors.textLightMuted, 
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
      ),
    );
  }
}