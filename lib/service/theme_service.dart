// import 'package:shared_preferences/shared_preferences.dart';

// class ThemeService {
//   static const String _themeKey = 'isDarkMode';

//   Future<bool> getThemeMode() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getBool(_themeKey) ?? false;
//   }

//   Future<void> setThemeMode(bool isDarkMode) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool(_themeKey, isDarkMode);
//   }
// }

// service/theme_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const String _themeKey = 'theme_mode';
  static const String _colorKey = 'primary_color';

  Future<bool> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? false;
  }

  Future<void> setThemeMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDark);
  }

  Future<String> getPrimaryColor() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_colorKey) ?? 'amber';
  }

  Future<void> setPrimaryColor(String colorName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_colorKey, colorName);
  }
}
