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
    return ThemeState(
      themeData: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
        ),
        cardTheme: CardThemeData(
          elevation: 6,
          shadowColor: Colors.black.withOpacity(0.3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.teal.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.teal.shade300, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade800,
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
