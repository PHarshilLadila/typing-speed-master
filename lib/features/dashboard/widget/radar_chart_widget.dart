// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:typing_speed_master/models/typing_test_result_model.dart';

class TypingRadarChart extends StatelessWidget {
  final List<TypingTestResultModel> recentResults;
  final bool isDarkMode;
  final double? chartSize;

  const TypingRadarChart({
    super.key,
    required this.recentResults,
    required this.isDarkMode,
    this.chartSize,
  });

  @override
  Widget build(BuildContext context) {
    if (recentResults.length < 3) {
      return emptyChartWidget(context);
    }

    final displayResults = recentResults.reversed.take(3).toList();
    final datasets = createDataSets(displayResults);

    return Container(
      height: chartSize ?? 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
          width: 1,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Radar',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Compare recent test metrics',
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: RadarChart(
              RadarChartData(
                radarTouchData: RadarTouchData(
                  touchCallback: (FlTouchEvent event, response) {},
                ),
                dataSets: datasets,
                radarBackgroundColor: Colors.transparent,
                borderData: FlBorderData(show: false),
                radarBorderData: BorderSide(
                  color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                  width: 1,
                ),
                titlePositionPercentageOffset: 0.15,
                titleTextStyle: TextStyle(
                  color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                getTitle: (index, angle) {
                  final titles = ['WPM', 'Accuracy', 'Consistency'];
                  return RadarChartTitle(text: titles[index], angle: angle);
                },
                tickCount: 4,
                ticksTextStyle: TextStyle(
                  color: isDarkMode ? Colors.grey[500] : Colors.grey[400],
                  fontSize: 9,
                ),
                tickBorderData: BorderSide(
                  color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                  width: 0.5,
                ),
                gridBorderData: BorderSide(
                  color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                  width: 1,
                ),
              ),
              swapAnimationDuration: const Duration(milliseconds: 400),
            ),
          ),
          const SizedBox(height: 16),
          radarMainLegend(displayResults, isDarkMode),
        ],
      ),
    );
  }

  Widget emptyChartWidget(BuildContext context) {
    return Container(
      height: chartSize ?? 300,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.radar,
            size: 48,
            color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Insufficient Data',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete at least 3 tests to see radar chart',
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<RadarDataSet> createDataSets(List<TypingTestResultModel> results) {
    final List<Color> colors = [
      Colors.blue.withOpacity(0.7),
      Colors.green.withOpacity(0.7),
      Colors.orange.withOpacity(0.7),
      Colors.purple.withOpacity(0.7),
      Colors.red.withOpacity(0.7),
    ];

    return results.asMap().entries.map((entry) {
      final index = entry.key;
      final result = entry.value;

      final maxWpm = results.map((r) => r.wpm).reduce((a, b) => a > b ? a : b);
      final maxAccuracy = results
          .map((r) => r.accuracy)
          .reduce((a, b) => a > b ? a : b);
      final maxConsistency = results
          .map((r) => r.consistency)
          .reduce((a, b) => a > b ? a : b);

      final normalizedWpm =
          (result.wpm / maxWpm * 100).clamp(0, 100).toDouble();
      final normalizedAccuracy =
          (result.accuracy / maxAccuracy * 100).clamp(0, 100).toDouble();
      final normalizedConsistency =
          ((result.consistency) / maxConsistency * 100)
              .clamp(0, 100)
              .toDouble();

      return RadarDataSet(
        fillColor: colors[index % colors.length].withOpacity(0.1),
        borderColor: colors[index % colors.length],
        entryRadius: 4,
        dataEntries: [
          RadarEntry(value: normalizedWpm),
          RadarEntry(value: normalizedAccuracy),
          RadarEntry(value: normalizedConsistency),
        ],
        borderWidth: 2,
      );
    }).toList();
  }

  Widget radarMainLegend(List<TypingTestResultModel> results, bool isDarkMode) {
    final List<String> testLabels = ['Last Test', 'Second Last', 'Third Last'];
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children:
          results.asMap().entries.map((entry) {
            final index = entry.key;
            // final result = entry.value;

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: getColorForIndex(index),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  index < testLabels.length
                      ? testLabels[index]
                      : 'Test ${index + 1}',
                  style: TextStyle(
                    fontSize: 10,
                    color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
                  ),
                ),
              ],
            );
          }).toList(),
    );
  }

  Color getColorForIndex(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
    ];
    return colors[index % colors.length];
  }
}
