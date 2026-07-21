import 'package:flutter/material.dart';

/// Central theme definition for BirtaKhabar.
///
/// Primary color evokes urgency/alertness (used for the app's red identity,
/// echoing the "Khabar" masthead style common to Nepali news outlets) with a
/// calm neutral surface for long-form reading.
class AppTheme {
  static const Color primary = Color(0xFFD32F2F); // Birta red
  static const Color primaryDark = Color(0xFF9A0007);
  static const Color emergency = Color(0xFFB00020);
  static const Color accent = Color(0xFF1565C0);
  static const Color background = Color(0xFFF7F7F8);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B6B6B);

  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: primary,
        secondary: accent,
        error: emergency,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: primary,
        unselectedItemColor: textSecondary,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
    );
  }

  static Color categoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'emergency':
        return emergency;
      case 'sports':
        return const Color(0xFF2E7D32);
      case 'business':
        return const Color(0xFFEF6C00);
      case 'events':
        return const Color(0xFF6A1B9A);
      default:
        return accent; // local
    }
  }
}
