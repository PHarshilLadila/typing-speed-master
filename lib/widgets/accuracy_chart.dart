// import 'package:flutter/material.dart';
// import '../models/typing_result.dart';

// class AccuracyChart extends StatelessWidget {
//   final List<TypingResult> results;

//   const AccuracyChart({Key? key, required this.results}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     if (results.length < 2) {
//       return Container(
//         padding: const EdgeInsets.all(40),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: Colors.grey[200]!),
//         ),
//         child: Center(
//           child: Text(
//             'Complete more tests to see your progress chart',
//             style: TextStyle(fontSize: 16, color: Colors.grey[500]),
//             textAlign: TextAlign.center,
//           ),
//         ),
//       );
//     }

//     final recentResults = results.reversed.toList();
//     final maxAccuracy = recentResults
//         .map((r) => r.accuracy)
//         .reduce((a, b) => a > b ? a : b);
//     final minAccuracy = recentResults
//         .map((r) => r.accuracy)
//         .reduce((a, b) => a < b ? a : b);

//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey[200]!),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Accuracy Trend',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.grey[800],
//             ),
//           ),
//           const SizedBox(height: 16),
//           SizedBox(
//             height: 200,
//             child: CustomPaint(
//               size: const Size(double.infinity, 200),
//               painter: _AccuracyChartPainter(
//                 results: recentResults,
//                 maxAccuracy: maxAccuracy,
//                 minAccuracy: minAccuracy,
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//           _buildLegend(recentResults),
//         ],
//       ),
//     );
//   }

//   Widget _buildLegend(List<TypingResult> recentResults) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceAround,
//       children: [
//         _buildLegendItem(
//           'First: ${recentResults.first.accuracy.toStringAsFixed(1)}%',
//           Colors.blue,
//         ),
//         _buildLegendItem(
//           'Last: ${recentResults.last.accuracy.toStringAsFixed(1)}%',
//           Colors.green,
//         ),
//         _buildLegendItem(
//           'Avg: ${(recentResults.map((r) => r.accuracy).reduce((a, b) => a + b) / recentResults.length).toStringAsFixed(1)}%',
//           Colors.orange,
//         ),
//       ],
//     );
//   }

//   Widget _buildLegendItem(String text, Color color) {
//     return Row(
//       children: [
//         Container(
//           width: 12,
//           height: 12,
//           decoration: BoxDecoration(color: color, shape: BoxShape.circle),
//         ),
//         const SizedBox(width: 4),
//         Text(text, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
//       ],
//     );
//   }
// }

// class _AccuracyChartPainter extends CustomPainter {
//   final List<TypingResult> results;
//   final double maxAccuracy;
//   final double minAccuracy;

//   _AccuracyChartPainter({
//     required this.results,
//     required this.maxAccuracy,
//     required this.minAccuracy,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint =
//         Paint()
//           ..color = Colors.blue
//           ..strokeWidth = 3
//           ..style = PaintingStyle.stroke;

//     final fillPaint =
//         Paint()
//           ..color = Colors.blue.withOpacity(0.1)
//           ..style = PaintingStyle.fill;

//     final dotPaint =
//         Paint()
//           ..color = Colors.blue
//           ..style = PaintingStyle.fill;

//     if (results.length < 2) return;

//     final points = <Offset>[];
//     final width = size.width;
//     final height = size.height;
//     final range =
//         (maxAccuracy - minAccuracy) == 0 ? 100 : (maxAccuracy - minAccuracy);

//     for (int i = 0; i < results.length; i++) {
//       final x = (i / (results.length - 1)) * width;
//       final normalizedAccuracy = (results[i].accuracy - minAccuracy) / range;
//       final y = height - (normalizedAccuracy * height);
//       points.add(Offset(x, y));
//     }

//     // Draw filled area
//     final path = Path();
//     path.moveTo(0, height);
//     for (final point in points) {
//       path.lineTo(point.dx, point.dy);
//     }
//     path.lineTo(width, height);
//     path.close();
//     canvas.drawPath(path, fillPaint);

//     // Draw line
//     for (int i = 0; i < points.length - 1; i++) {
//       canvas.drawLine(points[i], points[i + 1], paint);
//     }

//     // Draw points
//     for (final point in points) {
//       canvas.drawCircle(point, 4, dotPaint);
//     }

//     // Draw labels
//     final textPainter = TextPainter(textDirection: TextDirection.ltr);

//     // Y-axis labels
//     final yLabels = [maxAccuracy, (maxAccuracy + minAccuracy) / 2, minAccuracy];
//     for (final label in yLabels) {
//       textPainter.text = TextSpan(
//         text: '${label.toStringAsFixed(0)}%',
//         style: const TextStyle(color: Colors.grey, fontSize: 10),
//       );
//       textPainter.layout();
//       final y = height - ((label - minAccuracy) / range * height);
//       textPainter.paint(canvas, Offset(0, y - 8));
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../models/typing_result.dart';

class AccuracyChart extends StatelessWidget {
  final List<TypingResult> results;

  const AccuracyChart({Key? key, required this.results}) : super(key: key);

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
