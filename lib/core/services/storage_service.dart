import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Generic data storage
  static Future<bool> saveData(String key, String value) async {
    return await _prefs?.setString(key, value) ?? false;
  }

  static String? getData(String key) {
    return _prefs?.getString(key);
  }

  // Theme Persistence
  static Future<void> saveThemeMode(bool isDark) async {
    await _prefs?.setBool('isDarkMode', isDark);
  }

  static Future<void> setDarkMode(bool isDark) async {
    await saveThemeMode(isDark);
  }

  static bool isDarkMode() {
    return _prefs?.getBool('isDarkMode') ?? false;
  }

  // Onboarding Persistence
  static Future<void> setFirstTime(bool value) async {
    await _prefs?.setBool('isFirstTime', value);
  }

  static bool isFirstTime() {
    return _prefs?.getBool('isFirstTime') ?? true;
  }

  // Legacy helper for bookings (keep for compatibility)
  static Future<void> saveBookingsJson(String json) async {
    await _prefs?.setString('bookings', json);
  }

  static String? getBookingsJson() {
    return _prefs?.getString('bookings');
  }

  // Role Persistence
  static Future<void> saveUserRole(String role) async {
    await _prefs?.setString('userRole', role);
  }

  static String getUserRole() {
    return _prefs?.getString('userRole') ?? 'User';
  }
}
