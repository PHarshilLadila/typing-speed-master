// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:typing_speed_master/screens/main_entry_point_.dart';
import 'package:typing_speed_master/theme/dark_theme.dart';
import 'package:typing_speed_master/theme/light_theme.dart';
import 'providers/typing_provider.dart';
import 'providers/theme_provider.dart';

void main() {
  runApp(const TypingSpeedTesterApp());
}

class TypingSpeedTesterApp extends StatelessWidget {
  const TypingSpeedTesterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => TypingProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Typing Speed Tester',
            theme: AppLightTheme.theme,
            darkTheme: AppDarkTheme.theme,
            themeMode: themeProvider.themeMode,
            home: const MainEntryPoint(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
