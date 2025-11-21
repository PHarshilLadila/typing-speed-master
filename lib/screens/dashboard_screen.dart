// ignore_for_file: deprecated_member_use

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:typing_speed_master/providers/theme_provider.dart';
import 'package:typing_speed_master/widgets/responsive_layout.dart';
import 'package:typing_speed_master/widgets/typing_result_card.dart';
import '../providers/typing_provider.dart';
import '../widgets/stats_card.dart';
import '../widgets/accuracy_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = Provider.of<TypingProvider>(context, listen: false);
    provider.getAllRecentResults();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      smallMobile: dashboardWidget(
        context: context,
        titleFontSize: 22,
        subtitleFontSize: 14,
      ),
      bigMobile: dashboardWidget(
        context: context,
        titleFontSize: 24,
        subtitleFontSize: 14,
      ),
      smallTablet: dashboardWidget(
        context: context,
        titleFontSize: 26,
        subtitleFontSize: 16,
      ),
      bigTablet: dashboardWidget(
        context: context,
        titleFontSize: 28,
        subtitleFontSize: 16,
      ),
      smallDesktop: dashboardWidget(
        context: context,
        titleFontSize: 30,
        subtitleFontSize: 18,
      ),
      bigDesktop: dashboardWidget(
        context: context,
        titleFontSize: 32,
        subtitleFontSize: 18,
      ),
    );
  }

  Widget dashboardWidget({
    required BuildContext context,
    required double titleFontSize,
    required double subtitleFontSize,
    EdgeInsetsGeometry edgeInsetsGeometry = const EdgeInsets.all(40),
  }) {
    final width = MediaQuery.of(context).size.width;

    return Padding(
      padding:
          width > 1200
              ? EdgeInsets.symmetric(
                vertical: 50,
                horizontal: MediaQuery.of(context).size.width / 5,
              )
              : EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  dashboardStatsLayout(context),
                  const SizedBox(height: 26),
                  recentTypingResults(context, subtitleFontSize),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget dashboardStatsLayout(BuildContext context) {
    final provider = Provider.of<TypingProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 600;

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            'Dashboard',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: themeProvider.isDarkMode ? Colors.white : Colors.grey[800],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Track your performance insights",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color:
                  themeProvider.isDarkMode
                      ? Colors.grey[400]
                      : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 38),
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
            title: 'Consistency',
            value: provider.averageConsistency.toStringAsFixed(1),
            unit: '%',
            color: Colors.pink,
            icon: FontAwesomeIcons.bolt,
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
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dashboard',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: themeProvider.isDarkMode ? Colors.white : Colors.grey[800],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Track your performance insights",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color:
                  themeProvider.isDarkMode
                      ? Colors.grey[400]
                      : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 38),
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
                  title: 'Consistency',
                  value: provider.averageConsistency.toStringAsFixed(1),
                  unit: '%',
                  color: Colors.pink,
                  icon: FontAwesomeIcons.bolt,
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
              Expanded(
                flex: 1,
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
              const SizedBox(width: 16),

              Expanded(child: SizedBox()),
            ],
          ),
        ],
      );
    } else if (screenWidth <= 1200) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dashboard',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: themeProvider.isDarkMode ? Colors.white : Colors.grey[800],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Track your performance insights",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color:
                  themeProvider.isDarkMode
                      ? Colors.grey[400]
                      : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 38),
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
                  title: 'Consistency',
                  value: provider.averageConsistency.toStringAsFixed(1),
                  unit: '%',
                  color: Colors.pink,
                  icon: FontAwesomeIcons.bolt,
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
                flex: 1,
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
                flex: 1,
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
              const SizedBox(width: 16),

              const Spacer(flex: 1),
            ],
          ),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dashboard',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: themeProvider.isDarkMode ? Colors.white : Colors.grey[800],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Track your performance insights",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color:
                  themeProvider.isDarkMode
                      ? Colors.grey[400]
                      : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 38),
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
                  title: 'Consistency',
                  value: provider.averageConsistency.toStringAsFixed(1),
                  unit: '%',
                  color: Colors.pink,
                  icon: FontAwesomeIcons.bolt,
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
            padding: EdgeInsets.all(0),
            decoration: BoxDecoration(
              color:
                  themeProvider.isDarkMode ? Colors.grey[900] : Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    themeProvider.isDarkMode
                        ? Colors.grey[500]!
                        : Colors.grey[500]!,
                width: 0.3,
              ),
            ),
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height / 7,
                  bottom: MediaQuery.of(context).size.height / 7.5,
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: borderColor ?? Colors.grey[200]!,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
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
                ),
              ),
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
