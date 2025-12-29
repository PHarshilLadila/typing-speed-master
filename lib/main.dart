// ignore_for_file: deprecated_member_use

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_adsense/google_adsense.dart';
import 'package:meta_seo/meta_seo.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:typing_speed_master/providers/app_providers.dart';
import 'package:typing_speed_master/theme/dark_theme.dart';
import 'package:typing_speed_master/theme/light_theme.dart';
import 'theme/provider/theme_provider.dart';
import 'package:typing_speed_master/routes/app_router.dart';
import 'package:typing_speed_master/providers/router_provider.dart';
import 'package:url_strategy/url_strategy.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  setPathUrlStrategy();

  await adSense.initialize('3779258307133143');

  if (kIsWeb) {
    MetaSEO().config();
    MetaSEO meta = MetaSEO();
    meta.author(author: 'Typing Speed Master');
    meta.description(
      description:
          'Typing Speed Master is a professional Flutter web application to test and improve your typing speed with real-time WPM, accuracy, and consistency tracking. Features include Google login, difficulty levels, detailed analytics, historical progress charts, performance dashboard, and full responsive support across desktop, tablet, and mobile. Practice typing with live metrics, save your results securely via Supabase, and track your journey to becoming a typing expert.',
    );
    meta.keywords(
      keywords:
          'typing speed test, WPM test, typing speed, typing, speed, typing speed master, typing practice, google auth, typing accuracy, online typing app, Flutter web app, Supabase login, typing analytics, typing tracker, real-time typing test, accuracy, vercel, responsive design, typing performance, typing consistency, typing history, typing dashboard, vercel hosting, vercel web app, vercel flutter',
    );
  }

  await dotenv.load(fileName: ".env");

  final supabaseURL = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

  if (supabaseURL == null || supabaseAnonKey == null) {
    throw Exception("Missing Supabase credentials in .env file");
  }

  await Supabase.initialize(url: supabaseURL, anonKey: supabaseAnonKey);

  runApp(const TypingSpeedMasterApp());
}

class TypingSpeedMasterApp extends StatefulWidget {
  const TypingSpeedMasterApp({super.key});

  @override
  State<TypingSpeedMasterApp> createState() => _TypingSpeedMasterAppState();
}

class _TypingSpeedMasterAppState extends State<TypingSpeedMasterApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: AppProviders.providers,
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return Consumer<RouterProvider>(
            builder: (context, routerProvider, child) {
              return MaterialApp.router(
                title: 'Typing Speed Master',
                theme: AppLightTheme.getTheme(
                  primaryColor: themeProvider.primaryColor,
                ),
                darkTheme: AppDarkTheme.getTheme(
                  primaryColor: themeProvider.primaryColor,
                ),
                themeMode: themeProvider.themeMode,
                debugShowCheckedModeBanner: false,
                scrollBehavior: const MaterialScrollBehavior().copyWith(
                  scrollbars: false,
                ),
                routeInformationProvider:
                    AppRouter.router.routeInformationProvider,
                routeInformationParser: AppRouter.router.routeInformationParser,
                routerDelegate: AppRouter.router.routerDelegate,
              );
            },
          );
        },
      ),
    );
  }
}
