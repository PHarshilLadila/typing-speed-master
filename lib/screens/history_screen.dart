// ignore_for_file: deprecated_member_use

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:typing_speed_master/providers/theme_provider.dart';
import 'package:typing_speed_master/providers/typing_provider.dart';
import 'package:typing_speed_master/widgets/typing_result_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  Widget _buildRecentResults(BuildContext context, double subtitleFontSize) {
    final provider = Provider.of<TypingProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final recentResults = provider.getAllRecentResults();

    final titleColor =
        themeProvider.isDarkMode ? Colors.white : Colors.grey[800];
    final cardColor =
        themeProvider.isDarkMode ? Colors.grey[800] : Colors.white;
    final borderColor =
        themeProvider.isDarkMode ? Colors.grey[700] : Colors.grey[200];
    final textColor =
        themeProvider.isDarkMode ? Colors.grey[300] : Colors.grey[500];
    final iconColor =
        themeProvider.isDarkMode ? Colors.grey[400] : Colors.grey[400];

    return Column(
      children: [
        Row(
          children: [
            Text(
              'History',
              style: TextStyle(
                fontSize: subtitleFontSize + 2,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (recentResults.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor ?? Colors.grey[200]!),
            ),
            child: Column(
              children: [
                Icon(Icons.assignment, size: 48, color: iconColor),
                const SizedBox(height: 16),
                Text(
                  'No tests completed yet',
                  style: TextStyle(
                    fontSize: subtitleFontSize,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start your first typing test to see results here',
                  style: TextStyle(
                    fontSize: subtitleFontSize - 2,
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ...recentResults.map(
            (result) => TypingResultCard(
              result: result,
              subtitleFontSize: 16,
              isDarkMode: themeProvider.isDarkMode,
              isHistory: true,
              onViewDetails: () {
                log('View details for ${result.difficulty}');
              },
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: _buildRecentResults(context, 16),
      ),
    );
  }
}
