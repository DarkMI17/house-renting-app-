import 'package:flutter/material.dart';

class AppTheme {
  static const Color fairouzi = Color(0xFF009688);   // الفيروزي (المسيطر)
  static const Color tootie = Color(0xFF2DDFCD);     // العنابي
  static const Color beige = Color(0xFFFFFFFF);      // البيج
  static const Color dustyRose = Color(0xFF351719);  // الوردي الترابي

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      // الـ seedColor يخبر فلاتر: "اشتق كل ألوانك من الفيروزي وليس البنفسجي"
      colorScheme: ColorScheme.fromSeed(
        seedColor: fairouzi,
        primary: fairouzi,
        secondary: tootie,
        surface: beige,
        error: const Color(0xFFBA1A1A), // لون أحمر صريح للخطأ
      ),
      fontFamily: 'BellotaText',
      scaffoldBackgroundColor: beige,
      appBarTheme: const AppBarTheme(
        backgroundColor: fairouzi,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: fairouzi,
        brightness: Brightness.dark,
        primary: fairouzi,
        secondary: const Color(0xFF2DDFCD),
        surface: const Color(0xFF1A1A1A), // أسود مخفف للوضع الداكن
      ),
      fontFamily: 'BellotaText',
      scaffoldBackgroundColor: const Color(0xFF1A1A1A),
    );
  }
}