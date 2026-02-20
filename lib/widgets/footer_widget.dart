// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:typing_speed_master/theme/provider/theme_provider.dart';

class FooterWidget extends StatelessWidget {
  final ThemeProvider themeProvider;

  const FooterWidget({super.key, required this.themeProvider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12),
      width: double.maxFinite,
      decoration: BoxDecoration(
        color: themeProvider.primaryColor.withOpacity(0.3),
      ),
      child: Center(
        child: Text(
          "@2025 Typing Speed Test. All rights reserved.",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: themeProvider.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
