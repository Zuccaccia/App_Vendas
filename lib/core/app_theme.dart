import 'package:flutter/material.dart';

class AppTheme {
  static const Color bg = Color(0xFF0F1923);
  static const Color surface = Color(0xFF1A2535);
  static const Color card = Color(0xFF1E2D40);
  static const Color accent = Color(0xFF00D9A3);
  static const Color accentRed = Color(0xFFFF5C6A);
  static const Color textPrim = Color(0xFFFFFFFF);
  static const Color textSec = Color(0xFF8B9BB4);
  static const Color border = Color(0xFF2A3F58);

  static ThemeData get theme => ThemeData(
    scaffoldBackgroundColor: bg,
    colorScheme: const ColorScheme.dark(primary: accent, surface: surface),
    appBarTheme: const AppBarTheme(
      backgroundColor: bg,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: textPrim,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      iconTheme: IconThemeData(color: textPrim),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surface,
      selectedItemColor: accent,
      unselectedItemColor: textSec,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    cardColor: card,
    dividerColor: border,
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: textPrim),
      bodySmall: TextStyle(color: textSec),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: bg,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: accent, width: 1.5),
      ),
      labelStyle: const TextStyle(color: textSec),
      hintStyle: const TextStyle(color: textSec),
    ),
  );
}
