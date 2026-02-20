// ignore_for_file: deprecated_member_use

import 'dart:developer';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:typing_speed_master/models/typing_test_result_model.dart';

class SpeedAccuracyTrendChart extends StatelessWidget {
  final List<TypingTestResultModel> results;
  final bool isDarkMode;

  const SpeedAccuracyTrendChart({
    super.key,
    required this.results,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) return const SizedBox();
    final displayResultData =
        results.length > 8 ? results.sublist(results.length - 8) : results;

    final displayResults = displayResultData.reversed.toList();

    log(
      "displayResults => ${displayResults.map((e) => e.toJson()).toList().toString()}",
    );

    final wpmValues = displayResults.map((r) => r.wpm.toDouble()).toList();
    final accuracyValues = displayResults.map((r) => r.accuracy).toList();

    final allValues = [...wpmValues, ...accuracyValues];
    final minValue = allValues.reduce((a, b) => a < b ? a : b);
    final maxValue = allValues.reduce((a, b) => a > b ? a : b);

    final minY = (minValue * 0.8).floorToDouble();
    final maxY = (maxValue * 1.2).ceilToDouble();

    log("Y-axis range: $minY to $maxY");

    return Container(
      height: 350,
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
            'Speed & Accuracy Trend',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.grey[800],
            ),
          ),
          const SizedBox(height: 40),
          Expanded(
            child: LineChart(
              LineChartData(
                minY: minY,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  drawHorizontalLine: true,
                  getDrawingHorizontalLine:
                      (value) => FlLine(
                        color:
                            isDarkMode ? Colors.grey[800]! : Colors.grey[100]!,
                        strokeWidth: 1,
                      ),
                  getDrawingVerticalLine:
                      (value) => FlLine(
                        color:
                            isDarkMode ? Colors.grey[800]! : Colors.grey[100]!,
                        strokeWidth: 1,
                      ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index >= 0 && index < displayResults.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              DateFormat(
                                'MMM d',
                              ).format(displayResults[index].timestamp),
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 10,
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: calculateInterval(maxY - minY),
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
                    width: 1,
                  ),
                ),
                lineBarsData: [
                  lineData(
                    displayResults,
                    (r) => r.accuracy,
                    Colors.green,
                    "Accuracy",
                  ),
                  lineData(
                    displayResults,
                    (r) => r.wpm.toDouble(),
                    Colors.blue,
                    "WPM",
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (List<LineBarSpot> touchedSpots) {
                      return touchedSpots
                          .map((spot) {
                            final index = spot.x.toInt();
                            if (index >= 0 && index < displayResults.length) {
                              final result = displayResults[index];
                              return LineTooltipItem(
                                spot.barIndex == 0
                                    ? 'Accuracy: ${result.accuracy.toStringAsFixed(1)}%'
                                    : 'WPM: ${result.wpm}',
                                TextStyle(
                                  color:
                                      spot.barIndex == 0
                                          ? Colors.green
                                          : Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }
                            return null;
                          })
                          .where((item) => item != null)
                          .cast<LineTooltipItem>()
                          .toList();
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          lineChartMainLegend(),
        ],
      ),
    );
  }

  double calculateInterval(double range) {
    if (range <= 20) return 5;
    if (range <= 50) return 10;
    if (range <= 100) return 20;
    return 25;
  }

  LineChartBarData lineData(
    List<TypingTestResultModel> data,
    double Function(TypingTestResultModel) getY,
    Color color,
    String label,
  ) {
    final spots =
        data
            .asMap()
            .entries
            .map((e) => FlSpot(e.key.toDouble(), getY(e.value)))
            .toList();

    log("$label spots: $spots");

    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 4,
            color: color,
            strokeWidth: 2,
            strokeColor: isDarkMode ? Colors.black : Colors.white,
          );
        },
      ),
      belowBarData: BarAreaData(
        show: true,
        color: color.withOpacity(0.15),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withOpacity(0.3), color.withOpacity(0.05)],
        ),
      ),
    );
  }

  Widget lineChartMainLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        legendItem(Colors.green, "Accuracy (%)"),
        const SizedBox(width: 20),
        legendItem(Colors.blue, "Speed (WPM)"),
      ],
    );
  }

  Widget legendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
