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
  final bool isViewDetails;

  const ResultsScreen({
    super.key,
    required this.result,
    required this.onBackToTest,
    required this.onBackToDashboard,
    this.isViewDetails = false,
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
    _confettiController.dispose();
    super.dispose();
  }

  void _handleBack() {
    if (widget.isViewDetails) {
      Navigator.of(context).pop();
    } else {
      widget.onBackToDashboard();
    }
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

            final horizontalPadding =
                isDesktop
                    ? 100.0
                    : isTablet
                    ? 60.0
                    : isSmallMobile
                    ? 12.0
                    : 20.0;

            final verticalPadding =
                isDesktop
                    ? 40.0
                    : isTablet
                    ? 30.0
                    : widget.isViewDetails
                    ? 0.0
                    : 20.0;

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

            return Stack(
              children: [
                Padding(
                  padding: EdgeInsets.all(40),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!widget.isViewDetails)
                          _buildHeader(
                            headerFontSize,
                            textFontSize,
                            isDesktop,
                            isTablet,
                            isMobile,
                            isSmallMobile,
                          ),
                        if (!widget.isViewDetails)
                          SizedBox(height: isDesktop ? 32.0 : 20.0),
                        _buildStatsSection(
                          isDesktop,
                          isTablet,
                          isMobile,
                          isSmallMobile,
                        ),
                        SizedBox(height: isDesktop ? 32.0 : 20.0),
                        _buildDetailedStats(
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
      ),
    );
  }

  Widget _buildHeader(
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
              fontSize: headerFontSize,
              fontWeight: FontWeight.bold,
              color: themeProvider.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Great job! Here are your results',
            style: TextStyle(
              fontSize: textFontSize - 2,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          _buildActionButtons(isDesktop, isTablet, isMobile, isSmallMobile),
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
                  fontSize: headerFontSize,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Great job! Here are your results',
                style: TextStyle(
                  fontSize: textFontSize,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        if (!isSmallMobile)
          widget.isViewDetails
              ? SizedBox.shrink()
              : _buildActionButtons(
                isDesktop,
                isTablet,
                isMobile,
                isSmallMobile,
              ),
      ],
    );
  }

  Widget _buildStatsSection(
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
              title: 'Consistancy',
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
                  title: 'Consistancy',
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
                  title: 'Consistancy',
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

  Widget _buildDetailedStats(
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
            'Detailed Statistics',
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
              color: themeProvider.isDarkMode ? Colors.white : Colors.grey[800],
            ),
          ),
          SizedBox(height: isDesktop ? 20.0 : 16.0),

          if (isDesktop || isTablet)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Correct Characters',
                  widget.result.correctChars.toString(),
                  Colors.green,
                  themeProvider.isDarkMode,
                  isSmallMobile,
                ),
                _buildStatItem(
                  'Incorrect Characters',
                  widget.result.incorrectChars.toString(),
                  Colors.red,
                  themeProvider.isDarkMode,
                  isSmallMobile,
                ),
                _buildStatItem(
                  'Total Characters',
                  widget.result.totalChars.toString(),
                  Colors.blue,
                  themeProvider.isDarkMode,
                  isSmallMobile,
                ),
              ],
            )
          else
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      'Correct',
                      widget.result.correctChars.toString(),
                      Colors.green,
                      themeProvider.isDarkMode,
                      isSmallMobile,
                    ),
                    _buildStatItem(
                      'Incorrect',
                      widget.result.incorrectChars.toString(),
                      Colors.red,
                      themeProvider.isDarkMode,
                      isSmallMobile,
                    ),
                  ],
                ),
                SizedBox(height: 16),
                _buildStatItem(
                  'Total Characters',
                  widget.result.totalChars.toString(),
                  Colors.blue,
                  themeProvider.isDarkMode,
                  isSmallMobile,
                ),
              ],
            ),

          SizedBox(height: isDesktop ? 32.0 : 24.0),

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
                  dataSource: _chartDataPerformance,
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
                  dataSource: _chartData,
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
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    Color color,
    bool isDarkTheme,
    bool isSmallMobile,
  ) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(isSmallMobile ? 8 : 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: isSmallMobile ? 12 : 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: isSmallMobile ? 80 : 100,
          child: Text(
            label,
            style: TextStyle(
              fontSize: isSmallMobile ? 10 : 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
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
              onPressed: widget.onBackToTest,
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
            onPressed: widget.onBackToTest,
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
          onPressed: widget.onBackToTest,
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
}

class TypingStatData {
  final String label;
  final double value;

  TypingStatData(this.label, this.value);
}
