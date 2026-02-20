// ignore_for_file: library_private_types_in_public_api, deprecated_member_use, invalid_use_of_visible_for_testing_member
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_adsense/experimental/ad_unit_widget.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:typing_speed_master/features/typing_test/provider/typing_test_provider.dart';
import 'package:typing_speed_master/models/typing_stat_data.dart';
import 'package:typing_speed_master/theme/provider/theme_provider.dart';
import 'package:typing_speed_master/features/typing_test/widget/character_analysis_widget.dart';
import '../../models/typing_test_result_model.dart';
import '../../widgets/custom_stats_card.dart';
import 'package:typing_speed_master/providers/router_provider.dart';

class ResultsScreen extends StatefulWidget {
  final TypingTestResultModel result;
  final bool isViewDetails;
  final bool shouldSaveResult;
  final String? from;

  const ResultsScreen({
    super.key,
    required this.result,
    this.isViewDetails = false,
    this.shouldSaveResult = true,
    this.from,
  });

  @override
  _ResultsScreenState createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen>
    with SingleTickerProviderStateMixin {
  late ConfettiController confettiController;
  late List<TypingStatData> chartData;
  late List<TypingStatData> chartDataPerformance;
  late AnimationController animationController;
  late Animation<double> animations;
  bool showCPM = false;
  bool showMinutes = false;

  @override
  void initState() {
    super.initState();
    confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    if (widget.result.wpm > 40 && widget.result.accuracy > 90) {
      confettiController.play();
    }

    chartData = [
      TypingStatData('Correct', widget.result.correctChars.toDouble()),
      TypingStatData('Incorrect', widget.result.incorrectChars.toDouble()),
      TypingStatData('Total Chars', widget.result.totalChars.toDouble()),
      TypingStatData(
        'Words Typed',
        widget.result.userInput
            .split(' ')
            .where((w) => w.isNotEmpty)
            .length
            .toDouble(),
      ),
      TypingStatData(
        'Original Words',
        widget.result.originalText
            .split(' ')
            .where((w) => w.isNotEmpty)
            .length
            .toDouble(),
      ),
    ];

    chartDataPerformance = [
      TypingStatData(
        'WPM',
        double.parse(widget.result.wpm.toDouble().toStringAsFixed(2)),
      ),
      TypingStatData(
        'Consistency',
        double.parse(widget.result.consistency.toDouble().toStringAsFixed(2)),
      ),
      TypingStatData(
        'Accuracy',
        double.parse(widget.result.accuracy.toDouble().toStringAsFixed(2)),
      ),
      TypingStatData(
        'Duration',
        double.parse(
          widget.result.duration.inSeconds.toDouble().toStringAsFixed(2),
        ),
      ),
    ];

    animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    animations = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOutCubic,
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      animationController.forward();
    });
  }

  @override
  void dispose() {
    confettiController.dispose();
    animationController.dispose();
    super.dispose();
  }

  void onBackToTest() {
    final routerProvider = Provider.of<RouterProvider>(context, listen: false);
    routerProvider.setSelectedIndex(0);

    context.go('/');
  }

  void onBackToDashboard() async {
    final routerProvider = Provider.of<RouterProvider>(context, listen: false);
    routerProvider.setSelectedIndex(1);

    final typingProvider = Provider.of<TypingProvider>(context, listen: false);

    typingProvider.getAllRecentResults();

    context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    // final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      body: KeyedSubtree(
        key: ValueKey(
          'results_screen_${widget.result.timestamp.millisecondsSinceEpoch}',
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth > 1200;
                  final isTablet =
                      constraints.maxWidth > 600 &&
                      constraints.maxWidth <= 1200;
                  final isMobile = constraints.maxWidth <= 600;
                  final isSmallMobile = constraints.maxWidth <= 400;

                  final headerFontSize =
                      isDesktop
                          ? 36.0
                          : isTablet
                          ? 30.0
                          : isSmallMobile
                          ? 22.0
                          : 26.0;

                  final titleFontSize =
                      isDesktop
                          ? 24.0
                          : isTablet
                          ? 20.0
                          : isSmallMobile
                          ? 16.0
                          : 18.0;

                  final textFontSize =
                      isDesktop
                          ? 18.0
                          : isTablet
                          ? 16.0
                          : isSmallMobile
                          ? 14.0
                          : 16.0;

                  final chartHeight =
                      isDesktop
                          ? 400.0
                          : isTablet
                          ? 300.0
                          : isSmallMobile
                          ? 220.0
                          : 250.0;

                  final statItemSpacing =
                      isDesktop
                          ? 32.0
                          : isTablet
                          ? 24.0
                          : isSmallMobile
                          ? 16.0
                          : 20.0;
                  final themeProvider = Provider.of<ThemeProvider>(context);
                  return Stack(
                    children: [
                      Padding(
                        padding:
                            isDesktop
                                ? EdgeInsets.symmetric(
                                  vertical: 50,
                                  horizontal:
                                      MediaQuery.of(context).size.width / 6,
                                )
                                : EdgeInsets.all(40),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!widget.isViewDetails)
                                resultHeader(
                                  headerFontSize,
                                  textFontSize,
                                  isDesktop,
                                  isTablet,
                                  isMobile,
                                  isSmallMobile,
                                ),
                              if (!widget.isViewDetails)
                                SizedBox(height: isDesktop ? 32.0 : 20.0),
                              resultStatsSection(
                                isDesktop,
                                isTablet,
                                isMobile,
                                isSmallMobile,
                              ),
                              SizedBox(height: isDesktop ? 40.0 : 20.0),
                              resultDetailedStats(
                                titleFontSize,
                                textFontSize,
                                chartHeight,
                                statItemSpacing,
                                isDesktop,
                                isTablet,
                                isMobile,
                                isSmallMobile,
                              ),
                              SizedBox(height: isDesktop ? 32.0 : 20.0),
                              resultErrorAnalysisSection(
                                themeProvider,
                                isDesktop,
                                isTablet,
                                isMobile,
                                isSmallMobile,
                              ),

                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: AdUnitWidget(
                                  adClient: "3779258307133143",
                                  configuration:
                                      AdUnitConfiguration.displayAdUnit(
                                        adSlot: '4355381273',
                                        isAdTest: true,
                                        isFullWidthResponsive: true,
                                        adFormat: AdFormat.AUTO,
                                      ),
                                  onInjected: () {
                                    debugPrint("Ad Injected Successfully");
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (widget.result.wpm > 40 && widget.result.accuracy > 90)
                        Align(
                          alignment: Alignment.topCenter,
                          child: ConfettiWidget(
                            confettiController: confettiController,
                            blastDirectionality: BlastDirectionality.explosive,
                            shouldLoop: false,
                            colors: const [
                              Colors.green,
                              Colors.blue,
                              Colors.orange,
                              Colors.purple,
                              Colors.red,
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ),
              // FooterWidget(themeProvider: themeProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget resultHeader(
    double headerFontSize,
    double textFontSize,
    bool isDesktop,
    bool isTablet,
    bool isMobile,
    bool isSmallMobile,
  ) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    if (isSmallMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.isViewDetails ? "View Results" : 'Test Completed!',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: themeProvider.isDarkMode ? Colors.white : Colors.grey[800],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Great job! Here are your results',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color:
                  themeProvider.isDarkMode
                      ? Colors.grey[400]
                      : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          resultActionButtons(isDesktop, isTablet, isMobile, isSmallMobile),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.isViewDetails ? "View Results" : 'Test Completed!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color:
                      themeProvider.isDarkMode
                          ? Colors.white
                          : Colors.grey[800],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Great job! Here are your results',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color:
                      themeProvider.isDarkMode
                          ? Colors.grey[400]
                          : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        if (!isSmallMobile)
          widget.isViewDetails
              ? SizedBox.shrink()
              : resultActionButtons(
                isDesktop,
                isTablet,
                isMobile,
                isSmallMobile,
              ),
      ],
    );
  }

  Widget resultStatsSection(
    bool isDesktop,
    bool isTablet,
    bool isMobile,
    bool isSmallMobile,
  ) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    if (isDesktop) {
      return Row(
        children: [
          Expanded(
            child: CustomStatsCard(
              title: showCPM ? 'Characters Per Minute' : 'Words Per Minute',
              value:
                  showCPM
                      ? widget.result.cpm.toString()
                      : widget.result.wpm.toString(),
              unit: showCPM ? 'CPM' : 'WPM',
              color: Colors.blue,
              icon: Icons.speed,
              isDarkMode: themeProvider.isDarkMode,
              isExtraButton: true,
              extraWidgetToolTip:
                  !showCPM ? 'Characters Per Minute' : 'Words Per Minute',
              onTapExtraWidget: () {
                setState(() {
                  showCPM = !showCPM;
                });
              },
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: CustomStatsCard(
              title: 'Consistency',
              value: widget.result.consistency.toString(),
              unit: '%',
              color: Colors.pink,
              icon: FontAwesomeIcons.bolt,
              isDarkMode: themeProvider.isDarkMode,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: CustomStatsCard(
              title: 'Accuracy',
              value: widget.result.accuracy.toStringAsFixed(1),
              unit: '%',
              color: Colors.green,
              icon: Icons.flag,
              isDarkMode: themeProvider.isDarkMode,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: CustomStatsCard(
              title: 'Duration',
              value:
                  showMinutes
                      ? (widget.result.duration.inSeconds / 60).toStringAsFixed(
                        1,
                      )
                      : widget.result.duration.inSeconds.toString(),
              unit: showMinutes ? 'minutes' : 'seconds',
              extraWidgetToolTip: !showMinutes ? 'minutes' : 'seconds',
              color: Colors.orange,
              icon: Icons.timer,
              isDarkMode: themeProvider.isDarkMode,
              isExtraButton: true,
              onTapExtraWidget: () {
                setState(() {
                  showMinutes = !showMinutes;
                });
              },
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: CustomStatsCard(
              title: 'Difficulty',
              value: widget.result.difficulty,
              unit: '',
              color: Colors.purple,
              icon: Icons.leaderboard,
              isDarkMode: themeProvider.isDarkMode,
            ),
          ),
        ],
      );
    } else if (isTablet) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: CustomStatsCard(
                  title: showCPM ? 'Characters Per Minute' : 'Words Per Minute',
                  value:
                      showCPM
                          ? widget.result.cpm.toString()
                          : widget.result.wpm.toString(),
                  unit: showCPM ? 'CPM' : 'WPM',
                  color: Colors.blue,
                  icon: Icons.speed,
                  isDarkMode: themeProvider.isDarkMode,
                  isExtraButton: true,
                  onTapExtraWidget: () {
                    setState(() {
                      showCPM = !showCPM;
                    });
                  },
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: CustomStatsCard(
                  title: 'Consistency',
                  value: widget.result.consistency.toString(),
                  unit: '%',
                  color: Colors.pink,
                  icon: FontAwesomeIcons.bolt,
                  isDarkMode: themeProvider.isDarkMode,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CustomStatsCard(
                  title: 'Accuracy',
                  value: widget.result.accuracy.toStringAsFixed(1),
                  unit: '%',
                  color: Colors.green,
                  icon: Icons.flag,
                  isDarkMode: themeProvider.isDarkMode,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: CustomStatsCard(
                  title: 'Duration',
                  value:
                      showMinutes
                          ? (widget.result.duration.inSeconds / 60)
                              .toStringAsFixed(1)
                          : widget.result.duration.inSeconds.toString(),
                  unit: showMinutes ? 'minutes' : 'seconds',
                  color: Colors.orange,
                  icon: Icons.timer,
                  isDarkMode: themeProvider.isDarkMode,
                  isExtraButton: true,
                  onTapExtraWidget: () {
                    setState(() {
                      showMinutes = !showMinutes;
                    });
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: CustomStatsCard(
                  title: 'Difficulty',
                  value: widget.result.difficulty,
                  unit: '',
                  color: Colors.purple,
                  icon: Icons.leaderboard,
                  isDarkMode: themeProvider.isDarkMode,
                ),
              ),
              Expanded(child: SizedBox()),
            ],
          ),
        ],
      );
    } else if (isMobile && !isSmallMobile) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: CustomStatsCard(
                  title: showCPM ? 'Characters Per Minute' : 'Words Per Minute',
                  value:
                      showCPM
                          ? widget.result.cpm.toString()
                          : widget.result.wpm.toString(),
                  unit: showCPM ? 'CPM' : 'WPM',
                  color: Colors.blue,
                  icon: Icons.speed,
                  isDarkMode: themeProvider.isDarkMode,
                  isExtraButton: true,
                  onTapExtraWidget: () {
                    setState(() {
                      showCPM = !showCPM;
                    });
                  },
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: CustomStatsCard(
                  title: 'Consistency',
                  value: widget.result.consistency.toString(),
                  unit: '%',
                  color: Colors.pink,
                  icon: FontAwesomeIcons.bolt,
                  isDarkMode: themeProvider.isDarkMode,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CustomStatsCard(
                  title: 'Accuracy',
                  value: widget.result.accuracy.toStringAsFixed(1),
                  unit: '%',
                  color: Colors.green,
                  icon: Icons.flag,
                  isDarkMode: themeProvider.isDarkMode,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: CustomStatsCard(
                  title: 'Duration',
                  value:
                      showMinutes
                          ? (widget.result.duration.inSeconds / 60)
                              .toStringAsFixed(1)
                          : widget.result.duration.inSeconds.toString(),
                  unit: showMinutes ? 'minutes' : 'seconds',
                  color: Colors.orange,
                  icon: Icons.timer,
                  isDarkMode: themeProvider.isDarkMode,
                  isExtraButton: true,
                  onTapExtraWidget: () {
                    setState(() {
                      showMinutes = !showMinutes;
                    });
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: CustomStatsCard(
                  title: 'Difficulty',
                  value: widget.result.difficulty,
                  unit: '',
                  color: Colors.purple,
                  icon: Icons.leaderboard,
                  isDarkMode: themeProvider.isDarkMode,
                ),
              ),
              Expanded(child: SizedBox()),
            ],
          ),
        ],
      );
    } else {
      return Column(
        children: [
          CustomStatsCard(
            title: showCPM ? 'Characters Per Minute' : 'Words Per Minute',
            value:
                showCPM
                    ? widget.result.cpm.toString()
                    : widget.result.wpm.toString(),
            unit: showCPM ? 'CPM' : 'WPM',
            color: Colors.blue,
            icon: Icons.speed,
            isDarkMode: themeProvider.isDarkMode,
            isExtraButton: true,
            onTapExtraWidget: () {
              setState(() {
                showCPM = !showCPM;
              });
            },
          ),
          SizedBox(height: 12),
          CustomStatsCard(
            title: 'Accuracy',
            value: widget.result.accuracy.toStringAsFixed(1),
            unit: '%',
            color: Colors.green,
            icon: Icons.flag,
            isDarkMode: themeProvider.isDarkMode,
          ),
          SizedBox(height: 12),
          CustomStatsCard(
            title: 'Duration',
            value:
                showMinutes
                    ? (widget.result.duration.inSeconds / 60).toStringAsFixed(1)
                    : widget.result.duration.inSeconds.toString(),
            unit: showMinutes ? 'minutes' : 'seconds',
            color: Colors.orange,
            icon: Icons.timer,
            isDarkMode: themeProvider.isDarkMode,
            isExtraButton: true,
            onTapExtraWidget: () {
              setState(() {
                showMinutes = !showMinutes;
              });
            },
          ),
          SizedBox(height: 12),
          CustomStatsCard(
            title: 'Difficulty',
            value: widget.result.difficulty,
            unit: '',
            color: Colors.purple,
            icon: Icons.leaderboard,
            isDarkMode: themeProvider.isDarkMode,
          ),
        ],
      );
    }
  }

  Widget resultDetailedStats(
    double titleFontSize,
    double textFontSize,
    double chartHeight,
    double statItemSpacing,
    bool isDesktop,
    bool isTablet,
    bool isMobile,
    bool isSmallMobile,
  ) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
          decoration: BoxDecoration(
            color: themeProvider.isDarkMode ? Colors.black12 : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  themeProvider.isDarkMode
                      ? Colors.grey[800]!
                      : Colors.grey[200]!,
            ),
            boxShadow: [
              if (!themeProvider.isDarkMode)
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Performance Overview',
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                  color:
                      themeProvider.isDarkMode
                          ? Colors.white
                          : Colors.grey[800],
                ),
              ),
              SizedBox(height: isDesktop ? 20.0 : 32.0),

              SizedBox(
                height: chartHeight,
                child: AnimatedBuilder(
                  animation: animations,
                  builder: (context, child) {
                    return BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY:
                            chartDataPerformance
                                .map((e) => e.value)
                                .reduce((a, b) => a > b ? a : b) *
                            1.2,
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              return BarTooltipItem(
                                ' ${rod.toY.toStringAsFixed(1)}',
                                TextStyle(
                                  color: Colors.white,
                                  fontSize: isSmallMobile ? 10 : 12,
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
                              getTitlesWidget: (value, meta) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    chartDataPerformance[value.toInt()].label,
                                    style: TextStyle(
                                      color:
                                          themeProvider.isDarkMode
                                              ? Colors.grey[300]
                                              : Colors.grey[700],
                                      fontWeight: FontWeight.w500,
                                      fontSize: isSmallMobile ? 10 : 12,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              },
                              reservedSize: 40,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: TextStyle(
                                    color:
                                        themeProvider.isDarkMode
                                            ? Colors.grey[300]
                                            : Colors.grey[700],
                                    fontWeight: FontWeight.w500,
                                    fontSize: isSmallMobile ? 10 : 12,
                                  ),
                                );
                              },
                              reservedSize: 40,
                            ),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval:
                              (chartDataPerformance
                                      .map((e) => e.value)
                                      .reduce((a, b) => a > b ? a : b) *
                                  1.2) /
                              5,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color:
                                  themeProvider.isDarkMode
                                      ? Colors.grey[700]
                                      : Colors.grey[300],
                              strokeWidth: 1,
                              dashArray: [5, 5],
                            );
                          },
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups:
                            chartDataPerformance.asMap().entries.map((entry) {
                              final index = entry.key;
                              final data = entry.value;
                              final animatedValue =
                                  data.value * animations.value;

                              return BarChartGroupData(
                                x: index,
                                barRods: [
                                  BarChartRodData(
                                    toY: animatedValue,
                                    width:
                                        isMobile
                                            ? 55
                                            : isTablet
                                            ? 100
                                            : 140,
                                    borderRadius: BorderRadius.circular(8),
                                    gradient: LinearGradient(
                                      colors:
                                          themeProvider.isDarkMode
                                              ? [
                                                Colors.blueAccent,
                                                Colors.lightBlueAccent,
                                              ]
                                              : [
                                                Colors.lightBlueAccent,
                                                Colors.blueAccent,
                                              ],
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                    ),
                                  ),
                                ],
                                showingTooltipIndicators: [0],
                              );
                            }).toList(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: isDesktop ? 16.0 : 16.0),

        Container(
          width: double.infinity,
          padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
          decoration: BoxDecoration(
            color: themeProvider.isDarkMode ? Colors.black12 : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  themeProvider.isDarkMode
                      ? Colors.grey[800]!
                      : Colors.grey[200]!,
            ),
            boxShadow: [
              if (!themeProvider.isDarkMode)
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Character Analysis',
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                  color:
                      themeProvider.isDarkMode
                          ? Colors.white
                          : Colors.grey[800],
                ),
              ),
              SizedBox(height: isDesktop ? 20.0 : 40.0),
              isMobile || isTablet
                  ? Column(
                    children: [
                      SizedBox(
                        height: chartHeight,
                        child: AnimatedBuilder(
                          animation: animations,
                          builder: (context, child) {
                            return BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY:
                                    chartData
                                        .map((e) => e.value)
                                        .reduce((a, b) => a > b ? a : b) *
                                    1.2,
                                barTouchData: BarTouchData(
                                  enabled: true,
                                  touchTooltipData: BarTouchTooltipData(
                                    getTooltipItem: (
                                      group,
                                      groupIndex,
                                      rod,
                                      rodIndex,
                                    ) {
                                      return BarTooltipItem(
                                        rod.toY.toStringAsFixed(0),
                                        TextStyle(
                                          color: Colors.white,
                                          fontSize: isSmallMobile ? 10 : 12,
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
                                      getTitlesWidget: (value, meta) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            top: 8.0,
                                          ),
                                          child: Text(
                                            chartData[value.toInt()].label,
                                            style: TextStyle(
                                              color:
                                                  themeProvider.isDarkMode
                                                      ? Colors.grey[300]
                                                      : Colors.grey[700],
                                              fontWeight: FontWeight.w500,
                                              fontSize: isSmallMobile ? 10 : 12,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        );
                                      },
                                      reservedSize: 40,
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        return Text(
                                          value.toInt().toString(),
                                          style: TextStyle(
                                            color:
                                                themeProvider.isDarkMode
                                                    ? Colors.grey[300]
                                                    : Colors.grey[700],
                                            fontWeight: FontWeight.w500,
                                            fontSize: isSmallMobile ? 10 : 12,
                                          ),
                                        );
                                      },
                                      reservedSize: 40,
                                    ),
                                  ),
                                  topTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  rightTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                ),
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  horizontalInterval:
                                      (chartData
                                              .map((e) => e.value)
                                              .reduce((a, b) => a > b ? a : b) *
                                          1.2) /
                                      5,
                                  getDrawingHorizontalLine: (value) {
                                    return FlLine(
                                      color:
                                          themeProvider.isDarkMode
                                              ? Colors.grey[700]
                                              : Colors.grey[300],
                                      strokeWidth: 1,
                                      dashArray: [5, 5],
                                    );
                                  },
                                ),
                                borderData: FlBorderData(show: false),
                                barGroups:
                                    chartData.asMap().entries.map((entry) {
                                      final index = entry.key;
                                      final data = entry.value;
                                      final animatedValue =
                                          data.value * animations.value;

                                      return BarChartGroupData(
                                        x: index,
                                        barRods: [
                                          BarChartRodData(
                                            toY: animatedValue,
                                            width: isDesktop ? 68 : 18,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            gradient: LinearGradient(
                                              colors:
                                                  themeProvider.isDarkMode
                                                      ? [
                                                        Colors.green,
                                                        Colors.lightGreenAccent,
                                                      ]
                                                      : [
                                                        Colors.lightGreenAccent,
                                                        Colors.green,
                                                      ],
                                              begin: Alignment.bottomCenter,
                                              end: Alignment.topCenter,
                                            ),
                                          ),
                                        ],
                                        showingTooltipIndicators: [0],
                                      );
                                    }).toList(),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 16),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: chartHeight,
                            child: AnimatedBuilder(
                              animation: animations,
                              builder: (context, child) {
                                return PieChart(
                                  PieChartData(
                                    pieTouchData: PieTouchData(
                                      touchCallback:
                                          (
                                            FlTouchEvent event,
                                            pieTouchResponse,
                                          ) {},
                                      enabled: true,
                                    ),
                                    borderData: FlBorderData(show: false),
                                    sectionsSpace: 0,
                                    centerSpaceRadius: isSmallMobile ? 30 : 40,
                                    sections:
                                        chartData.asMap().entries.map((entry) {
                                          final index = entry.key;
                                          final data = entry.value;

                                          final colorPalette = [
                                            Colors.green,
                                            Colors.red,
                                            Colors.amber,
                                            Colors.deepPurple,
                                            Colors.blue,
                                          ];

                                          return PieChartSectionData(
                                            color:
                                                colorPalette[index %
                                                    colorPalette.length],
                                            value: double.parse(
                                              (data.value.toDouble() *
                                                      animations.value)
                                                  .toStringAsFixed(2),
                                            ),
                                            radius: 60,
                                            titleStyle: TextStyle(
                                              fontSize: isSmallMobile ? 10 : 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                            titlePositionPercentageOffset: 0.6,
                                            showTitle: true,
                                          );
                                        }).toList(),
                                  ),
                                );
                              },
                            ),
                          ),

                          AnimatedBuilder(
                            animation: animations,
                            builder: (context, child) {
                              return Wrap(
                                spacing: 12,
                                runSpacing: 8,
                                children:
                                    chartData.asMap().entries.map((entry) {
                                      final index = entry.key;
                                      final data = entry.value;
                                      final animatedValue =
                                          (data.value * animations.value)
                                              .toInt();

                                      final colorPalette = [
                                        Colors.green,
                                        Colors.red,
                                        Colors.amber,
                                        Colors.deepPurple,
                                        Colors.blue,
                                      ];
                                      final color =
                                          colorPalette[index %
                                              colorPalette.length];

                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 4,
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 10,
                                              height: 10,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.rectangle,
                                                color: color,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${data.label} - $animatedValue',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color:
                                                    themeProvider.isDarkMode
                                                        ? Colors.white
                                                        : Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  )
                  : Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: chartHeight,
                          child: AnimatedBuilder(
                            animation: animations,
                            builder: (context, child) {
                              return BarChart(
                                BarChartData(
                                  alignment: BarChartAlignment.spaceAround,
                                  maxY:
                                      chartData
                                          .map((e) => e.value)
                                          .reduce((a, b) => a > b ? a : b) *
                                      1.2,
                                  barTouchData: BarTouchData(
                                    enabled: true,
                                    touchTooltipData: BarTouchTooltipData(
                                      getTooltipItem: (
                                        group,
                                        groupIndex,
                                        rod,
                                        rodIndex,
                                      ) {
                                        return BarTooltipItem(
                                          rod.toY.toStringAsFixed(0),
                                          TextStyle(
                                            color: Colors.white,
                                            fontSize: isSmallMobile ? 10 : 12,
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
                                        getTitlesWidget: (value, meta) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              top: 8.0,
                                            ),
                                            child: Text(
                                              chartData[value.toInt()].label,
                                              style: TextStyle(
                                                color:
                                                    themeProvider.isDarkMode
                                                        ? Colors.grey[300]
                                                        : Colors.grey[700],
                                                fontWeight: FontWeight.w500,
                                                fontSize:
                                                    isSmallMobile ? 10 : 12,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          );
                                        },
                                        reservedSize: 40,
                                      ),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          return Text(
                                            value.toInt().toString(),
                                            style: TextStyle(
                                              color:
                                                  themeProvider.isDarkMode
                                                      ? Colors.grey[300]
                                                      : Colors.grey[700],
                                              fontWeight: FontWeight.w500,
                                              fontSize: isSmallMobile ? 10 : 12,
                                            ),
                                          );
                                        },
                                        reservedSize: 40,
                                      ),
                                    ),
                                    topTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    rightTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                  ),
                                  gridData: FlGridData(
                                    show: true,
                                    drawVerticalLine: false,
                                    horizontalInterval:
                                        (chartData
                                                .map((e) => e.value)
                                                .reduce(
                                                  (a, b) => a > b ? a : b,
                                                ) *
                                            1.2) /
                                        5,
                                    getDrawingHorizontalLine: (value) {
                                      return FlLine(
                                        color:
                                            themeProvider.isDarkMode
                                                ? Colors.grey[700]
                                                : Colors.grey[300],
                                        strokeWidth: 1,
                                        dashArray: [5, 5],
                                      );
                                    },
                                  ),
                                  borderData: FlBorderData(show: false),
                                  barGroups:
                                      chartData.asMap().entries.map((entry) {
                                        final index = entry.key;
                                        final data = entry.value;
                                        final animatedValue =
                                            data.value * animations.value;

                                        return BarChartGroupData(
                                          x: index,
                                          barRods: [
                                            BarChartRodData(
                                              toY: animatedValue,
                                              width: isDesktop ? 68 : 18,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              gradient: LinearGradient(
                                                colors:
                                                    themeProvider.isDarkMode
                                                        ? [
                                                          Colors.green,
                                                          Colors
                                                              .lightGreenAccent,
                                                        ]
                                                        : [
                                                          Colors
                                                              .lightGreenAccent,
                                                          Colors.green,
                                                        ],
                                                begin: Alignment.bottomCenter,
                                                end: Alignment.topCenter,
                                              ),
                                            ),
                                          ],
                                          showingTooltipIndicators: [0],
                                        );
                                      }).toList(),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: chartHeight,
                              child: AnimatedBuilder(
                                animation: animations,
                                builder: (context, child) {
                                  return PieChart(
                                    PieChartData(
                                      pieTouchData: PieTouchData(
                                        touchCallback:
                                            (
                                              FlTouchEvent event,
                                              pieTouchResponse,
                                            ) {},
                                        enabled: true,
                                      ),
                                      borderData: FlBorderData(show: false),
                                      sectionsSpace: 0,
                                      centerSpaceRadius:
                                          isSmallMobile ? 30 : 40,
                                      sections:
                                          chartData.asMap().entries.map((
                                            entry,
                                          ) {
                                            final index = entry.key;
                                            final data = entry.value;

                                            final colorPalette = [
                                              Colors.green,
                                              Colors.red,
                                              Colors.amber,
                                              Colors.deepPurple,
                                              Colors.blue,
                                            ];

                                            return PieChartSectionData(
                                              color:
                                                  colorPalette[index %
                                                      colorPalette.length],
                                              value: double.parse(
                                                (data.value.toDouble() *
                                                        animations.value)
                                                    .toStringAsFixed(2),
                                              ),
                                              radius: 60,
                                              titleStyle: TextStyle(
                                                fontSize:
                                                    isSmallMobile ? 10 : 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                              titlePositionPercentageOffset:
                                                  0.6,
                                              showTitle: true,
                                            );
                                          }).toList(),
                                    ),
                                  );
                                },
                              ),
                            ),

                            AnimatedBuilder(
                              animation: animations,
                              builder: (context, child) {
                                return Wrap(
                                  spacing: 12,
                                  runSpacing: 8,
                                  children:
                                      chartData.asMap().entries.map((entry) {
                                        final index = entry.key;
                                        final data = entry.value;
                                        final animatedValue =
                                            (data.value * animations.value)
                                                .toInt();

                                        final colorPalette = [
                                          Colors.green,
                                          Colors.red,
                                          Colors.amber,
                                          Colors.deepPurple,
                                          Colors.blue,
                                        ];
                                        final color =
                                            colorPalette[index %
                                                colorPalette.length];

                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 4,
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: 10,
                                                height: 10,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.rectangle,
                                                  color: color,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${data.label} - $animatedValue',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color:
                                                      themeProvider.isDarkMode
                                                          ? Colors.white
                                                          : Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
            ],
          ),
        ),
      ],
    );
  }

  Widget resultActionButtons(
    bool isDesktop,
    bool isTablet,
    bool isMobile,
    bool isSmallMobile,
  ) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    if (isSmallMobile) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: IconButton.filled(
              onPressed: onBackToTest,
              icon: Icon(FontAwesomeIcons.undoAlt, size: 20),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: TextButton(
              onPressed: onBackToDashboard,
              style: TextButton.styleFrom(
                backgroundColor: themeProvider.primaryColor,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                'Dashboard',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color:
                      themeProvider.primaryColor == Colors.amber ||
                              themeProvider.primaryColor == Colors.yellow ||
                              themeProvider.primaryColor == Colors.lime
                          ? Colors.black
                          : Colors.white,
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (isMobile) {
      return Column(
        children: [
          IconButton.filled(
            onPressed: onBackToTest,
            icon: Icon(FontAwesomeIcons.undoAlt),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onBackToDashboard,
            style: TextButton.styleFrom(
              backgroundColor: themeProvider.primaryColor,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color:
                    themeProvider.primaryColor == Colors.amber ||
                            themeProvider.primaryColor == Colors.yellow ||
                            themeProvider.primaryColor == Colors.lime
                        ? Colors.black
                        : Colors.white,
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        IconButton.filled(
          onPressed: onBackToTest,
          icon: Icon(FontAwesomeIcons.undoAlt),
          iconSize: isTablet ? 20 : 24,
        ),
        SizedBox(width: isTablet ? 12 : 16),
        TextButton(
          onPressed: onBackToDashboard,
          style: TextButton.styleFrom(
            backgroundColor: themeProvider.primaryColor,
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 20 : 24,
              vertical: isTablet ? 12 : 16,
            ),
          ),
          child: Text(
            'Dashboard',
            style: TextStyle(
              fontSize: isTablet ? 14 : 16,
              fontWeight: FontWeight.bold,
              color:
                  themeProvider.primaryColor == Colors.amber ||
                          themeProvider.primaryColor == Colors.yellow ||
                          themeProvider.primaryColor == Colors.lime
                      ? Colors.black
                      : Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget resultErrorAnalysisSection(
    ThemeProvider themeProvider,
    bool isDesktop,
    bool isTablet,
    bool isMobile,
    bool isSmallMobile,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? Colors.black12 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              themeProvider.isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
        ),
        boxShadow: [
          if (!themeProvider.isDarkMode)
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Text Comparison',
            style: TextStyle(
              fontSize:
                  isDesktop
                      ? 24.0
                      : isTablet
                      ? 20.0
                      : 18.0,
              fontWeight: FontWeight.bold,
              color: themeProvider.isDarkMode ? Colors.white : Colors.grey[800],
            ),
          ),
          SizedBox(height: isDesktop ? 24.0 : 16.0),

          CharacterAnalysisWidget(
            originalText: widget.result.originalText,
            userInput: widget.result.userInput,
            incorrectCharPositions: widget.result.incorrectCharPositions,
            isDarkMode: themeProvider.isDarkMode,
          ),

          SizedBox(height: isDesktop ? 16.0 : 12.0),
        ],
      ),
    );
  }
}
