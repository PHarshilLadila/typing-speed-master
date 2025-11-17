// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:typing_speed_master/providers/auth_provider.dart';
import 'package:typing_speed_master/screens/main_entry_point_.dart';
import 'package:typing_speed_master/theme/dark_theme.dart';
import 'package:typing_speed_master/theme/light_theme.dart';
import 'providers/typing_provider.dart';
import 'providers/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final supabaseURL = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

  if (supabaseURL == null || supabaseAnonKey == null) {
    throw Exception("Missing Supabase credentials in .env file");
  }

  await Supabase.initialize(url: supabaseURL, anonKey: supabaseAnonKey);

  runApp(const TypingSpeedTesterApp());
}

class TypingSpeedTesterApp extends StatefulWidget {
  const TypingSpeedTesterApp({super.key});

  @override
  State<TypingSpeedTesterApp> createState() => _TypingSpeedTesterAppState();
}

class _TypingSpeedTesterAppState extends State<TypingSpeedTesterApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => TypingProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Typing Speed Master',
            // theme: AppLightTheme.theme,
            // darkTheme: AppDarkTheme.theme,
            theme: AppLightTheme.getTheme(
              primaryColor: themeProvider.primaryColor,
            ),
            darkTheme: AppDarkTheme.getTheme(
              primaryColor: themeProvider.primaryColor,
            ),
            themeMode: themeProvider.themeMode,
            debugShowCheckedModeBanner: false,
            home: const MainEntryPoint(),
          );
        },
      ),
    );
  }
}
