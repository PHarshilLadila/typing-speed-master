// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class GridBackgroundPage extends StatelessWidget {
  final Widget child;
  const GridBackgroundPage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: GridPainter(
                cellSize: 15,
                lineColor: Colors.grey.withOpacity(0.03),
                lineOpacity: 0.3,
                strokeWidth: 0.2,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  final double cellSize;
  final Color lineColor;
  final double lineOpacity;
  final double strokeWidth;

  GridPainter({
    required this.cellSize,
    required this.lineColor,
    required this.lineOpacity,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = lineColor.withOpacity(lineOpacity)
          ..strokeWidth = strokeWidth;

    // vertical lines
    for (double x = 0; x <= size.width; x += cellSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // horizontal lines
    for (double y = 0; y <= size.height; y += cellSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
