import 'dart:math';

import 'package:flutter/material.dart';

class CyclesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);
    final double radius = size.width * 0.3;

    // Draw main circle
    canvas.drawCircle(center, radius, paint);

    // Draw some decorative elements
    final double smallerRadius = radius * 0.7;
    canvas.drawCircle(center, smallerRadius, paint);

    // Draw some lines connecting the circles
    for (int i = 0; i < 8; i++) {
      final double angle = (i * pi) / 4;
      final double x1 = center.dx + radius * cos(angle);
      final double y1 = center.dy + radius * sin(angle);
      final double x2 = center.dx + smallerRadius * cos(angle);
      final double y2 = center.dy + smallerRadius * sin(angle);

      canvas.drawLine(
        Offset(x1, y1),
        Offset(x2, y2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
