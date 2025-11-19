// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:typing_speed_master/providers/activity_provider.dart';
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
        ChangeNotifierProvider(create: (_) => ActivityProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Typing Speed Master',
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


// <!DOCTYPE html>
// <html>

// <head>
 
//   <base href="$FLUTTER_BASE_HREF">

//   <meta charset="UTF-8">
//   <meta content="IE=Edge" http-equiv="X-UA-Compatible">
//   <meta name="description" content="A new Flutter project.">

//   <!-- google-adsense-account -->
//   <meta name="google-adsense-account" content="ca-pub-3779258307133143">

//   <!-- iOS meta tags & icons -->
//   <meta name="mobile-web-app-capable" content="yes">
//   <meta name="apple-mobile-web-app-status-bar-style" content="black">
//   <meta name="apple-mobile-web-app-title" content="typing_speed_master">
//   <link rel="apple-touch-icon" href="icons/icon-192.jpg">

//   <!-- Favicon -->
//   <link rel="icon" type="image/png" href="favicon.jpg" />

//   <title>typing_speed</title>
//   <link rel="manifest" href="manifest.json">
//   <script defer src="/_vercel/insights/script.js"></script>

//   <script async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-3779258307133143"
//     crossorigin="anonymous"></script>
//   <!-- Flutter Web Banner 300x250 -->
//   <ins class="adsbygoogle" style="display:block" data-ad-client="ca-pub-3779258307133143" data-ad-slot="4355381273"
//     data-ad-format="auto" data-full-width-responsive="true"></ins>
//   <script>
//     (adsbygoogle = window.adsbygoogle || []).push({});
//   </script>

// </head>

// <body>
//   <script src="flutter_bootstrap.js" async></script>
// </body>

// </html>
