import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Kunci untuk status login pengguna
class PrefsHelper {
  static const String keyIsLoggedIn = 'isLoggedIn';

  static const String keyUserRole = 'userRole';

  static const String keyUsername = 'username';

  static const String keyUserEmail = 'userEmail';

  static const String keyThemeMode = 'themeMode';

  static const String keyLastLoginTime = 'lastLoginTime';

  static const String keyLanguage = 'language';

  static const String keyNotificationsEnabled = 'notificationsEnabled';

  static const String keyAppVersion = 'appVersion';

  static const String keyLastSyncTime = 'lastSyncTime';

  static const String keyUserId = 'userId';

  static const String keyCartTotal = 'cartTotal';

  static Future<void> saveLoginData(
    String username,
    String email,
    String role, {
    String? userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyIsLoggedIn, true);
    await prefs.setString(keyUserRole, role);
    await prefs.setString(keyUsername, username);
    await prefs.setString(keyUserEmail, email);
    await prefs.setString(keyLastLoginTime, DateTime.now().toIso8601String());
    if (userId != null) {
      await prefs.setString(keyUserId, userId);
    }

    // Set nilai default jika belum ada
    if (!prefs.containsKey(keyThemeMode)) {
      await prefs.setString(keyThemeMode, 'light');
    }
    if (!prefs.containsKey(keyLanguage)) {
      await prefs.setString(keyLanguage, 'en');
    }
    if (!prefs.containsKey(keyNotificationsEnabled)) {
      await prefs.setBool(keyNotificationsEnabled, true);
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyIsLoggedIn, false);
    await prefs.remove(keyUserRole);
    await prefs.remove(keyUsername);
    await prefs.remove(keyUserEmail);
    await prefs.remove(keyUserId);
    await prefs.remove(keyLastLoginTime);
  }

  static Future<Map<String, dynamic>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final themeMode = await getTheme();
    return {
      keyIsLoggedIn: prefs.getBool(keyIsLoggedIn) ?? false,
      keyUserRole: prefs.getString(keyUserRole) ?? '',
      keyUsername: prefs.getString(keyUsername) ?? '',
      keyUserEmail: prefs.getString(keyUserEmail) ?? '',
      keyThemeMode: themeMode.name,
      keyLastLoginTime: prefs.getString(keyLastLoginTime) ?? '',
      keyLanguage: prefs.getString(keyLanguage) ?? 'en',
      keyNotificationsEnabled: prefs.getBool(keyNotificationsEnabled) ?? true,
      keyUserId: prefs.getString(keyUserId) ?? '',
    };
  }

  static Future<void> setTheme(ThemeMode themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyThemeMode, themeMode.name);
  }

  static Future<ThemeMode> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString(keyThemeMode);
    return ThemeMode.values.firstWhere(
      (e) => e.name == themeString,
      orElse: () => ThemeMode.system,
    );
  }

  static Future<void> setLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyLanguage, language);
  }

  static Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyLanguage) ?? 'en';
  }

  static Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyNotificationsEnabled, enabled);
  }

  static Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyNotificationsEnabled) ?? true;
  }

  static Future<void> setAppVersion(String version) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyAppVersion, version);
  }

  static Future<String> getAppVersion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyAppVersion) ?? '1.0.0';
  }

  static Future<void> setLastSyncTime(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyLastSyncTime, time.toIso8601String());
  }

  static Future<DateTime?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timeString = prefs.getString(keyLastSyncTime);
    return timeString != null ? DateTime.parse(timeString) : null;
  }

  static Future<void> setCartTotal(double total) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(keyCartTotal, total);
  }

  static Future<double> getCartTotal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(keyCartTotal) ?? 0.0;
  }

  static Future<String> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyUserId) ?? '';
  }

  static Future<void> clearAllPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
