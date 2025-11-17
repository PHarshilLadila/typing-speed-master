// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:typing_speed_master/models/typing_stat_data.dart';
import 'package:typing_speed_master/providers/theme_provider.dart';
import 'package:typing_speed_master/providers/typing_provider.dart';
import 'package:typing_speed_master/widgets/charecter_analysis_widget.dart';
import '../models/typing_result.dart';
import '../widgets/stats_card.dart';

class ResultsScreen extends StatefulWidget {
  final TypingResult result;
  final VoidCallback onBackToTest;
  final VoidCallback onBackToDashboard;
  final bool isViewDetails;
  final bool shouldSaveResult;

  const ResultsScreen({
    super.key,
    required this.result,
    required this.onBackToTest,
    required this.onBackToDashboard,
    this.isViewDetails = false,
    this.shouldSaveResult = true,
  });

  @override
  _ResultsScreenState createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  late ConfettiController confettiController;
  late List<TypingStatData> chartData;
  late List<TypingStatData> chartDataPerformance;

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
      TypingStatData('Total', widget.result.totalChars.toDouble()),
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
  }

  @override
  void dispose() {
    confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: KeyedSubtree(
        key: ValueKey(
          'results_screen_${widget.result.timestamp.millisecondsSinceEpoch}',
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 1200;
            final isTablet =
                constraints.maxWidth > 600 && constraints.maxWidth <= 1200;
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
                  padding: EdgeInsets.all(40),
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
                        SizedBox(height: isDesktop ? 32.0 : 20.0),
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
            child: StatsCard(
              title: 'Words Per Minute',
              value: widget.result.wpm.toString(),
              unit: 'WPM',
              color: Colors.blue,
              icon: Icons.speed,
              isDarkMode: themeProvider.isDarkMode,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: StatsCard(
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
            child: StatsCard(
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
            child: StatsCard(
              title: 'Duration',
              value: widget.result.duration.inSeconds.toString(),
              unit: 'seconds',
              color: Colors.orange,
              icon: Icons.timer,
              isDarkMode: themeProvider.isDarkMode,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: StatsCard(
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
                child: StatsCard(
                  title: 'Words Per Minute',
                  value: widget.result.wpm.toString(),
                  unit: 'WPM',
                  color: Colors.blue,
                  icon: Icons.speed,
                  isDarkMode: themeProvider.isDarkMode,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: StatsCard(
                  title: 'Consistency',
                  value: widget.result.duration.inSeconds.toString(),
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
                child: StatsCard(
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
                child: StatsCard(
                  title: 'Duration',
                  value: widget.result.duration.inSeconds.toString(),
                  unit: 'seconds',
                  color: Colors.orange,
                  icon: Icons.timer,
                  isDarkMode: themeProvider.isDarkMode,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: StatsCard(
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
                child: StatsCard(
                  title: 'Words Per Minute',
                  value: widget.result.wpm.toString(),
                  unit: 'WPM',
                  color: Colors.blue,
                  icon: Icons.speed,
                  isDarkMode: themeProvider.isDarkMode,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: StatsCard(
                  title: 'Consistency',
                  value: widget.result.duration.inSeconds.toString(),
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
                child: StatsCard(
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
                child: StatsCard(
                  title: 'Duration',
                  value: widget.result.duration.inSeconds.toString(),
                  unit: 'seconds',
                  color: Colors.orange,
                  icon: Icons.timer,
                  isDarkMode: themeProvider.isDarkMode,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: StatsCard(
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
          StatsCard(
            title: 'Words Per Minute',
            value: widget.result.wpm.toString(),
            unit: 'WPM',
            color: Colors.blue,
            icon: Icons.speed,
            isDarkMode: themeProvider.isDarkMode,
          ),
          SizedBox(height: 12),
          StatsCard(
            title: 'Accuracy',
            value: widget.result.accuracy.toStringAsFixed(1),
            unit: '%',
            color: Colors.green,
            icon: Icons.flag,
            isDarkMode: themeProvider.isDarkMode,
          ),
          SizedBox(height: 12),
          StatsCard(
            title: 'Duration',
            value: widget.result.duration.inSeconds.toString(),
            unit: 'seconds',
            color: Colors.orange,
            icon: Icons.timer,
            isDarkMode: themeProvider.isDarkMode,
          ),
          SizedBox(height: 12),
          StatsCard(
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
            'Performance Overview',
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
              color: themeProvider.isDarkMode ? Colors.white : Colors.grey[800],
            ),
          ),
          SizedBox(height: isDesktop ? 20.0 : 16.0),

          SizedBox(
            height: chartHeight,
            child: SfCartesianChart(
              primaryXAxis: CategoryAxis(
                majorGridLines: const MajorGridLines(width: 0),
                labelStyle: TextStyle(
                  color:
                      themeProvider.isDarkMode
                          ? Colors.grey[300]
                          : Colors.grey[700],
                  fontWeight: FontWeight.w500,
                  fontSize: isSmallMobile ? 10 : 12,
                ),
              ),
              primaryYAxis: NumericAxis(
                axisLine: const AxisLine(width: 0),
                majorTickLines: const MajorTickLines(size: 0),
                labelStyle: TextStyle(
                  color:
                      themeProvider.isDarkMode
                          ? Colors.grey[300]
                          : Colors.grey[700],
                  fontWeight: FontWeight.w500,
                  fontSize: isSmallMobile ? 10 : 12,
                ),
                majorGridLines: MajorGridLines(
                  color:
                      themeProvider.isDarkMode
                          ? Colors.grey[700]
                          : Colors.grey[300],
                  dashArray: const [5, 5],
                ),
              ),
              tooltipBehavior: TooltipBehavior(
                enable: true,
                header: '',
                canShowMarker: true,
                tooltipPosition: TooltipPosition.pointer,
                color:
                    themeProvider.isDarkMode
                        ? Colors.grey[300]
                        : Colors.grey[800],
                textStyle: TextStyle(
                  color:
                      themeProvider.isDarkMode ? Colors.black87 : Colors.white,
                  fontSize: isSmallMobile ? 10 : 12,
                ),
              ),
              series: <CartesianSeries>[
                ColumnSeries<TypingStatData, String>(
                  dataSource: chartDataPerformance,
                  xValueMapper: (TypingStatData data, _) => data.label,
                  yValueMapper: (TypingStatData data, _) => data.value,
                  gradient: LinearGradient(
                    colors:
                        themeProvider.isDarkMode
                            ? [Colors.blueAccent, Colors.lightBlueAccent]
                            : [Colors.lightBlueAccent, Colors.blueAccent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  dataLabelSettings: DataLabelSettings(
                    isVisible: !isSmallMobile,
                    textStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color:
                          themeProvider.isDarkMode
                              ? Colors.white
                              : Colors.black87,
                      fontSize: isSmallMobile ? 10 : 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: isDesktop ? 32.0 : 24.0),

          Text(
            'Character Analysis',
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
              color: themeProvider.isDarkMode ? Colors.white : Colors.grey[800],
            ),
          ),
          SizedBox(height: isDesktop ? 20.0 : 16.0),

          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: chartHeight,
                  child: SfCartesianChart(
                    primaryXAxis: CategoryAxis(
                      majorGridLines: const MajorGridLines(width: 0),
                      labelStyle: TextStyle(
                        color:
                            themeProvider.isDarkMode
                                ? Colors.grey[300]
                                : Colors.grey[700],
                        fontWeight: FontWeight.w500,
                        fontSize: isSmallMobile ? 10 : 12,
                      ),
                    ),
                    primaryYAxis: NumericAxis(
                      axisLine: const AxisLine(width: 0),
                      majorTickLines: const MajorTickLines(size: 0),
                      labelStyle: TextStyle(
                        color:
                            themeProvider.isDarkMode
                                ? Colors.grey[300]
                                : Colors.grey[700],
                        fontWeight: FontWeight.w500,
                        fontSize: isSmallMobile ? 10 : 12,
                      ),
                      majorGridLines: MajorGridLines(
                        color:
                            themeProvider.isDarkMode
                                ? Colors.grey[700]
                                : Colors.grey[300],
                        dashArray: const [5, 5],
                      ),
                    ),
                    tooltipBehavior: TooltipBehavior(
                      enable: true,
                      header: '',
                      canShowMarker: true,
                      tooltipPosition: TooltipPosition.pointer,
                      color:
                          themeProvider.isDarkMode
                              ? Colors.grey[300]
                              : Colors.grey[800],
                      textStyle: TextStyle(
                        color:
                            themeProvider.isDarkMode
                                ? Colors.black87
                                : Colors.white,
                        fontSize: isSmallMobile ? 10 : 12,
                      ),
                    ),
                    series: <CartesianSeries>[
                      ColumnSeries<TypingStatData, String>(
                        dataSource: chartData,
                        xValueMapper: (TypingStatData data, _) => data.label,
                        yValueMapper: (TypingStatData data, _) => data.value,
                        gradient: LinearGradient(
                          colors:
                              themeProvider.isDarkMode
                                  ? [Colors.green, Colors.lightGreenAccent]
                                  : [Colors.lightGreenAccent, Colors.green],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(8),
                        ),
                        dataLabelSettings: DataLabelSettings(
                          isVisible: !isSmallMobile,
                          textStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                themeProvider.isDarkMode
                                    ? Colors.white
                                    : Colors.black87,
                            fontSize: isSmallMobile ? 10 : 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: SizedBox(
                  height: chartHeight,
                  child: SfCircularChart(
                    tooltipBehavior: TooltipBehavior(
                      enable: true,
                      header: '',
                      format: 'point.x : point.y',
                      canShowMarker: true,
                      color:
                          themeProvider.isDarkMode
                              ? Colors.grey[300]
                              : Colors.grey[800],
                      textStyle: TextStyle(
                        color:
                            themeProvider.isDarkMode
                                ? Colors.black87
                                : Colors.white,
                        fontSize: isSmallMobile ? 10 : 12,
                      ),
                    ),
                    series: <CircularSeries>[
                      PieSeries<TypingStatData, String>(
                        dataSource: chartData,
                        xValueMapper: (TypingStatData data, _) => data.label,
                        yValueMapper: (TypingStatData data, _) => data.value,
                        dataLabelSettings: DataLabelSettings(
                          isVisible: true,
                          textStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                themeProvider.isDarkMode
                                    ? Colors.white
                                    : Colors.black87,
                            fontSize: isSmallMobile ? 10 : 12,
                          ),
                          labelPosition: ChartDataLabelPosition.outside,
                          connectorLineSettings: ConnectorLineSettings(
                            length: '20%',
                            color:
                                themeProvider.isDarkMode
                                    ? Colors.grey[300]
                                    : Colors.grey[700],
                          ),
                          builder: (
                            dynamic data,
                            dynamic point,
                            dynamic series,
                            int pointIndex,
                            int seriesIndex,
                          ) {
                            return Text('${data.label}: ${data.value}');
                          },
                        ),
                        pointColorMapper: (TypingStatData data, int index) {
                          final List<Color> colorPalette = [
                            Colors.amber,
                            Color(0xff1b3665),
                            Colors.purple,
                          ];

                          return colorPalette[index % colorPalette.length];
                        },
                        dataLabelMapper: (TypingStatData data, _) {
                          return '${data.label}\n${data.value}';
                        },
                        enableTooltip: true,
                        animationDuration: 1000,
                        opacity: 5,
                        strokeWidth: 0.5,
                      ),
                    ],
                    legend: Legend(
                      isVisible: chartData.length <= 8,
                      position: LegendPosition.bottom,
                      overflowMode: LegendItemOverflowMode.wrap,
                      textStyle: TextStyle(
                        color:
                            themeProvider.isDarkMode
                                ? Colors.grey[300]
                                : Colors.grey[700],
                        fontSize: isSmallMobile ? 10 : 12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget resultActionButtons(
    bool isDesktop,
    bool isTablet,
    bool isMobile,
    bool isSmallMobile,
  ) {
    if (isSmallMobile) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: IconButton.filled(
              onPressed: () {
                final typingProvider = Provider.of<TypingProvider>(
                  context,
                  listen: false,
                );
                typingProvider.resetCurrentTest();
                widget.onBackToTest();
              },
              icon: Icon(FontAwesomeIcons.undoAlt, size: 20),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: TextButton(
              onPressed: widget.onBackToDashboard,
              style: TextButton.styleFrom(
                backgroundColor: Colors.amber,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                'Dashboard',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
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
            onPressed: () {
              final typingProvider = Provider.of<TypingProvider>(
                context,
                listen: false,
              );
              typingProvider.resetCurrentTest();
              widget.onBackToTest();
            },
            icon: Icon(FontAwesomeIcons.undoAlt),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: widget.onBackToDashboard,
            style: TextButton.styleFrom(
              backgroundColor: Colors.amber,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        IconButton.filled(
          onPressed: () {
            final typingProvider = Provider.of<TypingProvider>(
              context,
              listen: false,
            );
            typingProvider.resetCurrentTest();
            widget.onBackToTest();
          },
          icon: Icon(FontAwesomeIcons.undoAlt),
          iconSize: isTablet ? 20 : 24,
        ),
        SizedBox(width: isTablet ? 12 : 16),
        TextButton(
          onPressed: widget.onBackToDashboard,
          style: TextButton.styleFrom(
            backgroundColor: Colors.amber,
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
              color: Colors.black,
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

          CharecterAnalysisWidget(
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
