import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme/app_colors.dart';

enum AppTheme { light, dark }

class ThemeState {
  final ThemeData themeData;
  final AppTheme appTheme;
  final bool isDark;

  ThemeState({required this.themeData, required this.appTheme})
    : isDark = appTheme == AppTheme.dark;

  ThemeState copyWith({ThemeData? themeData, AppTheme? appTheme}) {
    return ThemeState(
      themeData: themeData ?? this.themeData,
      appTheme: appTheme ?? this.appTheme,
    );
  }
}

class ThemeCubit extends Cubit<ThemeState> {
  static const String _themeKey = 'app_theme';

  ThemeCubit() : super(_getLightTheme()) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_themeKey) ?? false;
    if (isDark) {
      emit(_getDarkTheme());
    } else {
      emit(_getLightTheme());
    }
  }

  Future<void> _saveTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDark);
  }

  static ThemeState _getLightTheme() {
    return ThemeState(
      themeData: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.background,

        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          tertiary: AppColors.accent,
          surface: AppColors.surface,
          background: AppColors.background,
          error: AppColors.error,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: AppColors.textPrimary,
          onBackground: AppColors.textPrimary,
        ),

        appBarTheme: AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.textPrimary,
          iconTheme: const IconThemeData(color: AppColors.primary),
          titleTextStyle: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        cardTheme: CardThemeData(
          elevation: 0,
          color: AppColors.surface,
          shadowColor: AppColors.cardShadow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.antiAlias,
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 6,
            shadowColor: AppColors.primary.withOpacity(0.25),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ),

        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceVariant,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColors.divider.withOpacity(0.2)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColors.divider.withOpacity(0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.error, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.error, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.6)),
          labelStyle: const TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),

        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        ),

        textTheme: const TextTheme(
          displayLarge: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            letterSpacing: -1,
            height: 1.2,
          ),
          displayMedium: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
            height: 1.2,
          ),
          displaySmall: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
          headlineLarge: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
          headlineMedium: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
          headlineSmall: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
          titleLarge: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
          titleMedium: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          titleSmall: TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          bodyLarge: TextStyle(color: AppColors.textPrimary, height: 1.5),
          bodyMedium: TextStyle(color: AppColors.textSecondary, height: 1.5),
          bodySmall: TextStyle(color: AppColors.textSecondary, height: 1.5),
          labelLarge: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
          labelMedium: TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
          labelSmall: TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),

        iconTheme: const IconThemeData(color: AppColors.primary),
        dividerColor: AppColors.divider,
        dividerTheme: const DividerThemeData(
          color: AppColors.divider,
          thickness: 1,
          space: 1,
        ),
      ),
      appTheme: AppTheme.light,
    );
  }

  static ThemeState _getDarkTheme() {
    return ThemeState(
      themeData: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.backgroundDark,

        colorScheme: ColorScheme.dark(
          primary: AppColors.primaryLight,
          secondary: AppColors.secondaryLight,
          tertiary: AppColors.accentLight,
          surface: AppColors.surfaceDark,
          background: AppColors.backgroundDark,
          error: AppColors.errorLight,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: AppColors.textPrimaryDark,
          onBackground: AppColors.textPrimaryDark,
        ),

        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: AppColors.surfaceDark,
          foregroundColor: AppColors.textPrimaryDark,
          iconTheme: IconThemeData(color: AppColors.accentLight),
          titleTextStyle: TextStyle(
            color: AppColors.textPrimaryDark,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        cardTheme: CardThemeData(
          elevation: 0,
          color: AppColors.cardDark,
          shadowColor: AppColors.cardShadowDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.antiAlias,
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryLight,
            foregroundColor: Colors.white,
            elevation: 8,
            shadowColor: AppColors.primaryLight.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ),

        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: Colors.white,
          elevation: 16,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceVariantDark,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppColors.dividerDark.withOpacity(0.3),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppColors.dividerDark.withOpacity(0.3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AppColors.accentLight,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.errorLight, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AppColors.errorLight,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          hintStyle: TextStyle(
            color: AppColors.textTertiaryDark.withOpacity(0.6),
          ),
          labelStyle: const TextStyle(
            color: AppColors.textSecondaryDark,
            fontWeight: FontWeight.w600,
          ),
        ),

        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.surfaceDark,
          selectedItemColor: AppColors.accentLight,
          unselectedItemColor: AppColors.textTertiaryDark,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        ),

        textTheme: const TextTheme(
          displayLarge: TextStyle(
            color: AppColors.textPrimaryDark,
            fontWeight: FontWeight.bold,
            letterSpacing: -1,
            height: 1.2,
          ),
          displayMedium: TextStyle(
            color: AppColors.textPrimaryDark,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
            height: 1.2,
          ),
          displaySmall: TextStyle(
            color: AppColors.textPrimaryDark,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
          headlineLarge: TextStyle(
            color: AppColors.textPrimaryDark,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
          headlineMedium: TextStyle(
            color: AppColors.textPrimaryDark,
            fontWeight: FontWeight.w700,
          ),
          headlineSmall: TextStyle(
            color: AppColors.textPrimaryDark,
            fontWeight: FontWeight.w700,
          ),
          titleLarge: TextStyle(
            color: AppColors.textPrimaryDark,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
          titleMedium: TextStyle(
            color: AppColors.textPrimaryDark,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          titleSmall: TextStyle(
            color: AppColors.textSecondaryDark,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          bodyLarge: TextStyle(color: AppColors.textPrimaryDark, height: 1.5),
          bodyMedium: TextStyle(
            color: AppColors.textSecondaryDark,
            height: 1.5,
          ),
          bodySmall: TextStyle(color: AppColors.textTertiaryDark, height: 1.5),
          labelLarge: TextStyle(
            color: AppColors.textPrimaryDark,
            fontWeight: FontWeight.w700,
          ),
          labelMedium: TextStyle(
            color: AppColors.textSecondaryDark,
            fontWeight: FontWeight.w500,
          ),
          labelSmall: TextStyle(
            color: AppColors.textTertiaryDark,
            fontWeight: FontWeight.w500,
          ),
        ),

        iconTheme: const IconThemeData(color: AppColors.accentLight),
        dividerColor: AppColors.dividerDark,
        dividerTheme: const DividerThemeData(
          color: AppColors.dividerDark,
          thickness: 1,
          space: 1,
        ),
      ),
      appTheme: AppTheme.dark,
    );
  }

  void toggleTheme() {
    if (state.appTheme == AppTheme.light) {
      emit(_getDarkTheme());
      _saveTheme(true);
    } else {
      emit(_getLightTheme());
      _saveTheme(false);
    }
  }

  void setTheme(AppTheme theme) {
    if (theme == AppTheme.light) {
      emit(_getLightTheme());
      _saveTheme(false);
    } else {
      emit(_getDarkTheme());
      _saveTheme(true);
    }
  }
}
