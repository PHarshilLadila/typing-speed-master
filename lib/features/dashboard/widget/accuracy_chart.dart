// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:typing_speed_master/theme/provider/theme_provider.dart';
import '../../../models/typing_test_result_model.dart';

class AccuracyChart extends StatelessWidget {
  final List<TypingTestResultModel> results;
  final bool isDarkMode;

  const AccuracyChart({
    super.key,
    required this.results,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isDarkMode ? Colors.grey.shade900 : Colors.white;
    final borderColor = isDarkMode ? Colors.grey[700]! : Colors.grey[200]!;
    final titleColor = isDarkMode ? Colors.white : Colors.grey[800];
    final textColor = isDarkMode ? Colors.grey[300] : Colors.grey[600];
    final chartTextColor = isDarkMode ? Colors.grey[400] : Colors.grey[600];
    final gridLineColor = isDarkMode ? Colors.grey[700]! : Colors.grey[300]!;
    final themeProvider = Provider.of<ThemeProvider>(context);

    if (results.length < 2) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Center(
          child: Text(
            'Complete more tests to see your progress chart',
            style: TextStyle(fontSize: 16, color: textColor),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final recentResults = results.reversed.toList();
    final maxAccuracy = recentResults
        .map((r) => r.accuracy)
        .reduce((a, b) => a > b ? a : b);
    final minAccuracy = recentResults
        .map((r) => r.accuracy)
        .reduce((a, b) => a < b ? a : b);

    final List<FlSpot> spots = [];
    for (int i = 0; i < recentResults.length; i++) {
      spots.add(FlSpot(i.toDouble(), recentResults[i].accuracy.toDouble()));
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Accuracy Trend',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  drawHorizontalLine: true,
                  horizontalInterval: (maxAccuracy - minAccuracy + 10) / 4,
                  verticalInterval:
                      recentResults.length > 5
                          ? (recentResults.length / 5).ceilToDouble()
                          : 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: gridLineColor.withOpacity(0.5),
                      strokeWidth: 1,
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: gridLineColor.withOpacity(0.3),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval:
                          recentResults.length > 5
                              ? (recentResults.length / 5).ceilToDouble()
                              : 1,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            '${value.toInt()}',
                            style: TextStyle(
                              fontSize: 10,
                              color: chartTextColor,
                            ),
                          ),
                        );
                      },
                    ),
                    axisNameWidget: Text(
                      'Tests',
                      style: TextStyle(fontSize: 12, color: chartTextColor),
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: (maxAccuracy - minAccuracy + 10) / 4,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}%',
                          style: TextStyle(fontSize: 10, color: chartTextColor),
                        );
                      },
                    ),
                    axisNameWidget: Text(
                      'Accuracy',
                      style: TextStyle(fontSize: 12, color: chartTextColor),
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: gridLineColor, width: 1),
                ),
                minX: 0,
                maxX: recentResults.length > 1 ? recentResults.length - 1 : 1,
                minY: minAccuracy - 5,
                maxY: maxAccuracy + 5,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: false,
                    color: themeProvider.primaryColor,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 3,
                          color: themeProvider.primaryColor,
                          strokeWidth: 1.5,
                          strokeColor:
                              isDarkMode
                                  ? Colors.white
                                  : themeProvider.primaryColor,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: themeProvider.primaryColor.withOpacity(
                        isDarkMode ? 0.3 : 0.2,
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((touchedSpot) {
                        return LineTooltipItem(
                          '${touchedSpot.y.toStringAsFixed(1)}%',
                          TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                  handleBuiltInTouches: true,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildLegend(recentResults, textColor ?? Colors.grey[600]!),
        ],
      ),
    );
  }

  Widget _buildLegend(
    List<TypingTestResultModel> recentResults,
    Color textColor,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildLegendItem(
          'First: ${recentResults.first.accuracy.toStringAsFixed(1)}%',
          Colors.blue,
          textColor,
        ),
        _buildLegendItem(
          'Last: ${recentResults.last.accuracy.toStringAsFixed(1)}%',
          Colors.green,
          textColor,
        ),
        _buildLegendItem(
          'Avg: ${(recentResults.map((r) => r.accuracy).reduce((a, b) => a + b) / recentResults.length).toStringAsFixed(1)}%',
          Colors.orange,
          textColor,
        ),
      ],
    );
  }

  Widget _buildLegendItem(String text, Color color, Color textColor) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 12, color: textColor)),
      ],
    );
  }
}
