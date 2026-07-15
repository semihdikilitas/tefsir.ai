import 'package:flutter/material.dart';

class AppColors {
  // ANA ZEMİN: OLED Siyahı ve Çok Koyu Antrasit
  static const Color pureBlack = Color(0xFF000000); // Saf siyah
  static const Color surfaceDark = Color(0xFF0A0A0A); // Siyaha çok yakın koyu gri yüzey
  static const Color surfaceElevated = Color(0xFF141414); // Kartlar için bir tık açık yüzey

  static const Color gold = Color(0xFFD4AF37);
  static const Color primaryButton = Color(0xFFD4AF37); 
  
  static const Color error = Color(0xFFD90429);
  static const Color success = Color(0xFF2A9D8F);

  // EKRAN TEMALARI — her ekrana özel vurgu renkleri, altın ile uyumlu
  static const Color trackerAmberLight = Color(0xFFFFB74D);

  // PREMIUM GOLD GRADIENT (Değişmedi, siyah üstünde çok daha iyi parlayacak)
  static const Gradient premiumGoldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFC9A227), 
      Color(0xFFFDF3C7), 
      Color(0xFFD4AF37), 
      Color(0xFFFCEFB4), 
      Color(0xFFB8901F), 
    ],
    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
  );

  // Atamalar
  static const Color background = pureBlack;
  static const Color surface = surfaceDark;
  
  static const Color textDark = Color(0xFF000000); // Açık zeminler için
  static const Color textLight = Color(0xFFF0EAD6); // Kırık beyaz / Fildişi (Siyah üstünde göz yormaz)
  static const Color textLightMuted = Color(0x8AF0EAD6);

  static const Color surfaceCard = surfaceElevated; 

  // Siyah zemin üzerinde radial gradient (Çok hafif bir merkez ışığı)
  static const Gradient backgroundGradient = RadialGradient(
    center: Alignment(0, -0.4),
    radius: 1.5,
    colors: [
      Color(0xFF0F0F0F), // Merkezde çok hafif bir antrasit aydınlığı
      pureBlack,         // Kenarlara doğru zifiri karanlık
    ],
    stops: [0.0, 1.0],
  );

  // Buton Gradient'i (Saf siyah ile gold uyumu)
  static const Gradient blackGoldButtonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF050505), 
      Color(0xFF1A1710), 
      Color(0xFFD4AF37), 
    ],
    stops: [0.0, 0.25, 1.0],
  );
}