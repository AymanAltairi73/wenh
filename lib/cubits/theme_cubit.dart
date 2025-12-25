import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black87,
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.teal),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.teal, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
      appTheme: AppTheme.light,
    );
  }

  static ThemeState _getDarkTheme() {
    const darkBackground = Color(0xFF0F1419);
    const darkSurface = Color(0xFF1A1F26);
    const darkCard = Color(0xFF252D38);
    const tealAccent = Color(0xFF4DD0E1);
    const tealPrimary = Color(0xFF26A69A);
    
    return ThemeState(
      themeData: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: darkBackground,
        colorScheme: ColorScheme.dark(
          primary: tealPrimary,
          secondary: tealAccent,
          surface: darkSurface,
          background: darkBackground,
          error: const Color(0xFFEF5350),
          onPrimary: Colors.white,
          onSecondary: Colors.black,
          onSurface: const Color(0xFFE1E3E6),
          onBackground: const Color(0xFFE1E3E6),
          onError: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: darkSurface,
          foregroundColor: Colors.white,
          iconTheme: IconThemeData(color: tealAccent),
        ),
        cardTheme: CardThemeData(
          color: darkCard,
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: tealPrimary,
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF37474F)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF37474F)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: tealAccent, width: 2),
          ),
          filled: true,
          fillColor: const Color(0xFF1E2329),
          labelStyle: const TextStyle(color: Color(0xFFB0BEC5)),
          hintStyle: const TextStyle(color: Color(0xFF78909C)),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFFE1E3E6)),
          bodyMedium: TextStyle(color: Color(0xFFB0BEC5)),
          bodySmall: TextStyle(color: Color(0xFF78909C)),
          titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          titleMedium: TextStyle(color: Colors.white),
          titleSmall: TextStyle(color: Color(0xFFB0BEC5)),
        ),
        iconTheme: const IconThemeData(color: tealAccent),
        dividerColor: const Color(0xFF37474F),
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
