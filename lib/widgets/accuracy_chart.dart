// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../models/typing_result.dart';

class AccuracyChart extends StatelessWidget {
  final List<TypingResult> results;

  const AccuracyChart({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    if (results.length < 2) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Center(
          child: Text(
            'Complete more tests to see your progress chart',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Accuracy Trend',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              primaryXAxis: NumericAxis(
                edgeLabelPlacement: EdgeLabelPlacement.shift,
                labelStyle: const TextStyle(fontSize: 10),
                title: AxisTitle(text: 'Tests'),
              ),
              primaryYAxis: NumericAxis(
                minimum: minAccuracy - 5,
                maximum: maxAccuracy + 5,
                labelFormat: '{value}%',
                labelStyle: const TextStyle(fontSize: 10),
              ),
              tooltipBehavior: TooltipBehavior(enable: true),
              series: <CartesianSeries<TypingResult, int>>[
                AreaSeries<TypingResult, int>(
                  dataSource: recentResults,
                  xValueMapper: (TypingResult result, int index) => index,
                  yValueMapper: (TypingResult result, _) => result.accuracy,
                  color: Colors.blue.withOpacity(0.2),
                  borderColor: Colors.blue,
                  borderWidth: 2,
                  markerSettings: const MarkerSettings(
                    isVisible: true,
                    shape: DataMarkerType.circle,
                    width: 6,
                    height: 6,
                    borderWidth: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildLegend(recentResults),
        ],
      ),
    );
  }

  Widget _buildLegend(List<TypingResult> recentResults) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildLegendItem(
          'First: ${recentResults.first.accuracy.toStringAsFixed(1)}%',
          Colors.blue,
        ),
        _buildLegendItem(
          'Last: ${recentResults.last.accuracy.toStringAsFixed(1)}%',
          Colors.green,
        ),
        _buildLegendItem(
          'Avg: ${(recentResults.map((r) => r.accuracy).reduce((a, b) => a + b) / recentResults.length).toStringAsFixed(1)}%',
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildLegendItem(String text, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}
