// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:typing_speed_master/providers/theme_provider.dart';
import '../models/typing_result.dart';
import '../widgets/stats_card.dart';

class ResultsScreen extends StatefulWidget {
  final TypingResult result;
  final VoidCallback onBackToTest;
  final VoidCallback onBackToDashboard;

  const ResultsScreen({
    super.key,
    required this.result,
    required this.onBackToTest,
    required this.onBackToDashboard,
  });

  @override
  _ResultsScreenState createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  late ConfettiController _confettiController;
  late List<TypingStatData> _chartData;
  late List<TypingStatData> _chartDataPerformance;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    if (widget.result.wpm > 40 && widget.result.accuracy > 90) {
      _confettiController.play();
    }

    _chartData = [
      TypingStatData('Correct', widget.result.correctChars.toDouble()),
      TypingStatData('Incorrect', widget.result.incorrectChars.toDouble()),
      TypingStatData('Total', widget.result.totalChars.toDouble()),
    ];

    double difficultyValue;
    switch (widget.result.difficulty.toLowerCase()) {
      case 'easy':
        difficultyValue = 1;
        break;
      case 'medium':
        difficultyValue = 2;
        break;
      case 'hard':
        difficultyValue = 3;
        break;
      default:
        difficultyValue = 0;
    }

    _chartDataPerformance = [
      TypingStatData('WPM', widget.result.wpm.toDouble()),
      TypingStatData('Accuracy', widget.result.accuracy.toDouble()),
      TypingStatData('Duration', widget.result.duration.inSeconds.toDouble()),
      TypingStatData('Difficulty', difficultyValue),
    ];
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      child: LayoutBuilder(
        key: ValueKey(
          'results_screen_${widget.result.timestamp.millisecondsSinceEpoch}',
        ),
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth > 1000;
          final isTablet =
              constraints.maxWidth > 600 && constraints.maxWidth <= 1000;
          final isMobile = constraints.maxWidth <= 600;
          final themeProvider = Provider.of<ThemeProvider>(context);

          final horizontalPadding =
              isDesktop
                  ? 100.0
                  : isTablet
                  ? 40.0
                  : 20.0;

          final headerFontSize =
              isDesktop
                  ? 36.0
                  : isTablet
                  ? 30.0
                  : 26.0;
          final textFontSize =
              isDesktop
                  ? 20.0
                  : isTablet
                  ? 18.0
                  : 16.0;
          final gridCrossAxisCount =
              isDesktop
                  ? 4
                  : isTablet
                  ? 3
                  : 2;

          return Stack(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 20,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(
                        headerFontSize,
                        textFontSize,
                        themeProvider.isDarkMode,
                        isMobile,
                      ),
                      const SizedBox(height: 20),
                      _buildStatsGrid(gridCrossAxisCount),
                      const SizedBox(height: 20),
                      _buildDetailedStats(
                        textFontSize,
                        isMobile,
                        themeProvider.isDarkMode,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              if (widget.result.wpm > 40 && widget.result.accuracy > 90)
                Align(
                  alignment: Alignment.topCenter,
                  child: ConfettiWidget(
                    confettiController: _confettiController,
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
    );
  }

  Widget _buildHeader(
    double headerFontSize,
    double textFontSize,
    bool isDarkTheme,
    bool isMobile,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Test Completed!',
              style: TextStyle(
                fontSize: headerFontSize,
                fontWeight: FontWeight.bold,
                color: isDarkTheme ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Great job! Here are your results',
              style: TextStyle(fontSize: textFontSize, color: Colors.grey[600]),
            ),
          ],
        ),
        _buildActionButtons(isMobile),
      ],
    );
  }

  Widget _buildStatsGrid(int crossAxisCount) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2.5,
      ),
      children: [
        StatsCard(
          title: 'Words Per Minute',
          value: widget.result.wpm.toString(),
          unit: 'WPM',
          color: Colors.blue,
          icon: Icons.speed,
          isDarkMode: themeProvider.isDarkMode,
        ),
        StatsCard(
          title: 'Accuracy',
          value: widget.result.accuracy.toStringAsFixed(1),
          unit: '%',
          color: Colors.green,
          icon: Icons.flag,
          isDarkMode: themeProvider.isDarkMode,
        ),
        StatsCard(
          title: 'Duration',
          value: widget.result.duration.inSeconds.toString(),
          unit: 'seconds',
          color: Colors.orange,
          icon: Icons.timer,
          isDarkMode: themeProvider.isDarkMode,
        ),
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

  Widget _buildDetailedStats(
    double textFontSize,
    bool isMobile,
    bool isDarkTheme,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkTheme ? Colors.black12 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkTheme ? Colors.grey[800]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detailed Statistics',
            style: TextStyle(
              fontSize: textFontSize + 2,
              fontWeight: FontWeight.bold,
              color: isDarkTheme ? Colors.white : Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildStatItem(
                  'Correct Characters',
                  widget.result.correctChars.toString(),
                  Colors.green,
                  isDarkTheme,
                ),
                const SizedBox(width: 20),
                _buildStatItem(
                  'Incorrect Characters',
                  widget.result.incorrectChars.toString(),
                  Colors.red,
                  isDarkTheme,
                ),
                const SizedBox(width: 20),
                _buildStatItem(
                  'Total Characters',
                  widget.result.totalChars.toString(),
                  Colors.blue,
                  isDarkTheme,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Performance Overview',
            style: TextStyle(
              fontSize: textFontSize + 2,
              fontWeight: FontWeight.bold,
              color: isDarkTheme ? Colors.white : Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            height: isMobile ? 250 : 350,
            child: SfCartesianChart(
              primaryXAxis: CategoryAxis(
                majorGridLines: const MajorGridLines(width: 0),
                labelStyle: TextStyle(
                  color: isDarkTheme ? Colors.grey[300] : Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              primaryYAxis: NumericAxis(
                axisLine: const AxisLine(width: 0),
                majorTickLines: const MajorTickLines(size: 0),
                labelStyle: TextStyle(
                  color: isDarkTheme ? Colors.grey[300] : Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
                majorGridLines: MajorGridLines(
                  color: isDarkTheme ? Colors.grey[700] : Colors.grey[300],
                  dashArray: const [5, 5],
                ),
              ),
              tooltipBehavior: TooltipBehavior(
                enable: true,
                header: '',
                canShowMarker: true,
                tooltipPosition: TooltipPosition.pointer,
                color: isDarkTheme ? Colors.grey[300] : Colors.grey[800],
                textStyle: TextStyle(
                  color: isDarkTheme ? Colors.black87 : Colors.white,
                ),
              ),
              series: <CartesianSeries>[
                ColumnSeries<TypingStatData, String>(
                  dataSource: _chartDataPerformance,
                  xValueMapper: (TypingStatData data, _) => data.label,
                  yValueMapper: (TypingStatData data, _) => data.value,
                  gradient: LinearGradient(
                    colors:
                        isDarkTheme
                            ? [Colors.blueAccent, Colors.lightBlueAccent]
                            : [Colors.lightBlueAccent, Colors.blueAccent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  dataLabelSettings: DataLabelSettings(
                    isVisible: true,
                    textStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDarkTheme ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'Character Analysis',
            style: TextStyle(
              fontSize: textFontSize + 2,
              fontWeight: FontWeight.bold,
              color: isDarkTheme ? Colors.white : Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            height: isMobile ? 250 : 350,
            child: SfCartesianChart(
              primaryXAxis: CategoryAxis(
                majorGridLines: const MajorGridLines(width: 0),
                labelStyle: TextStyle(
                  color: isDarkTheme ? Colors.grey[300] : Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              primaryYAxis: NumericAxis(
                axisLine: const AxisLine(width: 0),
                majorTickLines: const MajorTickLines(size: 0),
                labelStyle: TextStyle(
                  color: isDarkTheme ? Colors.grey[300] : Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
                majorGridLines: MajorGridLines(
                  color: isDarkTheme ? Colors.grey[700] : Colors.grey[300],
                  dashArray: const [5, 5],
                ),
              ),
              tooltipBehavior: TooltipBehavior(
                enable: true,
                header: '',
                canShowMarker: true,
                tooltipPosition: TooltipPosition.pointer,
                color: isDarkTheme ? Colors.grey[300] : Colors.grey[800],
                textStyle: TextStyle(
                  color: isDarkTheme ? Colors.black87 : Colors.white,
                ),
              ),
              series: <CartesianSeries>[
                ColumnSeries<TypingStatData, String>(
                  dataSource: _chartData,
                  xValueMapper: (TypingStatData data, _) => data.label,
                  yValueMapper: (TypingStatData data, _) => data.value,
                  gradient: LinearGradient(
                    colors:
                        isDarkTheme
                            ? [Colors.green, Colors.lightGreenAccent]
                            : [Colors.lightGreenAccent, Colors.green],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  dataLabelSettings: DataLabelSettings(
                    isVisible: true,
                    textStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDarkTheme ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    Color color,
    bool isDarkTheme,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool isMobile) {
    return isMobile
        ? Column(
          children: [
            IconButton.filled(
              onPressed: widget.onBackToTest,
              icon: Icon(FontAwesomeIcons.undoAlt),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: widget.onBackToDashboard,
              style: const ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Colors.amber),
              ),
              child: Text(
                'Dashboard',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        )
        : Row(
          children: [
            IconButton.filled(
              onPressed: widget.onBackToTest,
              icon: Icon(FontAwesomeIcons.undoAlt),
            ),
            const SizedBox(width: 16),
            TextButton(
              onPressed: widget.onBackToDashboard,
              style: const ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Colors.amber),
              ),
              child: Text(
                'Dashboard',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        );
  }
}

class TypingStatData {
  final String label;
  final double value;

  TypingStatData(this.label, this.value);
}
