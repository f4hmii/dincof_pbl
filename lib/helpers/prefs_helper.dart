import 'package:shared_preferences/shared_preferences.dart';

// Kunci untuk status login pengguna
class PrefsHelper {
  // Key-1: Digunakan untuk menyimpan status login (true jika sudah login, false jika belum).
  static const String keyIsLoggedIn = 'isLoggedIn';
  
  // Key-2: Digunakan untuk menyimpan peran pengguna (misalnya, 'admin' atau 'user').
  static const String keyUserRole = 'userRole';
  
  // Key-3: Digunakan untuk menyimpan nama pengguna yang sedang login.
  static const String keyUsername = 'username';
  
  // Key-4: Digunakan untuk menyimpan alamat email pengguna yang sedang login.
  static const String keyUserEmail = 'userEmail';
  
  // Key-5: Digunakan untuk menyimpan mode tema aplikasi (misalnya, 'light' atau 'dark').
  static const String keyThemeMode = 'themeMode';
  
  // Key-6: Digunakan untuk menyimpan waktu terakhir kali pengguna login.
  static const String keyLastLoginTime = 'lastLoginTime';
  
  // Key-7: Digunakan untuk menyimpan preferensi bahasa pengguna.
  static const String keyLanguage = 'language';
  
  // Key-8: Digunakan untuk menyimpan status notifikasi (true jika diaktifkan, false jika tidak).
  static const String keyNotificationsEnabled = 'notificationsEnabled';
  
  // Key-9: Digunakan untuk menyimpan versi aplikasi saat ini.
  static const String keyAppVersion = 'appVersion';
  
  // Key-10: Digunakan untuk menyimpan waktu terakhir sinkronisasi data.
  static const String keyLastSyncTime = 'lastSyncTime';
  
  // Key-11: Digunakan untuk menyimpan ID unik pengguna.
  static const String keyUserId = 'userId';
  
  // Key-12: Digunakan untuk menyimpan total belanja di keranjang.
  static const String keyCartTotal = 'cartTotal';

  static Future<void> saveLoginData(String username, String email, String role, {String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyIsLoggedIn, true);
    await prefs.setString(keyUserRole, role);
    await prefs.setString(keyUsername, username);
    await prefs.setString(keyUserEmail, email);
    await prefs.setString(keyLastLoginTime, DateTime.now().toIso8601String());
    if (userId != null) {
      await prefs.setString(keyUserId, userId);
    }
    
    // Set default values if not exists
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
    return {
      keyIsLoggedIn: prefs.getBool(keyIsLoggedIn) ?? false,
      keyUserRole: prefs.getString(keyUserRole) ?? '',
      keyUsername: prefs.getString(keyUsername) ?? '',
      keyUserEmail: prefs.getString(keyUserEmail) ?? '',
      keyThemeMode: prefs.getString(keyThemeMode) ?? 'light',
      keyLastLoginTime: prefs.getString(keyLastLoginTime) ?? '',
      keyLanguage: prefs.getString(keyLanguage) ?? 'en',
      keyNotificationsEnabled: prefs.getBool(keyNotificationsEnabled) ?? true,
      keyUserId: prefs.getString(keyUserId) ?? '',
    };
  }

  static Future<void> setThemeMode(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyThemeMode, theme);
  }

  // Preferences Methods for New Keys

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
