import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/typing_provider.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(const TypingSpeedTesterApp());
}

class TypingSpeedTesterApp extends StatelessWidget {
  const TypingSpeedTesterApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TypingProvider(),
      child: MaterialApp(
        title: 'Typing Speed Tester',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: false,
          fontFamily: 'Inter',
          scaffoldBackgroundColor: Colors.grey[50],
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            elevation: 0,
            centerTitle: false,
            titleTextStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[400]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[400]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.blue),
            ),
          ),
        ),
        home: const DashboardScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
