// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:typing_speed_master/providers/theme_provider.dart';

class CustomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool isDarkTheme;

  const CustomNavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.isDarkTheme,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    // here manage the selected and unselected tab colors with dark and light screen

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color:
              selected
                  ? isDarkTheme
                      ? Colors.white.withOpacity(0.2)
                      : Colors.black
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color:
                  selected
                      ? Colors.white
                      : isDarkTheme
                      ? Colors.white
                      : Colors.black87,
              size: 20,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color:
                    selected
                        ? isDarkTheme
                            ? Colors.white
                            : Colors.white
                        : isDarkTheme
                        ? Colors.white
                        : Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
