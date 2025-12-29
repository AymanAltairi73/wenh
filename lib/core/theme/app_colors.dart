import 'package:flutter/material.dart';

/// Deep Purple & Indigo High-Tech Color Palette
class AppColors {
  // Primary - Deep Purple
  static const Color primary = Color(0xFF673AB7);
  static const Color primaryDark = Color(0xFF5E35B1);
  static const Color primaryLight = Color(0xFF7E57C2);
  static const Color primaryLighter = Color(0xFF9575CD);

  // Secondary - Indigo
  static const Color secondary = Color(0xFF3F51B5);
  static const Color secondaryDark = Color(0xFF3949AB);
  static const Color secondaryLight = Color(0xFF5C6BC0);
  static const Color secondaryLighter = Color(0xFF7986CB);

  // Accent - Cyan
  static const Color accent = Color(0xFF00BCD4);
  static const Color accentDark = Color(0xFF0097A7);
  static const Color accentLight = Color(0xFF26C6DA);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF81C784);
  static const Color successDark = Color(0xFF388E3C);

  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFB74D);
  static const Color warningDark = Color(0xFFF57C00);

  static const Color error = Color(0xFFF44336);
  static const Color errorLight = Color(0xFFE57373);
  static const Color errorDark = Color(0xFFD32F2F);

  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFF64B5F6);
  static const Color infoDark = Color(0xFF1976D2);

  // Light Mode Backgrounds
  static const Color background = Color(0xFFF5F5F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF8F8FA);

  // Dark Mode Backgrounds
  static const Color backgroundDark = Color(0xFF1A0033);
  static const Color surfaceDark = Color(0xFF2D1B4E);
  static const Color cardDark = Color(0xFF3D2B5E);
  static const Color surfaceVariantDark = Color(0xFF4A3570);

  // Text Colors - Light Mode
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textDisabled = Color(0xFFBDBDBD);

  // Text Colors - Dark Mode
  static const Color textPrimaryDark = Color(0xFFE8E8E8);
  static const Color textSecondaryDark = Color(0xFFB8B8B8);
  static const Color textTertiaryDark = Color(0xFF888888);

  // Dividers
  static const Color divider = Color(0xFFE0E0E0);
  static const Color dividerDark = Color(0xFF4A3570);

  // Glassmorphism
  static const Color glassLight = Color(0x40FFFFFF);
  static const Color glassDark = Color(0x20FFFFFF);
  static const Color glassBorder = Color(0x30FFFFFF);
  static const Color glassBorderLight = Color(0x50FFFFFF);
  static const Color glassBorderDark = Color(0x15FFFFFF);

  // Shimmer Colors
  static const Color shimmerBaseLight = Color(0xFFE0E0E0);
  static const Color shimmerHighlightLight = Color(0xFFF5F5F5);
  static const Color shimmerBaseDark = Color(0xFF2D1B4E);
  static const Color shimmerHighlightDark = Color(0xFF3D2B5E);

  // Shadows
  static const Color cardShadow = Color(0x1A000000);
  static const Color cardShadowDark = Color(0x40000000);

  // Gradients
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

  static LinearGradient purpleIndigoGradient = const LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient backgroundGradient = const LinearGradient(
    colors: [Color(0xFFF5F5F7), Color(0xFFE0D8F0)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static LinearGradient darkBackgroundGradient = const LinearGradient(
    colors: [Color(0xFF0F0021), Color(0xFF1A0033)],
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

  // Shadows
  static BoxShadow cardShadowLight = BoxShadow(
    color: cardShadow,
    blurRadius: 16,
    offset: const Offset(0, 4),
    spreadRadius: 0,
  );

  static BoxShadow softShadow = BoxShadow(
    color: Colors.black.withOpacity(0.05),
    blurRadius: 10,
    offset: const Offset(0, 4),
    spreadRadius: 0,
  );

  static BoxShadow cardShadowMedium = BoxShadow(
    color: cardShadow,
    blurRadius: 24,
    offset: const Offset(0, 8),
    spreadRadius: -2,
  );

  static BoxShadow cardShadowHeavy = BoxShadow(
    color: cardShadow.withOpacity(0.2),
    blurRadius: 40,
    offset: const Offset(0, 20),
    spreadRadius: -10,
  );

  static BoxShadow glowShadow = BoxShadow(
    color: primary.withOpacity(0.4),
    blurRadius: 24,
    offset: const Offset(0, 8),
    spreadRadius: -4,
  );

  static BoxShadow glowShadowDark = BoxShadow(
    color: primaryLight.withOpacity(0.5),
    blurRadius: 32,
    offset: const Offset(0, 10),
    spreadRadius: -6,
  );
}
