// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// class AppDarkTheme {
//   static ThemeData get theme {
//     return ThemeData(
//       primarySwatch: Colors.amber,
//       useMaterial3: false,
//       brightness: Brightness.dark,
//       textTheme: GoogleFonts.mulishTextTheme(ThemeData.dark().textTheme),
//       scaffoldBackgroundColor: Colors.grey[900],
//       appBarTheme: AppBarTheme(
//         backgroundColor: Colors.grey[800],
//         foregroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: false,
//         titleTextStyle: GoogleFonts.mulish(
//           fontSize: 18,
//           fontWeight: FontWeight.w600,
//           color: Colors.white,
//         ),
//       ),
//       inputDecorationTheme: InputDecorationTheme(
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: BorderSide(color: Colors.grey[600]!),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: BorderSide(color: Colors.grey[600]!),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: const BorderSide(color: Colors.amber),
//         ),
//         filled: true,
//         fillColor: Colors.grey[800],
//         labelStyle: const TextStyle(color: Colors.white),
//         hintStyle: const TextStyle(color: Colors.grey),
//       ),
//       cardColor: Colors.grey[800],
//       // bottomAppBarTheme: BottomAppBarTheme(color: Colors.grey[800]),
//       // dialogTheme: DialogTheme(backgroundColor: Colors.grey[800]),
//     );
//   }
// }
// themes/app_dark_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppDarkTheme {
  static ThemeData getTheme({required MaterialColor primaryColor}) {
    return ThemeData(
      primarySwatch: primaryColor,
      useMaterial3: false,
      brightness: Brightness.dark,
      textTheme: GoogleFonts.mulishTextTheme(ThemeData.dark().textTheme),
      scaffoldBackgroundColor: Colors.grey[900],
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey[800],
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.mulish(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[600]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[600]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor),
        ),
        filled: true,
        fillColor: Colors.grey[800],
        labelStyle: const TextStyle(color: Colors.white),
        hintStyle: const TextStyle(color: Colors.grey),
      ),
      cardColor: Colors.grey[800],
      colorScheme: ColorScheme.dark(primary: primaryColor),
    );
  }
}
