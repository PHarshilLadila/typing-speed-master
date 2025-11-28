import 'package:flutter/material.dart';
import 'package:typing_speed_master/service/theme_service.dart';

class ThemeProvider with ChangeNotifier {
  final ThemeService _themeService = ThemeService();

  bool _isDarkMode = false;
  ThemeMode _themeMode = ThemeMode.light;
  MaterialColor _primaryColor = Colors.amber;

  static final Map<String, MaterialColor> availableColors = {
    'red': Colors.red,
    'pink': Colors.pink,
    'purple': Colors.purple,
    'deepPurple': Colors.deepPurple,
    'indigo': Colors.indigo,
    'blue': Colors.blue,
    'lightBlue': Colors.lightBlue,
    'cyan': Colors.cyan,
    'teal': Colors.teal,
    'green': Colors.green,
    'lightGreen': Colors.lightGreen,
    'lime': Colors.lime,
    'yellow': Colors.yellow,
    'amber': Colors.amber,
    'orange': Colors.orange,
    'deepOrange': Colors.deepOrange,
    'brown': Colors.brown,
    'grey': Colors.grey,
    'blueGrey': Colors.blueGrey,
  };

  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _themeMode;
  MaterialColor get primaryColor => _primaryColor;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    _isDarkMode = await _themeService.getThemeMode();
    _themeMode = _isDarkMode ? ThemeMode.dark : ThemeMode.light;

    final savedColor = await _themeService.getPrimaryColor();
    _primaryColor = availableColors[savedColor] ?? Colors.amber;

    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    _themeMode = _isDarkMode ? ThemeMode.dark : ThemeMode.light;
    await _themeService.setThemeMode(_isDarkMode);
    notifyListeners();
  }

  Future<void> setTheme(bool isDark) async {
    _isDarkMode = isDark;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    await _themeService.setThemeMode(_isDarkMode);
    notifyListeners();
  }

  Future<void> setPrimaryColor(String colorName) async {
    if (availableColors.containsKey(colorName)) {
      _primaryColor = availableColors[colorName]!;
      await _themeService.setPrimaryColor(colorName);
      notifyListeners();
    }
  }

  String get currentColorName {
    return availableColors.entries
        .firstWhere(
          (entry) => entry.value == _primaryColor,
          orElse: () => MapEntry('amber', Colors.amber),
        )
        .key;
  }
}
