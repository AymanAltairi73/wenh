import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryDark = Color(0xFF5A52E0);
  static const Color primaryLight = Color(0xFF8B85FF);
  
  static const Color secondary = Color(0xFF00D9C0);
  static const Color secondaryDark = Color(0xFF00B8A3);
  static const Color secondaryLight = Color(0xFF33E3CE);
  
  static const Color accent = Color(0xFFFF6B9D);
  static const Color accentDark = Color(0xFFE5527D);
  static const Color accentLight = Color(0xFFFF8FB3);
  
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
  
  static const Color background = Color(0xFFF8F9FA);
  static const Color backgroundDark = Color(0xFF1A1A2E);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF16213E);
  
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFFBDBDBD);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  
  static const Color divider = Color(0xFFE0E0E0);
  static const Color dividerDark = Color(0xFF424242);
  
  static const Color cardShadow = Color(0x1A000000);
  
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
  
  static LinearGradient backgroundGradient = const LinearGradient(
    colors: [Color(0xFFF8F9FA), Color(0xFFE8EAF6)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static LinearGradient darkBackgroundGradient = const LinearGradient(
    colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static BoxShadow cardShadowLight = BoxShadow(
    color: cardShadow,
    blurRadius: 12,
    offset: const Offset(0, 4),
    spreadRadius: 0,
  );
  
  static BoxShadow cardShadowMedium = BoxShadow(
    color: cardShadow,
    blurRadius: 20,
    offset: const Offset(0, 8),
    spreadRadius: 0,
  );
  
  static BoxShadow cardShadowHeavy = BoxShadow(
    color: cardShadow.withOpacity(0.15),
    blurRadius: 30,
    offset: const Offset(0, 12),
    spreadRadius: 0,
  );
}
