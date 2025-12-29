import 'package:flutter/material.dart';
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
        
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.textPrimary,
          iconTheme: IconThemeData(color: AppColors.primary),
          titleTextStyle: TextStyle(
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
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 4,
            shadowColor: AppColors.primary.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceVariant,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.divider),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          hintStyle: const TextStyle(color: AppColors.textSecondary),
          labelStyle: const TextStyle(color: AppColors.textSecondary),
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
          displayLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          displayMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          displaySmall: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          headlineLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
          headlineSmall: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
          titleLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
          titleSmall: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
          bodyLarge: TextStyle(color: AppColors.textPrimary),
          bodyMedium: TextStyle(color: AppColors.textSecondary),
          bodySmall: TextStyle(color: AppColors.textSecondary),
          labelLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
          labelMedium: TextStyle(color: AppColors.textSecondary),
          labelSmall: TextStyle(color: AppColors.textSecondary),
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
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryLight,
            foregroundColor: Colors.white,
            elevation: 6,
            shadowColor: AppColors.primaryLight.withOpacity(0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: Colors.white,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceVariantDark,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.dividerDark),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.dividerDark),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.accentLight, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.errorLight),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.errorLight, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          hintStyle: const TextStyle(color: AppColors.textTertiaryDark),
          labelStyle: const TextStyle(color: AppColors.textSecondaryDark),
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
          displayLarge: TextStyle(color: AppColors.textPrimaryDark, fontWeight: FontWeight.bold),
          displayMedium: TextStyle(color: AppColors.textPrimaryDark, fontWeight: FontWeight.bold),
          displaySmall: TextStyle(color: AppColors.textPrimaryDark, fontWeight: FontWeight.bold),
          headlineLarge: TextStyle(color: AppColors.textPrimaryDark, fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(color: AppColors.textPrimaryDark, fontWeight: FontWeight.w600),
          headlineSmall: TextStyle(color: AppColors.textPrimaryDark, fontWeight: FontWeight.w600),
          titleLarge: TextStyle(color: AppColors.textPrimaryDark, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(color: AppColors.textPrimaryDark, fontWeight: FontWeight.w500),
          titleSmall: TextStyle(color: AppColors.textSecondaryDark, fontWeight: FontWeight.w500),
          bodyLarge: TextStyle(color: AppColors.textPrimaryDark),
          bodyMedium: TextStyle(color: AppColors.textSecondaryDark),
          bodySmall: TextStyle(color: AppColors.textTertiaryDark),
          labelLarge: TextStyle(color: AppColors.textPrimaryDark, fontWeight: FontWeight.w600),
          labelMedium: TextStyle(color: AppColors.textSecondaryDark),
          labelSmall: TextStyle(color: AppColors.textTertiaryDark),
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
