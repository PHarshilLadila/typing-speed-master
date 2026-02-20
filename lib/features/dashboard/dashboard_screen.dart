// ignore_for_file: deprecated_member_use

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:typing_speed_master/features/dashboard/widget/radar_chart_widget.dart';
import 'package:typing_speed_master/features/dashboard/widget/speed_and_accuracy_chart.dart';
import 'package:typing_speed_master/theme/provider/theme_provider.dart';
import 'package:typing_speed_master/widgets/custom_history_not_found_widget.dart';
import 'package:typing_speed_master/widgets/responsive_layout.dart';
import 'package:typing_speed_master/widgets/custom_typing_result_card.dart';
import '../typing_test/provider/typing_test_provider.dart';
import '../../widgets/custom_stats_card.dart';
import 'widget/accuracy_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  TypingProvider? typingProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      refreshData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    typingProvider = Provider.of<TypingProvider>(context);
  }

  Future<void> refreshData() async {
    if (typingProvider != null) {
      await typingProvider!.getAllRecentResults();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TypingProvider>(context);
    // final themeProvider = Provider.of<ThemeProvider>(context);

    return SingleChildScrollView(
      child: Column(
        children: [
          ResponsiveLayout(
            smallMobile: dashboardWidget(
              context: context,
              titleFontSize: 22,
              subtitleFontSize: 14,
              typingProvider: provider,
            ),
            bigMobile: dashboardWidget(
              context: context,
              titleFontSize: 24,
              subtitleFontSize: 14,
              typingProvider: provider,
            ),
            smallTablet: dashboardWidget(
              context: context,
              titleFontSize: 26,
              subtitleFontSize: 16,
              typingProvider: provider,
            ),
            bigTablet: dashboardWidget(
              context: context,
              titleFontSize: 28,
              subtitleFontSize: 16,
              typingProvider: provider,
            ),
            smallDesktop: dashboardWidget(
              context: context,
              titleFontSize: 30,
              subtitleFontSize: 18,
              typingProvider: provider,
            ),
            bigDesktop: dashboardWidget(
              context: context,
              titleFontSize: 32,
              subtitleFontSize: 18,
              typingProvider: provider,
            ),
          ),
          // FooterWidget(themeProvider: themeProvider),
        ],
      ),
    );
  }

  Widget dashboardWidget({
    required BuildContext context,
    required double titleFontSize,
    required double subtitleFontSize,
    TypingProvider? typingProvider,
    EdgeInsetsGeometry edgeInsetsGeometry = const EdgeInsets.all(40),
  }) {
    final width = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      child: Padding(
        padding:
            width > 1200
                ? EdgeInsets.symmetric(
                  vertical: 50,
                  horizontal: MediaQuery.of(context).size.width / 5,
                )
                : EdgeInsets.all(40),
        child: Column(
          children: [
            dashboardStatsLayout(context),
            const SizedBox(height: 26),
            recentTypingResults(context, subtitleFontSize),
          ],
        ),
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
          CustomStatsCard(
            title: 'Average WPM',
            value: provider.averageWPM.toStringAsFixed(1),
            unit: 'WPM',
            color: Colors.blue,
            icon: Icons.speed,
            isDarkMode: themeProvider.isDarkMode,
          ),
          const SizedBox(height: 16),
          CustomStatsCard(
            title: 'Consistency',
            value: provider.averageConsistency.toStringAsFixed(1),
            unit: '%',
            color: Colors.pink,
            icon: FontAwesomeIcons.bolt,
            isDarkMode: themeProvider.isDarkMode,
          ),
          const SizedBox(height: 16),
          CustomStatsCard(
            title: 'Average Accuracy',
            value: provider.averageAccuracy.toStringAsFixed(1),
            unit: '%',
            color: Colors.green,
            icon: Icons.flag,
            isDarkMode: themeProvider.isDarkMode,
          ),
          const SizedBox(height: 16),
          CustomStatsCard(
            title: 'Total Tests',
            value: provider.totalTests.toString(),
            unit: 'Tests',
            color: Colors.orange,
            icon: Icons.assignment,
            isDarkMode: themeProvider.isDarkMode,
          ),
          const SizedBox(height: 16),
          CustomStatsCard(
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
                child: CustomStatsCard(
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
                child: CustomStatsCard(
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
                child: CustomStatsCard(
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
                child: CustomStatsCard(
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
                child: CustomStatsCard(
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
                child: CustomStatsCard(
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
                child: CustomStatsCard(
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
                child: CustomStatsCard(
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
                child: CustomStatsCard(
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
                child: CustomStatsCard(
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
                child: CustomStatsCard(
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
                child: CustomStatsCard(
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
                child: CustomStatsCard(
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
                child: CustomStatsCard(
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
                child: CustomStatsCard(
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

  Widget emptyState(
    BuildContext context,
    ThemeProvider themeProvider,
    double subtitleFontSize,
  ) {
    return Container(
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? Colors.grey[900] : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              themeProvider.isDarkMode ? Colors.grey[500]! : Colors.grey[500]!,
          width: 0.3,
        ),
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height / 6.5,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomHistoryNotFoundWidget(title: 'No tests completed yet'),
              const SizedBox(height: 6),
              Text(
                'Start your first typing test to see your performance insights here',
                style: GoogleFonts.outfit(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
  /*


  Bar and Line Graph:

  The given bar graph accurately indicates the information about the population of selected countries of the world.

  The x-axis represents different countries like India, China, USA, Brazil, and Russia, while the y-axis indicates the population in millions.

  It is clearly seen from the graph that China records the highest population, which is around 1440 million,
  followed by India, which is about 1410 million. The lowest population is recorded for Russia, which is approximately 146 million.

  After analyzing this picture, it can be concluded that the picture provides crucial information about the population distribution among major countries of the world.

  --------

  Pie chart:

  The given pie chart provides details about how a student spends time in a day.

  The elements of the pie chart are Sleeping, Studying, Playing, and Other activities.

  It is clearly seen from the chart that Sleeping occupies the majority area, which is about 40%,
  followed by Studying, which is around 30%, and the minority area is covered by Playing, which is about 15%.

  In conclusion, the picture provides vital information about a student’s daily routine and time management.

  --------

  Process (Easy Example: Making Tea)

  The given process accurately indicates the information about the preparation of tea.

  There are several stages in this process like boiling water, adding tea leaves, adding milk and sugar, and serving tea. 
  
  It is clearly seen from the process
  that the first stage indicates the information about boiling water, followed by adding tea leaves, which is further transformed into tea by adding milk and sugar. 

  The second last stage of the process is straining the tea, which finally leads to serving hot tea.

  After analyzing this picture, it can be concluded that the picture provides crucial information about the step-by-step method of preparing tea.

  --------

  Random Image (Easy Example: Classroom Survey Data):

  The provided picture shows information about a classroom survey of students’ favorite subjects.

  It also provides information in different categories which are Mathematics, Science, English, and Sports.

  There are also different elements and numbers like number of students choosing each subject.

  There are also different colors in this image such as blue, green, red, and yellow.

  There are different numbers, variations, and trends shown in the picture; some subjects have the highest number of students while the others are the lowest.
  
  Overall, this image is very informative and easy to explain about students’ subject preferences in a classroom.

--------
  */

  Widget recentTypingResults(BuildContext context, double subtitleFontSize) {
    final provider = Provider.of<TypingProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final recentResults = provider.getRecentResults(10);

    if (recentResults.isEmpty) {
      return emptyState(context, themeProvider, subtitleFontSize);
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 600;
    final isTablet = screenWidth <= 900;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Analysis',
          style: TextStyle(
            fontSize: subtitleFontSize + 2,
            fontWeight: FontWeight.bold,
            color: themeProvider.isDarkMode ? Colors.white : Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),

        if (isMobile)
          Column(
            children: [
              SpeedAccuracyTrendChart(
                results: recentResults,
                isDarkMode: themeProvider.isDarkMode,
              ),
              const SizedBox(height: 20),
              if (recentResults.length >= 3)
                TypingRadarChart(
                  recentResults: recentResults,
                  isDarkMode: themeProvider.isDarkMode,
                  chartSize: 300,
                ),
            ],
          )
        else if (isTablet && screenWidth > 600)
          Row(
            children: [
              Expanded(
                child: SpeedAccuracyTrendChart(
                  results: recentResults,
                  isDarkMode: themeProvider.isDarkMode,
                ),
              ),
              const SizedBox(width: 16),
              if (recentResults.length >= 3)
                Expanded(
                  child: TypingRadarChart(
                    recentResults: recentResults,
                    isDarkMode: themeProvider.isDarkMode,
                    chartSize: 280,
                  ),
                ),
            ],
          )
        else
          Row(
            children: [
              Expanded(
                flex: 2,
                child: SpeedAccuracyTrendChart(
                  results: recentResults,
                  isDarkMode: themeProvider.isDarkMode,
                ),
              ),
              const SizedBox(width: 20),
              if (recentResults.length >= 3)
                Expanded(
                  flex: 1,
                  child: TypingRadarChart(
                    recentResults: recentResults,
                    isDarkMode: themeProvider.isDarkMode,
                    chartSize: 350,
                  ),
                ),
            ],
          ),

        const SizedBox(height: 20),

        SizedBox(
          height: isMobile ? 300 : 340,
          child: Align(
            alignment: Alignment.center,
            child: AccuracyChart(
              results: recentResults,
              isDarkMode: themeProvider.isDarkMode,
            ),
          ),
        ),
        const SizedBox(height: 20),

        Text(
          'Test History',
          style: TextStyle(
            fontSize: isMobile ? 18 : 20,
            fontWeight: FontWeight.bold,
            color: themeProvider.isDarkMode ? Colors.white : Colors.grey[800],
          ),
        ),
        const SizedBox(height: 10),
        ...recentResults
            .take(isMobile ? 3 : 5)
            .take(isMobile ? 3 : 5)
            .map(
              (result) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CustomTypingResultCard(
                  result: result,
                  subtitleFontSize: isMobile ? 14 : 16,
                  isDarkMode: themeProvider.isDarkMode,
                  isHistory: false,
                  onViewDetails: () => log('View details'),
                ),
              ),
            ),
      ],
    );
  }
}
