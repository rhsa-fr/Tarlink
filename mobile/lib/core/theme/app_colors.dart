import 'package:flutter/material.dart';

/// App color palette synchronized with Google Stitch 'TarlingKu Cultural Booking System' design tokens.
class AppColors {
  AppColors._();

  // Primary: Terracotta Red (vitality, celebration, Keraton brickwork)
  static const Color primary = Color(0xFFBD4024);
  static const Color primaryDark = Color(0xFF9B280E);
  static const Color primaryLight = Color(0xFFFFDAD2);
  static const Color primaryContainer = Color(0xFFBD4024);
  static const Color onPrimary = Colors.white;

  // Secondary: Heritage Ochre Gold (prestige, artistic excellence, royal troupe)
  static const Color secondary = Color(0xFFD4A017);
  static const Color secondaryDark = Color(0xFF795900);
  static const Color secondaryLight = Color(0xFFFFDFA0);
  static const Color secondaryContainer = Color(0xFFFFC641);
  static const Color onSecondaryContainer = Color(0xFF715300);

  // Tertiary: Tropical Palm Forest Green (confirmed dates, available status)
  static const Color tertiary = Color(0xFF2D6A4F);
  static const Color tertiaryDark = Color(0xFF1F5D43);
  static const Color tertiaryContainer = Color(0xFF3A765A);
  static const Color onTertiaryContainer = Color(0xFFBAFBD8);

  // Surface & Canvas (Pari Warm Cream & Pure White Cards)
  static const Color background = Color(0xFFF9F8F6);
  static const Color surface = Color(0xFFF8F9FF);
  static const Color card = Colors.white;
  static const Color surfaceContainer = Color(0xFFECEEF4);
  static const Color surfaceContainerLow = Color(0xFFF2F3FA);
  static const Color surfaceContainerHigh = Color(0xFFE6E8EF);

  // Text Colors (Neutral Core: Rich Charcoal, WCAG AA compliant)
  static const Color textPrimary = Color(0xFF191C21);
  static const Color textSecondary = Color(0xFF59413C);
  static const Color textMuted = Color(0xFF8C716B);

  // Material 3 Stitch Palette Aliases
  static const Color onSurface = Color(0xFF191C21);
  static const Color onSurfaceVariant = Color(0xFF59413C);
  static const Color surfaceContainerLowest = Colors.white;
  static const Color surfaceContainerHighest = Color(0xFFE1E2E9);
  static const Color onPrimaryContainer = Color(0xFFFFE7E2);
  static const Color tertiaryFixed = Color(0xFFB1F0CE);
  static const Color onTertiaryFixed = Color(0xFF002114);
  static const Color secondaryFixed = Color(0xFFFFDFA0);
  static const Color onSecondaryFixed = Color(0xFF261A00);

  // Elevation Aliases
  static const List<BoxShadow> elevation1 = elevationLevel1;
  static const List<BoxShadow> elevation2 = elevationLevel2;
  static const List<BoxShadow> elevation3 = elevationLevel3;

  // Borders & Outlines
  static const Color outline = Color(0xFF8C716B);
  static const Color outlineVariant = Color(0xFFE0BFB8);
  static const Color borderSubtle = Color(0xFFE8E5DF);

  // Status Colors
  static const Color success = Color(0xFF2D6A4F); // Jadwal Hijau Tersedia
  static const Color error = Color(0xFFBA1A1A);   // Jadwal Merah Terisi
  static const Color warning = Color(0xFFD4A017); // Menunggu Pembayaran DP
  static const Color info = Color(0xFF1B3B6F);

  // Stitch Elevation Shadows
  static const List<BoxShadow> elevationLevel1 = [
    BoxShadow(
      color: Color(0x0B22252A),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x08BD4024),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> elevationLevel2 = [
    BoxShadow(
      color: Color(0x1422252A),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> elevationLevel3 = [
    BoxShadow(
      color: Color(0x1222252A),
      blurRadius: 20,
      offset: Offset(0, -6),
    ),
  ];
}
