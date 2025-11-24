// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:typing_speed_master/providers/theme_provider.dart';
import '../models/typing_result.dart';

class AccuracyChart extends StatelessWidget {
  final List<TypingResult> results;
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
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              enableAxisAnimation: true,
              primaryXAxis: NumericAxis(
                edgeLabelPlacement: EdgeLabelPlacement.shift,
                labelStyle: TextStyle(fontSize: 10, color: chartTextColor),
                axisLine: AxisLine(color: gridLineColor),
                majorGridLines: MajorGridLines(
                  color: gridLineColor.withOpacity(0.5),
                ),
                title: AxisTitle(
                  text: 'Tests',
                  textStyle: TextStyle(color: chartTextColor),
                ),
              ),
              primaryYAxis: NumericAxis(
                minimum: minAccuracy - 5,
                maximum: maxAccuracy + 5,
                labelFormat: '{value}%',
                labelStyle: TextStyle(fontSize: 10, color: chartTextColor),
                axisLine: AxisLine(color: gridLineColor),
                majorGridLines: MajorGridLines(
                  color: gridLineColor.withOpacity(0.5),
                ),
                title: AxisTitle(
                  text: 'Accuracy',
                  textStyle: TextStyle(color: chartTextColor),
                ),
              ),
              tooltipBehavior: TooltipBehavior(
                enable: true,
                color: isDarkMode ? Colors.grey[700] : Colors.white,
                textStyle: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              series: <CartesianSeries<TypingResult, int>>[
                AreaSeries<TypingResult, int>(
                  dataSource: recentResults,
                  enableTooltip: true,
                  enableTrackball: true,
                  isVisibleInLegend: true,
                  xValueMapper: (TypingResult result, int index) => index,
                  yValueMapper: (TypingResult result, _) => result.accuracy,
                  color: themeProvider.primaryColor.withOpacity(
                    isDarkMode ? 0.3 : 0.2,
                  ),
                  borderColor: themeProvider.primaryColor,
                  borderWidth: 2,
                  markerSettings: MarkerSettings(
                    isVisible: true,
                    shape: DataMarkerType.circle,
                    width: 6,
                    height: 6,
                    borderWidth: 1.5,
                    color: themeProvider.primaryColor,
                    borderColor:
                        isDarkMode ? Colors.white : themeProvider.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildLegend(recentResults, textColor ?? Colors.grey[600]!),
        ],
      ),
    );
  }

  Widget _buildLegend(List<TypingResult> recentResults, Color textColor) {
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
