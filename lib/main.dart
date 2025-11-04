// ignore_for_file: deprecated_member_use

import 'dart:developer';

import 'package:flutter/material.dart';
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

  await Supabase.initialize(
    url: "https://uxksujxjnrjgdufeapfz.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV4a3N1anhqbnJqZ2R1ZmVhcGZ6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE4MzI4MzUsImV4cCI6MjA3NzQwODgzNX0.dZkGyvlHmy_lOr5IrQmxDM-a8gGYhgREBA2pzatgTFo",
  );
  runApp(const TypingSpeedTesterApp());
}

class TypingSpeedTesterApp extends StatefulWidget {
  const TypingSpeedTesterApp({super.key});

  @override
  State<TypingSpeedTesterApp> createState() => _TypingSpeedTesterAppState();
}

class _TypingSpeedTesterAppState extends State<TypingSpeedTesterApp> {
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    _supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final session = data.session;

      if (event == AuthChangeEvent.signedIn && session != null) {
        log('User signed in: ${session.user.id}');
      } else if (event == AuthChangeEvent.signedOut) {
        log('User signed out');
      }
    });
  }

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
            title: 'Typing Speed Tester',
            theme: AppLightTheme.theme,
            darkTheme: AppDarkTheme.theme,
            themeMode: themeProvider.themeMode,
            debugShowCheckedModeBanner: false,
            home: const MainEntryPoint(),
          );
        },
      ),
    );
  }
}
