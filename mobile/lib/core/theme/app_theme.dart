import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryLight,
        secondary: AppColors.secondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        tertiary: AppColors.tertiary,
        tertiaryContainer: AppColors.tertiaryContainer,
        onTertiaryContainer: AppColors.onTertiaryContainer,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
        outline: AppColors.borderSubtle,
        outlineVariant: AppColors.outlineVariant,
      ),
      scaffoldBackgroundColor: AppColors.background,
    );

    final textTheme = GoogleFonts.plusJakartaSansTextTheme(base.textTheme).copyWith(
      displayLarge: GoogleFonts.plusJakartaSans(fontSize: 30, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
      headlineLarge: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.02 * 24, color: AppColors.textPrimary),
      headlineMedium: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.01 * 20, color: AppColors.textPrimary),
      headlineSmall: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      bodyLarge: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textPrimary),
      bodyMedium: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textPrimary),
      bodySmall: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textSecondary),
      labelLarge: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.01 * 14),
      labelMedium: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.02 * 12),
      labelSmall: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.04 * 10),
    );

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: AppColors.surface.withValues(alpha: 0.9),
        foregroundColor: AppColors.textPrimary,
        titleTextStyle: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderSubtle, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)), // Stitch Pill button
          textStyle: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          minimumSize: const Size(double.infinity, 48),
          side: const BorderSide(color: AppColors.borderSubtle, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
          textStyle: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderSubtle, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderSubtle, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        hintStyle: GoogleFonts.plusJakartaSans(color: AppColors.textMuted, fontSize: 14),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        elevation: 3,
        shadowColor: AppColors.primary.withValues(alpha: 0.08),
        indicatorColor: AppColors.primaryLight,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
              letterSpacing: 0.02 * 12,
            );
          }
          return GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
            letterSpacing: 0.01 * 12,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primaryDark, size: 24);
          }
          return const IconThemeData(color: AppColors.textSecondary, size: 24);
        }),
      ),
    );
  }

  static ThemeData get darkTheme {
    return lightTheme; // Primary focus on Light Theme matching Stitch spec
  }
}
