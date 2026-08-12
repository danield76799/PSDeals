import 'package:flutter/material.dart';

/// Centralized PlayStation-inspired theme definition.
///
/// Dark by default: deep navy backgrounds, elevated surface cards, and the
/// signature PlayStation blue accent (#0070d1).
class AppTheme {
  AppTheme._();

  // ── Palette ──────────────────────────────────────────────────────────────
  static const Color background = Color(0xFF0E1017);
  static const Color backgroundAlt = Color(0xFF0E141D);
  static const Color surface = Color(0xFF1F2330);
  static const Color surfaceAlt = Color(0xFF272C3D);
  static const Color accent = Color(0xFF0070D1);
  static const Color accentLight = Color(0xFF2E9BFF);
  static const Color onSurface = Color(0xFFF5F7FA);
  static const Color onSurfaceMuted = Color(0xFF9AA3B2);
  static const Color discountGreen = Color(0xFF2BD96B);
  static const Color psPlus = Color(0xFF0070D1);
  static const Color divider = Color(0xFF2A2F3D);

  static ThemeData get darkTheme {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        brightness: Brightness.dark,
        primary: accent,
        secondary: accentLight,
        surface: surface,
        onSurface: onSurface,
        onSurfaceVariant: onSurfaceMuted,
        error: Color(0xFFE5534B),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 4,
        shadowColor: Colors.black54,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
          color: onSurface,
        ),
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: onSurface,
        ),
        titleMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
        bodyMedium: TextStyle(
          fontSize: 13,
          color: onSurfaceMuted,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: accent,
        inactiveTrackColor: surfaceAlt,
        thumbColor: accentLight,
        overlayColor: accent.withValues(alpha: 0.25),
        trackHeight: 6,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 11),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceAlt,
        selectedColor: accent,
        disabledColor: surfaceAlt,
        labelStyle: const TextStyle(color: onSurface, fontWeight: FontWeight.w600),
        secondarySelectedColor: accent,
        brightness: Brightness.dark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
    );

    return base;
  }
}
