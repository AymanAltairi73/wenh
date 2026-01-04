import 'package:flutter/material.dart';

/// Logo-Based Color Palette - Blue & Orange Professional Theme
class AppColors {
  // Primary - Deep Blue (from logo background)
  static const Color primary = Color(0xFF1E3A8A);
  static const Color primaryDark = Color(0xFF1E40AF);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryLighter = Color(0xFF60A5FA);

  // Secondary - Orange/Amber (from logo border)
  static const Color secondary = Color(0xFFF97316);
  static const Color secondaryDark = Color(0xFFEA580C);
  static const Color secondaryLight = Color(0xFFFB923C);
  static const Color secondaryLighter = Color(0xFFFED7AA);

  // Accent - Light Blue (from logo inner background)
  static const Color accent = Color(0xFFDBEAFE);
  static const Color accentDark = Color(0xFF93C5FD);
  static const Color accentLight = Color(0xFFEFF6FF);
  static const Color accentLighter = Color(0xFFFFFFFF);

  // Status Colors - Enhanced with theme consistency
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF34D399);
  static const Color successDark = Color(0xFF059669);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFCD34D);
  static const Color warningDark = Color(0xFFD97706);

  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFF87171);
  static const Color errorDark = Color(0xFFDC2626);

  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF60A5FA);
  static const Color infoDark = Color(0xFF2563EB);

  // Light Mode Backgrounds - Clean & Professional
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);

  // Dark Mode Backgrounds - Deep Blue Theme
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color cardDark = Color(0xFF334155);
  static const Color surfaceVariantDark = Color(0xFF475569);

  // Text Colors - Light Mode - Enhanced Contrast
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textDisabled = Color(0xFF94A3B8);

  // Text Colors - Dark Mode - Better Readability
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFFCBD5E1);
  static const Color textTertiaryDark = Color(0xFF94A3B8);

  // Dividers - Modern
  static const Color divider = Color(0xFFE2E8F0);
  static const Color dividerDark = Color(0xFF334155);

  // Glassmorphism - Enhanced
  static const Color glassLight = Color(0x60FFFFFF);
  static const Color glassDark = Color(0x30FFFFFF);
  static const Color glassBorder = Color(0x40FFFFFF);
  static const Color glassBorderLight = Color(0x70FFFFFF);
  static const Color glassBorderDark = Color(0x20FFFFFF);

  // Shimmer Colors - Modern
  static const Color shimmerBaseLight = Color(0xFFF1F5F9);
  static const Color shimmerHighlightLight = Color(0xFFFFFFFF);
  static const Color shimmerBaseDark = Color(0xFF334155);
  static const Color shimmerHighlightDark = Color(0xFF475569);

  // Shadows - Professional
  static const Color cardShadow = Color(0x0F000000);
  static const Color cardShadowDark = Color(0x40000000);

  // Gradients - Logo-Inspired
  static LinearGradient primaryGradient = const LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient secondaryGradient = const LinearGradient(
    colors: [secondary, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient accentGradient = const LinearGradient(
    colors: [accent, accentLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient vibrantGradient = const LinearGradient(
    colors: [primary, secondary, primaryLight],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient logoGradient = const LinearGradient(
    colors: [Color(0xFF1E3A8A), Color(0xFFF97316)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient backgroundGradient = const LinearGradient(
    colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static LinearGradient darkBackgroundGradient = const LinearGradient(
    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static LinearGradient darkPrimaryGradient = const LinearGradient(
    colors: [primaryLight, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient shimmerGradient = const LinearGradient(
    colors: [shimmerBaseLight, shimmerHighlightLight, shimmerBaseLight],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment(-1.0, 0.0),
    end: Alignment(1.0, 0.0),
  );

  static LinearGradient shimmerGradientDark = const LinearGradient(
    colors: [shimmerBaseDark, shimmerHighlightDark, shimmerBaseDark],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment(-1.0, 0.0),
    end: Alignment(1.0, 0.0),
  );

  // Shadows - Enhanced Professional
  static BoxShadow cardShadowLight = BoxShadow(
    color: cardShadow,
    blurRadius: 20,
    offset: const Offset(0, 8),
    spreadRadius: 0,
  );

  static BoxShadow softShadow = BoxShadow(
    color: Colors.black.withOpacity(0.04),
    blurRadius: 15,
    offset: const Offset(0, 4),
    spreadRadius: 0,
  );

  static BoxShadow cardShadowMedium = BoxShadow(
    color: cardShadow,
    blurRadius: 30,
    offset: const Offset(0, 12),
    spreadRadius: -4,
  );

  static BoxShadow cardShadowHeavy = BoxShadow(
    color: cardShadow.withOpacity(0.15),
    blurRadius: 50,
    offset: const Offset(0, 25),
    spreadRadius: -15,
  );

  static BoxShadow glowShadow = BoxShadow(
    color: primary.withOpacity(0.3),
    blurRadius: 30,
    offset: const Offset(0, 12),
    spreadRadius: -5,
  );

  static BoxShadow glowShadowDark = BoxShadow(
    color: primaryLight.withOpacity(0.4),
    blurRadius: 40,
    offset: const Offset(0, 15),
    spreadRadius: -8,
  );

  // Additional Modern Shadows
  static BoxShadow coloredShadow = BoxShadow(
    color: secondary.withOpacity(0.25),
    blurRadius: 25,
    offset: const Offset(0, 10),
    spreadRadius: -3,
  );

  static BoxShadow accentShadow = BoxShadow(
    color: accent.withOpacity(0.2),
    blurRadius: 35,
    offset: const Offset(0, 15),
    spreadRadius: -5,
  );
}
