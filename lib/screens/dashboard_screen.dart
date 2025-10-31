// ignore_for_file: deprecated_member_use

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:typing_speed_master/providers/theme_provider.dart';
import 'package:typing_speed_master/widgets/responsive_layout.dart';
import 'package:typing_speed_master/widgets/typing_result_card.dart';
import '../providers/typing_provider.dart';
import '../widgets/stats_card.dart';
import '../widgets/accuracy_chart.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      smallMobile: dashboardWidget(
        context: context,
        horizontalPadding: 12,
        titleFontSize: 22,
        subtitleFontSize: 14,
      ),
      bigMobile: dashboardWidget(
        context: context,
        horizontalPadding: 24,
        titleFontSize: 24,
        subtitleFontSize: 14,
      ),
      smallTablet: dashboardWidget(
        context: context,
        horizontalPadding: 40,
        titleFontSize: 26,
        subtitleFontSize: 16,
      ),
      bigTablet: dashboardWidget(
        context: context,
        horizontalPadding: 60,
        titleFontSize: 28,
        subtitleFontSize: 16,
      ),
      smallDesktop: dashboardWidget(
        context: context,
        horizontalPadding: 80,
        titleFontSize: 30,
        subtitleFontSize: 18,
      ),
      bigDesktop: dashboardWidget(
        context: context,
        horizontalPadding: 100,
        titleFontSize: 32,
        subtitleFontSize: 18,
      ),
    );
  }

  Widget dashboardWidget({
    required BuildContext context,
    required double horizontalPadding,
    required double titleFontSize,
    required double subtitleFontSize,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  statsLayout(context),
                  const SizedBox(height: 20),
                  recentTypingResults(context, subtitleFontSize),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget statsLayout(BuildContext context) {
    final provider = Provider.of<TypingProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 600;

    if (isMobile) {
      return Column(
        children: [
          StatsCard(
            title: 'Average WPM',
            value: provider.averageWPM.toStringAsFixed(1),
            unit: 'WPM',
            color: Colors.blue,
            icon: Icons.speed,
            isDarkMode: themeProvider.isDarkMode,
          ),
          const SizedBox(height: 16),
          StatsCard(
            title: 'Average Accuracy',
            value: provider.averageAccuracy.toStringAsFixed(1),
            unit: '%',
            color: Colors.green,
            icon: Icons.flag,
            isDarkMode: themeProvider.isDarkMode,
          ),
          const SizedBox(height: 16),
          StatsCard(
            title: 'Total Tests',
            value: provider.totalTests.toString(),
            unit: 'Tests',
            color: Colors.orange,
            icon: Icons.assignment,
            isDarkMode: themeProvider.isDarkMode,
          ),
          const SizedBox(height: 16),
          StatsCard(
            title: 'Best WPM',
            value:
                provider.results.isNotEmpty
                    ? provider.results
                        .map((r) => r.wpm)
                        .reduce((a, b) => a > b ? a : b)
                        .toString()
                    : '0',
            unit: 'WPM',
            color: Colors.purple,
            icon: Icons.emoji_events,
            isDarkMode: themeProvider.isDarkMode,
          ),
        ],
      );
    } else if (screenWidth <= 900) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: StatsCard(
                  title: 'Average WPM',
                  value: provider.averageWPM.toStringAsFixed(1),
                  unit: 'WPM',
                  color: Colors.blue,
                  icon: Icons.speed,
                  isDarkMode: themeProvider.isDarkMode,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatsCard(
                  title: 'Average Accuracy',
                  value: provider.averageAccuracy.toStringAsFixed(1),
                  unit: '%',
                  color: Colors.green,
                  icon: Icons.flag,
                  isDarkMode: themeProvider.isDarkMode,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: StatsCard(
                  title: 'Total Tests',
                  value: provider.totalTests.toString(),
                  unit: 'Tests',
                  color: Colors.orange,
                  icon: Icons.assignment,
                  isDarkMode: themeProvider.isDarkMode,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatsCard(
                  title: 'Best WPM',
                  value:
                      provider.results.isNotEmpty
                          ? provider.results
                              .map((r) => r.wpm)
                              .reduce((a, b) => a > b ? a : b)
                              .toString()
                          : '0',
                  unit: 'WPM',
                  color: Colors.purple,
                  icon: Icons.emoji_events,
                  isDarkMode: themeProvider.isDarkMode,
                ),
              ),
            ],
          ),
        ],
      );
    } else if (screenWidth <= 1200) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: StatsCard(
                  title: 'Average WPM',
                  value: provider.averageWPM.toStringAsFixed(1),
                  unit: 'WPM',
                  color: Colors.blue,
                  icon: Icons.speed,
                  isDarkMode: themeProvider.isDarkMode,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatsCard(
                  title: 'Average Accuracy',
                  value: provider.averageAccuracy.toStringAsFixed(1),
                  unit: '%',
                  color: Colors.green,
                  icon: Icons.flag,
                  isDarkMode: themeProvider.isDarkMode,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatsCard(
                  title: 'Total Tests',
                  value: provider.totalTests.toString(),
                  unit: 'Tests',
                  color: Colors.orange,
                  icon: Icons.assignment,
                  isDarkMode: themeProvider.isDarkMode,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 300,
                child: StatsCard(
                  title: 'Best WPM',
                  value:
                      provider.results.isNotEmpty
                          ? provider.results
                              .map((r) => r.wpm)
                              .reduce((a, b) => a > b ? a : b)
                              .toString()
                          : '0',
                  unit: 'WPM',
                  color: Colors.purple,
                  icon: Icons.emoji_events,
                  isDarkMode: themeProvider.isDarkMode,
                ),
              ),
              const Spacer(flex: 1),
            ],
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: StatsCard(
              title: 'Average WPM',
              value: provider.averageWPM.toStringAsFixed(1),
              unit: 'WPM',
              color: Colors.blue,
              icon: Icons.speed,
              isDarkMode: themeProvider.isDarkMode,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: StatsCard(
              title: 'Average Accuracy',
              value: provider.averageAccuracy.toStringAsFixed(1),
              unit: '%',
              color: Colors.green,
              icon: Icons.flag,
              isDarkMode: themeProvider.isDarkMode,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: StatsCard(
              title: 'Total Tests',
              value: provider.totalTests.toString(),
              unit: 'Tests',
              color: Colors.orange,
              icon: Icons.assignment,
              isDarkMode: themeProvider.isDarkMode,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: StatsCard(
              title: 'Best WPM',
              value:
                  provider.results.isNotEmpty
                      ? provider.results
                          .map((r) => r.wpm)
                          .reduce((a, b) => a > b ? a : b)
                          .toString()
                      : '0',
              unit: 'WPM',
              color: Colors.purple,
              icon: Icons.emoji_events,
              isDarkMode: themeProvider.isDarkMode,
            ),
          ),
        ],
      );
    }
  }

  Widget recentTypingResults(BuildContext context, double subtitleFontSize) {
    final provider = Provider.of<TypingProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final recentResults = provider.getRecentResults(5);

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
              'Recent Tests',
              style: TextStyle(
                fontSize: subtitleFontSize + 2,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
            const Spacer(),
            if (provider.results.isNotEmpty)
              TextButton(
                onPressed: provider.clearHistory,
                child: Text(
                  'Clear History',
                  style: TextStyle(
                    color:
                        themeProvider.isDarkMode ? Colors.red[300] : Colors.red,
                  ),
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
          Column(
            children: [
              AccuracyChart(
                results: recentResults,
                isDarkMode: themeProvider.isDarkMode,
              ),
              const SizedBox(height: 20),
              ...recentResults.map(
                (result) => TypingResultCard(
                  result: result,
                  subtitleFontSize: 16,
                  isDarkMode: themeProvider.isDarkMode,
                  isHistory: false,
                  onViewDetails: () {
                    log('View details for ${result.difficulty}');
                  },
                ),
              ),
            ],
          ),
      ],
    );
  }
}
