import 'package:flutter/material.dart';

class ThemeModel {
  final bool isDarkMode;
  final ThemeMode themeMode;

  ThemeModel({required this.isDarkMode, required this.themeMode});

  ThemeModel copyWith({bool? isDarkMode, ThemeMode? themeMode}) {
    return ThemeModel(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}
