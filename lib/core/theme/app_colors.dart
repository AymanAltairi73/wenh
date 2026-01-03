import 'package:flutter/material.dart';

/// Modern Professional Color Palette - Vibrant & Attractive
class AppColors {
  // Primary - Modern Teal/Turquoise
  static const Color primary = Color(0xFF00BFA5);
  static const Color primaryDark = Color(0xFF00897B);
  static const Color primaryLight = Color(0xFF26C6DA);
  static const Color primaryLighter = Color(0xFF4DD0E1);

  // Secondary - Deep Orange/Coral
  static const Color secondary = Color(0xFFFF6B35);
  static const Color secondaryDark = Color(0xFFE55100);
  static const Color secondaryLight = Color(0xFFFF8A65);
  static const Color secondaryLighter = Color(0xFFFFAB91);

  // Accent - Purple/Violet
  static const Color accent = Color(0xFF8B5CF6);
  static const Color accentDark = Color(0xFF7C3AED);
  static const Color accentLight = Color(0xFFA78BFA);
  static const Color accentLighter = Color(0xFFC4B5FD);

  // Status Colors - Enhanced
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

  // Light Mode Backgrounds - Modern Clean
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);

  // Dark Mode Backgrounds - Deep Rich
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color cardDark = Color(0xFF334155);
  static const Color surfaceVariantDark = Color(0xFF475569);

  // Text Colors - Light Mode - Enhanced Contrast
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textDisabled = Color(0xFF9CA3AF);

  // Text Colors - Dark Mode - Better Readability
  static const Color textPrimaryDark = Color(0xFFF9FAFB);
  static const Color textSecondaryDark = Color(0xFFD1D5DB);
  static const Color textTertiaryDark = Color(0xFF9CA3AF);

  // Dividers - Modern
  static const Color divider = Color(0xFFE5E7EB);
  static const Color dividerDark = Color(0xFF374151);

  // Glassmorphism - Enhanced
  static const Color glassLight = Color(0x60FFFFFF);
  static const Color glassDark = Color(0x30FFFFFF);
  static const Color glassBorder = Color(0x40FFFFFF);
  static const Color glassBorderLight = Color(0x70FFFFFF);
  static const Color glassBorderDark = Color(0x20FFFFFF);

  // Shimmer Colors - Modern
  static const Color shimmerBaseLight = Color(0xFFF3F4F6);
  static const Color shimmerHighlightLight = Color(0xFFFFFFFF);
  static const Color shimmerBaseDark = Color(0xFF374151);
  static const Color shimmerHighlightDark = Color(0xFF4B5563);

  // Shadows - Professional
  static const Color cardShadow = Color(0x0F000000);
  static const Color cardShadowDark = Color(0x40000000);

  // Gradients - Modern & Vibrant
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
    colors: [primary, secondary, accent],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient backgroundGradient = const LinearGradient(
    colors: [Color(0xFFFAFAFA), Color(0xFFF3F4F6)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static LinearGradient darkBackgroundGradient = const LinearGradient(
    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static LinearGradient darkPrimaryGradient = const LinearGradient(
    colors: [primaryLight, accentLight],
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
