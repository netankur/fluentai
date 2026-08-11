import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static TextTheme _applyGoogleFont(String family, TextTheme baseTheme) {
    switch (family.toLowerCase()) {
      case 'poppins':
        return GoogleFonts.poppinsTextTheme(baseTheme);
      case 'roboto':
        return GoogleFonts.robotoTextTheme(baseTheme);
      case 'outfit':
        return GoogleFonts.outfitTextTheme(baseTheme);
      case 'lora':
        return GoogleFonts.loraTextTheme(baseTheme);
      case 'inter':
      default:
        return GoogleFonts.interTextTheme(baseTheme);
    }
  }

  static ThemeData createTheme({
    required Brightness brightness,
    required Color primaryColor,
    required String fontFamily,
    required double textScaleFactor,
  }) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: brightness,
      primary: primaryColor,
      surface: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      onSurface: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
    );

    final baseTextTheme =
        isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme;
    final fontAppliedTheme = _applyGoogleFont(fontFamily, baseTextTheme);

    final scaledTextTheme = fontAppliedTheme.copyWith(
      displayLarge: fontAppliedTheme.displayLarge?.copyWith(fontSize: (fontAppliedTheme.displayLarge?.fontSize ?? 57) * textScaleFactor, fontWeight: FontWeight.bold),
      displayMedium: fontAppliedTheme.displayMedium?.copyWith(fontSize: (fontAppliedTheme.displayMedium?.fontSize ?? 45) * textScaleFactor, fontWeight: FontWeight.bold),
      displaySmall: fontAppliedTheme.displaySmall?.copyWith(fontSize: (fontAppliedTheme.displaySmall?.fontSize ?? 36) * textScaleFactor, fontWeight: FontWeight.bold),
      headlineLarge: fontAppliedTheme.headlineLarge?.copyWith(fontSize: (fontAppliedTheme.headlineLarge?.fontSize ?? 32) * textScaleFactor, fontWeight: FontWeight.w800, letterSpacing: -0.5),
      headlineMedium: fontAppliedTheme.headlineMedium?.copyWith(fontSize: (fontAppliedTheme.headlineMedium?.fontSize ?? 28) * textScaleFactor, fontWeight: FontWeight.w700, letterSpacing: -0.5),
      headlineSmall: fontAppliedTheme.headlineSmall?.copyWith(fontSize: (fontAppliedTheme.headlineSmall?.fontSize ?? 24) * textScaleFactor, fontWeight: FontWeight.w700),
      titleLarge: fontAppliedTheme.titleLarge?.copyWith(fontSize: (fontAppliedTheme.titleLarge?.fontSize ?? 20) * textScaleFactor, fontWeight: FontWeight.w700),
      titleMedium: fontAppliedTheme.titleMedium?.copyWith(fontSize: (fontAppliedTheme.titleMedium?.fontSize ?? 16) * textScaleFactor, fontWeight: FontWeight.w600),
      titleSmall: fontAppliedTheme.titleSmall?.copyWith(fontSize: (fontAppliedTheme.titleSmall?.fontSize ?? 14) * textScaleFactor, fontWeight: FontWeight.w600),
      bodyLarge: fontAppliedTheme.bodyLarge?.copyWith(fontSize: (fontAppliedTheme.bodyLarge?.fontSize ?? 16) * textScaleFactor, height: 1.5),
      bodyMedium: fontAppliedTheme.bodyMedium?.copyWith(fontSize: (fontAppliedTheme.bodyMedium?.fontSize ?? 14) * textScaleFactor, height: 1.5),
      bodySmall: fontAppliedTheme.bodySmall?.copyWith(fontSize: (fontAppliedTheme.bodySmall?.fontSize ?? 12) * textScaleFactor),
      labelLarge: fontAppliedTheme.labelLarge?.copyWith(fontSize: (fontAppliedTheme.labelLarge?.fontSize ?? 14) * textScaleFactor, fontWeight: FontWeight.w600),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isDark ? const Color(0xFF090D16) : const Color(0xFFF8FAFC),
      textTheme: scaledTextTheme,
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        color: isDark ? const Color(0xFF131C2E) : Colors.white,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : const Color(0xFF0F172A)),
        titleTextStyle: scaledTextTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
          color: isDark ? Colors.white : const Color(0xFF0F172A),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: scaledTextTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF131C2E) : const Color(0xFFF1F5F9),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        side: BorderSide.none,
        backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
      ),
    );
  }
}
