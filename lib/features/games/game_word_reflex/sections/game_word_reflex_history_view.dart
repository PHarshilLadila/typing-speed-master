// ignore_for_file: unused_element

import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:typing_speed_master/features/games/game_word_reflex/provider/word_reflex_provider.dart';
import 'package:typing_speed_master/theme/provider/theme_provider.dart';
import 'package:typing_speed_master/features/games/game_word_reflex/widgets/word_reflex_share_dialog.dart';
import 'package:typing_speed_master/widgets/custom_history_not_found_widget.dart';
import 'package:fl_chart/fl_chart.dart';

class GameWordReflexHistoryView extends StatefulWidget {
  const GameWordReflexHistoryView({super.key});

  @override
  State<GameWordReflexHistoryView> createState() =>
      GameWordReflexHistoryViewState();
}

class GameWordReflexHistoryViewState extends State<GameWordReflexHistoryView>
    with TickerProviderStateMixin {
  String resultFilter = 'All'; // All, Recent, High Score
  bool _isPerformanceExpanded = true; // Initially expanded (visible)
  bool _showCharts = false; // For chart animations

  @override
  void initState() {
    super.initState();
    // Delay chart animation slightly for a nice entrance effect
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _showCharts = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final provider = Provider.of<WordReflexProvider>(context);
    final isDark = themeProvider.isDarkMode;
    // final isMobile = MediaQuery.of(context).size.width < 768;

    List<dynamic> history = List.from(provider.history);

    // Apply Filter
    if (resultFilter == 'High Score') {
      history.sort((a, b) => b.score.compareTo(a.score));
    } else if (resultFilter == 'Recent') {
      history.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 600;

                return Flex(
                  direction: isMobile ? Axis.vertical : Axis.horizontal,
                  crossAxisAlignment:
                      isMobile
                          ? CrossAxisAlignment.start
                          : CrossAxisAlignment.center,
                  mainAxisAlignment:
                      isMobile
                          ? MainAxisAlignment.start
                          : MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Game History',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),

                    if (isMobile) const SizedBox(height: 12),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        wRFXGameHistoryFilterDropdown(isDark, themeProvider),
                        isMobile ? const Spacer() : const SizedBox(width: 8),
                        InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => provider.resetToSetup(),
                          child: Container(
                            height: 36,
                            width: 36,
                            decoration: BoxDecoration(
                              color: themeProvider.primaryColor.withOpacity(
                                0.2,
                              ),
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              Icons.close,
                              size: 20,
                              color:
                                  isDark ? Colors.grey[300] : Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          const Divider(height: 1),
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () {
                setState(() {
                  _isPerformanceExpanded = !_isPerformanceExpanded;
                });
              },
              child: Container(
                margin: EdgeInsets.only(right: 12, top: 12),
                padding: EdgeInsets.symmetric(vertical: 2, horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[850] : Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 1500),
                  tween: Tween(begin: 0.0, end: 1.0),
                  curve: Curves.easeInOut,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 3 * sin(value.toDouble())),
                      child: Icon(
                        _isPerformanceExpanded
                            ? Icons.keyboard_arrow_down
                            : Icons.keyboard_arrow_up,
                        color: themeProvider.primaryColor,
                        size: 28,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          SizedBox(height: 12),

          provider.isLoadingHistory
              ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(48.0),
                  child: CircularProgressIndicator(),
                ),
              )
              : history.isEmpty
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(48.0),
                  child: CustomHistoryNotFoundWidget(),
                ),
              )
              : Column(
                children: [
                  // Animated Performance Section
                  AnimatedSize(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (
                        Widget child,
                        Animation<double> animation,
                      ) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, -0.3),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                            ),
                          ),
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                      child:
                          _isPerformanceExpanded
                              ? _buildOverallPerformanceCharts(
                                isDark,
                                themeProvider,
                                history,
                              )
                              : const SizedBox.shrink(key: ValueKey('hidden')),
                    ),
                  ),

                  // const Divider(height: 1),

                  // Game History List with Wave Arrow Button
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: history.length,
                    padding: const EdgeInsets.only(
                      left: 8,
                      right: 8,
                      top: 8,
                      bottom: 60, // Add space for the wave button
                    ),
                    itemBuilder: (context, index) {
                      final game = history[index];
                      return wRFXGameHistoryItem(
                        game,
                        index,
                        isDark,
                        themeProvider,
                      );
                    },
                  ),
                ],
              ),
        ],
      ),
    );
  }

  Widget _buildOverallPerformanceCharts(
    bool isDark,
    ThemeProvider themeProvider,
    List<dynamic> history,
  ) {
    int allOverCorrectAnswers = 0;
    int allOverWrongAnswers = 0;
    int allOverStreak = 0;

    for (var game in history) {
      allOverCorrectAnswers += game.correctAnswers as int;
      allOverWrongAnswers += game.wrongAnswers as int;
      if (game.streak > allOverStreak) {
        allOverStreak = game.streak as int;
      }
    }
    int allOverTotalRounds = allOverCorrectAnswers + allOverWrongAnswers;
    int totalGames = history.length;
    double allOverAccuracy =
        allOverTotalRounds > 0
            ? (allOverCorrectAnswers / allOverTotalRounds) * 100
            : 0.0;

    String performanceLabel = 'Beginner';
    Color performanceColor = Colors.blueGrey;
    IconData performanceIcon = Icons.rocket_launch;

    if (allOverAccuracy >= 90) {
      performanceLabel = 'Elite';
      performanceColor = Colors.amber;
      performanceIcon = Icons.workspace_premium;
    } else if (allOverAccuracy >= 75) {
      performanceLabel = 'Advanced';
      performanceColor = Colors.green;
      performanceIcon = Icons.trending_up;
    } else if (allOverAccuracy >= 50) {
      performanceLabel = 'Intermediate';
      performanceColor = Colors.blue;
      performanceIcon = Icons.insights;
    }
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Padding(
      key: const ValueKey('performance-section'),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overall Performance Card - Redesigned
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? Colors.grey[850]! : Colors.grey[300]!,
                width: 0.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Performance Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: performanceColor.withOpacity(0.15),
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: performanceColor.withOpacity(0.3),
                      width: 0.5,
                    ),
                  ),
                  child: Icon(
                    performanceIcon,
                    color: performanceColor,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 20),

                // Performance Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Overall Performance',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          letterSpacing: 0.5,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      isMobile
                          ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                performanceLabel,
                                style: GoogleFonts.outfit(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: performanceColor,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: performanceColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${allOverAccuracy.toStringAsFixed(1)}%',
                                  style: GoogleFonts.outfit(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: performanceColor,
                                  ),
                                ),
                              ),
                            ],
                          )
                          : Row(
                            children: [
                              Text(
                                performanceLabel,
                                style: GoogleFonts.outfit(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: performanceColor,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: performanceColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${allOverAccuracy.toStringAsFixed(1)}%',
                                  style: GoogleFonts.outfit(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: performanceColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                    ],
                  ),
                ),
                // Stats Preview
                isMobile
                    ? Column(
                      crossAxisAlignment: CrossAxisAlignment.end,

                      children: [
                        _buildMiniStat(
                          'Total Games',
                          '${history.length}',
                          Colors.blue,
                          isDark,
                        ),
                        const SizedBox(height: 12),
                        _buildMiniStat(
                          'Best Streak',
                          '$allOverStreak',
                          Colors.orange,
                          isDark,
                        ),
                      ],
                    )
                    : Row(
                      children: [
                        _buildMiniStat(
                          'Games',
                          '${history.length}',
                          Colors.blue,
                          isDark,
                        ),
                        const SizedBox(width: 16),
                        _buildMiniStat(
                          'Best Streak',
                          '$allOverStreak',
                          Colors.orange,
                          isDark,
                        ),
                      ],
                    ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Section Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: themeProvider.primaryColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Analytics Dashboard',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Charts Row - Redesigned with Animations
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 600;
              final charts = [
                // Chart 1 - Answers Breakdown (Redesigned) with Animation
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: _showCharts ? 1.0 : 0.0),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Opacity(
                        opacity: value.clamp(0.0, 1.0),
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    width:
                        isMobile
                            ? double.infinity
                            : (constraints.maxWidth / 2) - 8,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[900] : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              isDark
                                  ? Colors.black12
                                  : Colors.grey.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Chart Header
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color:
                                    isDark
                                        ? Colors.grey[800]!
                                        : Colors.grey[200]!,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: themeProvider.primaryColor.withOpacity(
                                    0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.pie_chart,
                                  color: themeProvider.primaryColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Flexible(
                                child: Text(
                                  'Answers Breakdown',
                                  style: GoogleFonts.outfit(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        isDark ? Colors.white : Colors.black87,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Chart Body
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              if (allOverTotalRounds > 0)
                                TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  duration: const Duration(milliseconds: 1200),
                                  curve: Curves.easeInOut,
                                  builder: (context, value, child) {
                                    return Opacity(
                                      opacity: value.clamp(0.0, 1.0),
                                      child: child,
                                    );
                                  },
                                  child: SizedBox(
                                    height: 180,
                                    child: PieChart(
                                      PieChartData(
                                        sectionsSpace: 1,
                                        centerSpaceRadius: 20,
                                        startDegreeOffset: -90,
                                        sections: [
                                          PieChartSectionData(
                                            value:
                                                allOverCorrectAnswers
                                                    .toDouble(),
                                            color: Colors.lightGreen,
                                            title:
                                                '${((allOverCorrectAnswers / allOverTotalRounds) * 100).toStringAsFixed(0)}%',
                                            radius: 60,
                                            titleStyle: GoogleFonts.outfit(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          PieChartSectionData(
                                            value:
                                                allOverWrongAnswers.toDouble(),
                                            color: Colors.redAccent,
                                            title:
                                                '${((allOverWrongAnswers / allOverTotalRounds) * 100).toStringAsFixed(0)}%',
                                            radius: 70,
                                            titleStyle: GoogleFonts.outfit(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              else
                                SizedBox(
                                  height: 150,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.pie_chart_outline,
                                          size: 48,
                                          color:
                                              isDark
                                                  ? Colors.grey[700]
                                                  : Colors.grey[300],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'No data available',
                                          style: GoogleFonts.outfit(
                                            color:
                                                isDark
                                                    ? Colors.grey[600]
                                                    : Colors.grey[400],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                              const SizedBox(height: 20),

                              // Legend
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildLegendItem(
                                    'Correct',
                                    Colors.green,
                                    allOverCorrectAnswers,
                                    isDark,
                                  ),
                                  const SizedBox(width: 24),
                                  _buildLegendItem(
                                    'Wrong',
                                    Colors.red,
                                    allOverWrongAnswers,
                                    isDark,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (isMobile) const SizedBox(height: 16),

                // Chart 2 - Stats Overview (Redesigned) with Animation
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: _showCharts ? 1.0 : 0.0),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    debugPrint('value: $value');

                    return Transform.translate(
                      offset: Offset(50 * (1 - value), 0),
                      child: Opacity(
                        opacity: value.clamp(0.0, 1.0),
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    width:
                        isMobile
                            ? double.infinity
                            : (constraints.maxWidth / 2) - 8,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[900] : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              isDark
                                  ? Colors.black12
                                  : Colors.grey.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Chart Header
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color:
                                    isDark
                                        ? Colors.grey[800]!
                                        : Colors.grey[200]!,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: themeProvider.primaryColor.withOpacity(
                                    0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.bar_chart,
                                  color: themeProvider.primaryColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Stats Overview',
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Chart Body
                        Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              if (allOverTotalRounds > 0)
                                TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  duration: const Duration(milliseconds: 1500),
                                  curve: Curves.easeInOut,
                                  builder: (context, value, child) {
                                    return Opacity(
                                      opacity: value,
                                      child: child,
                                    );
                                  },
                                  child: SizedBox(
                                    height: 180,
                                    child: BarChart(
                                      BarChartData(
                                        alignment:
                                            BarChartAlignment.spaceAround,
                                        maxY:
                                            [
                                              allOverTotalRounds.toDouble(),
                                              allOverStreak.toDouble(),
                                              10.0,
                                            ].reduce((a, b) => a > b ? a : b) *
                                            1.2,
                                        barTouchData: BarTouchData(
                                          enabled: true,
                                          touchTooltipData: BarTouchTooltipData(
                                            getTooltipColor:
                                                (group) =>
                                                    isDark
                                                        ? Colors.grey[800]!
                                                        : Colors.white,
                                            getTooltipItem: (
                                              group,
                                              groupIndex,
                                              rod,
                                              rodIndex,
                                            ) {
                                              String value = rod.toY
                                                  .toStringAsFixed(0);
                                              return BarTooltipItem(
                                                value,
                                                TextStyle(
                                                  color:
                                                      isDark
                                                          ? Colors.white
                                                          : Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        titlesData: FlTitlesData(
                                          show: true,
                                          bottomTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              getTitlesWidget: (
                                                double value,
                                                TitleMeta meta,
                                              ) {
                                                final titles = [
                                                  'Total Rounds',
                                                  'Best Streak',
                                                  'Total Games',
                                                ];
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 8.0,
                                                      ),
                                                  child: Text(
                                                    titles[value.toInt()],
                                                    style: GoogleFonts.outfit(
                                                      color:
                                                          isDark
                                                              ? Colors.grey[400]
                                                              : Colors
                                                                  .grey[600],
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          leftTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              reservedSize: 30,
                                              getTitlesWidget: (value, meta) {
                                                if (value % 10 == 0 ||
                                                    value == 0) {
                                                  return Text(
                                                    value.toInt().toString(),
                                                    style: TextStyle(
                                                      color:
                                                          isDark
                                                              ? Colors.grey[500]
                                                              : Colors
                                                                  .grey[400],
                                                      fontSize: 10,
                                                    ),
                                                  );
                                                }
                                                return const Text('');
                                              },
                                            ),
                                          ),
                                          topTitles: const AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: false,
                                            ),
                                          ),
                                          rightTitles: const AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: false,
                                            ),
                                          ),
                                        ),
                                        gridData: FlGridData(
                                          show: true,
                                          drawHorizontalLine: true,
                                          horizontalInterval: 10,
                                          getDrawingHorizontalLine: (value) {
                                            return FlLine(
                                              color:
                                                  isDark
                                                      ? Colors.grey[800]!
                                                      : Colors.grey[200]!,
                                              strokeWidth: 1,
                                            );
                                          },
                                        ),
                                        borderData: FlBorderData(show: false),
                                        barGroups: [
                                          BarChartGroupData(
                                            x: 0,
                                            barRods: [
                                              BarChartRodData(
                                                toY:
                                                    allOverTotalRounds
                                                        .toDouble(),
                                                color: Colors.blue,
                                                width: 40,
                                                borderRadius:
                                                    const BorderRadius.only(
                                                      topLeft: Radius.circular(
                                                        4,
                                                      ),
                                                      topRight: Radius.circular(
                                                        4,
                                                      ),
                                                    ),
                                                backDrawRodData:
                                                    BackgroundBarChartRodData(
                                                      show: true,
                                                      toY: 20,
                                                      color: Colors.transparent,
                                                    ),
                                              ),
                                            ],
                                          ),
                                          BarChartGroupData(
                                            x: 0,
                                            barRods: [
                                              BarChartRodData(
                                                toY: totalGames.toDouble(),
                                                color: Colors.purple,
                                                width: 40,
                                                borderRadius:
                                                    const BorderRadius.only(
                                                      topLeft: Radius.circular(
                                                        4,
                                                      ),
                                                      topRight: Radius.circular(
                                                        4,
                                                      ),
                                                    ),
                                                backDrawRodData:
                                                    BackgroundBarChartRodData(
                                                      show: true,
                                                      toY: 20,
                                                      color: Colors.transparent,
                                                    ),
                                              ),
                                            ],
                                          ),
                                          BarChartGroupData(
                                            x: 1,
                                            barRods: [
                                              BarChartRodData(
                                                toY: allOverStreak.toDouble(),
                                                color: Colors.orange,
                                                width: 40,
                                                borderRadius:
                                                    const BorderRadius.only(
                                                      topLeft: Radius.circular(
                                                        4,
                                                      ),
                                                      topRight: Radius.circular(
                                                        4,
                                                      ),
                                                    ),
                                                backDrawRodData:
                                                    BackgroundBarChartRodData(
                                                      show: true,
                                                      toY: 20,
                                                      color: Colors.transparent,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              else
                                SizedBox(
                                  height: 180,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.bar_chart,
                                          size: 48,
                                          color:
                                              isDark
                                                  ? Colors.grey[700]
                                                  : Colors.grey[300],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'No data available',
                                          style: GoogleFonts.outfit(
                                            color:
                                                isDark
                                                    ? Colors.grey[600]
                                                    : Colors.grey[400],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ];

              if (isMobile) {
                return Column(children: charts);
              } else {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: charts,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // Helper method for mini stats
  Widget _buildMiniStat(String label, String value, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [color.withOpacity(0.2), color.withOpacity(0.06)],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 12,
              color: isDark ? Colors.grey[500] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // Updated legend item
  Widget _buildLegendItem(String title, Color color, int value, bool isDark) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '($value)',
          style: GoogleFonts.outfit(
            fontSize: 12,
            color: isDark ? Colors.grey[500] : Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildLegend(String title, Color color, bool isDark) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 12,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget wRFXGameHistoryFilterDropdown(
    bool isDark,
    ThemeProvider themeProvider,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: resultFilter,
          icon: Icon(
            Icons.filter_list,
            size: 18,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
          dropdownColor: isDark ? Colors.grey[800] : Colors.white,
          style: GoogleFonts.outfit(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 14,
          ),
          items:
              ['All', 'Recent', 'High Score'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
          onChanged: (newValue) {
            if (newValue != null) {
              setState(() => resultFilter = newValue);
            }
          },
        ),
      ),
    );
  }

  Widget wRFXGameHistoryItem(
    dynamic game,
    int index,
    bool isDark,
    ThemeProvider themeProvider,
  ) {
    // Format timestamp
    final date = game.timestamp;
    final dateStr = DateFormat('hh:mm a, d MMM yyyy').format(date);

    // Calculate accuracy
    final total = game.correctAnswers + game.wrongAnswers;
    final accuracy =
        total > 0
            ? ((game.correctAnswers / total) * 100).toStringAsFixed(1)
            : '0.0';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isDark ? Colors.grey[900] : Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[100]!),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),

          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: themeProvider.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Text(
                '#${index + 1}',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  color: themeProvider.primaryColor,
                  fontSize: 12,
                ),
              ),
            ),
            title: Text(
              'Score: ${game.score}',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            subtitle: Text(
              dateStr,
              style: GoogleFonts.outfit(
                color: isDark ? Colors.grey[500] : Colors.grey[600],
                fontSize: 12,
                height: 1.8,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    WordReflexShareDialog.show(context, game, themeProvider);
                  },
                  icon: const Icon(Icons.picture_as_pdf),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: isDark ? Colors.grey[500] : Colors.grey[400],
                ),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color:
                        isDark
                            ? Colors.black.withOpacity(0.2)
                            : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment:
                        MediaQuery.of(context).size.width < 600
                            ? WrapAlignment.spaceBetween
                            : WrapAlignment.spaceEvenly,
                    children: [
                      wRFXGameStatDetail(
                        'Total Rounds',
                        '${game.totalRounds}',
                        Colors.purple,
                        isDark,
                        Icons.layers,
                      ),
                      wRFXGameStatDetail(
                        'Correct',
                        '${game.correctAnswers}',
                        Color(0xFF4CAF50),
                        isDark,
                        Icons.check_circle_rounded,
                      ),
                      wRFXGameStatDetail(
                        'Wrong',
                        '${game.wrongAnswers}',
                        Colors.red,
                        isDark,
                        Icons.cancel_rounded,
                      ),

                      wRFXGameStatDetail(
                        'Streak',
                        '${game.streak}',
                        Colors.orange,
                        isDark,
                        Icons.local_fire_department,
                      ),
                      wRFXGameStatDetail(
                        'Accuracy',
                        '$accuracy%',
                        Color(0xFF64B5F6),
                        isDark,
                        CupertinoIcons.scope,
                      ),
                      wRFXGameStatDetail(
                        'Time',
                        '${game.gameDuration}s',
                        Colors.lime,
                        isDark,
                        Icons.timer,
                      ),
                    ],
                  ),
                ),
              ),
              if (game.roundResults.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(
                    height: 1,
                    color: isDark ? Colors.grey[800] : Colors.grey[200],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Word History',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            '${game.roundResults.length} Words',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...game.roundResults.map<Widget>(
                        (round) => wRFXGameRoundResultItem(
                          round,
                          isDark,
                          themeProvider,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget wRFXGameStatDetail(
    String label,
    String value,
    Color color,
    bool isDark,
    IconData icon,
  ) {
    return Container(
      margin: EdgeInsets.all(8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.05), color.withOpacity(0.02)],
        ),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated icon
          Container(
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            padding: EdgeInsets.all(10),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: 12),

          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Flexible(
                      child: Text(
                        value,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                          color: isDark ? Colors.white : Colors.grey[900],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  label,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget wRFXGameRoundResultItem(
    dynamic round,
    bool isDark,
    ThemeProvider themeProvider,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800]!.withOpacity(0.3) : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color:
              round.isCorrect
                  ? Colors.transparent
                  : Colors.red.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:
                  round.isCorrect
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              round.isCorrect ? Icons.check : Icons.close,
              size: 16,
              color: round.isCorrect ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      round.mainWord.toUpperCase(),
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_right_alt,
                      size: 16,
                      color: isDark ? Colors.grey[600] : Colors.grey[400],
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        round.userAnswer,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: round.isCorrect ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
                if (!round.isCorrect) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Correct: ',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: isDark ? Colors.grey[500] : Colors.grey[600],
                        ),
                      ),
                      Text(
                        round.correctAnswer,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.grey[300] : Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
