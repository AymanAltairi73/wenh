import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage authentication storage preferences
/// Handles Remember Me functionality securely
class AuthStorageService {
  static const String _rememberMeKey = 'remember_me';
  static const String _userTypeKey = 'user_type';
  static const String _userEmailKey = 'user_email';

  /// Save Remember Me preference along with user type
  Future<void> setRememberMe({
    required bool value,
    required String userType,
    String? email,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_rememberMeKey, value);

      if (value) {
        // Only store user type and email if Remember Me is enabled
        await prefs.setString(_userTypeKey, userType);
        if (email != null) {
          await prefs.setString(_userEmailKey, email);
        }
      } else {
        // Clear stored data if Remember Me is disabled
        await prefs.remove(_userTypeKey);
        await prefs.remove(_userEmailKey);
      }
    } catch (e) {
      // Silent fail - not critical
      print('[AuthStorageService] Error saving Remember Me: $e');
    }
  }

  /// Get Remember Me preference
  Future<bool> getRememberMe() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_rememberMeKey) ?? false;
    } catch (e) {
      print('[AuthStorageService] Error getting Remember Me: $e');
      return false;
    }
  }

  /// Get stored user type (worker, admin, customer)
  Future<String?> getUserType() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userTypeKey);
    } catch (e) {
      print('[AuthStorageService] Error getting user type: $e');
      return null;
    }
  }

  /// Get stored user email
  Future<String?> getUserEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userEmailKey);
    } catch (e) {
      print('[AuthStorageService] Error getting user email: $e');
      return null;
    }
  }

  /// Clear all stored authentication preferences
  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_rememberMeKey);
      await prefs.remove(_userTypeKey);
      await prefs.remove(_userEmailKey);
    } catch (e) {
      print('[AuthStorageService] Error clearing preferences: $e');
    }
  }

  /// Check if user should auto-login
  Future<bool> shouldAutoLogin() async {
    try {
      final rememberMe = await getRememberMe();
      final userType = await getUserType();
      return rememberMe && userType != null;
    } catch (e) {
      print('[AuthStorageService] Error checking auto-login: $e');
      return false;
    }
  }
}
