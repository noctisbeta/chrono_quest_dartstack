import 'dart:math';

import 'package:common/agenda/cycle.dart';
import 'package:flutter/material.dart';

class CyclesPainter extends CustomPainter {
  const CyclesPainter({required this.cycles});

  final List<Cycle> cycles;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blueGrey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final center = Offset(size.width / 2, size.height / 2);
    final double outerRadius = size.width * 0.3;
    final double innerRadius = outerRadius * 0.7;

    // Draw main circles
    canvas
      ..drawCircle(center, outerRadius, paint)
      ..drawCircle(center, innerRadius, paint);

    // Get unique periods
    final List<int> uniquePeriods =
        cycles.map((c) => c.period).toSet().toList();
    final int numberOfSections = uniquePeriods.length;

    // Draw sections
    if (numberOfSections > 0) {
      final double sectionAngle = 2 * pi / numberOfSections;

      for (int i = 0; i < numberOfSections; i++) {
        final double startAngle =
            -pi / 2 + (i * sectionAngle); // Start from top (-pi/2)

        final path = Path()
          ..moveTo(
            center.dx + innerRadius * cos(startAngle),
            center.dy + innerRadius * sin(startAngle),
          )
          ..lineTo(
            center.dx + outerRadius * cos(startAngle),
            center.dy + outerRadius * sin(startAngle),
          )
          ..arcTo(
            Rect.fromCircle(center: center, radius: outerRadius),
            startAngle,
            sectionAngle,
            false,
          )
          ..lineTo(
            center.dx + innerRadius * cos(startAngle + sectionAngle),
            center.dy + innerRadius * sin(startAngle + sectionAngle),
          )
          ..arcTo(
            Rect.fromCircle(center: center, radius: innerRadius),
            startAngle + sectionAngle,
            -sectionAngle,
            false,
          );

        canvas.drawPath(path, paint);

        // Find cycles with current period
        final int currentPeriod = uniquePeriods[i];
        final List<Cycle> cyclesInSection = cycles
            .where(
              (cycle) => currentPeriod % cycle.period == 0,
            )
            .toList();

        // Draw period number
        final textSpan = TextSpan(
          text: currentPeriod.toString(),
          style: const TextStyle(
            color: Colors.blue,
            fontSize: 12,
          ),
        );
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        )..layout();

        textPainter.paint(
          canvas,
          Offset(
            center.dx +
                (outerRadius + 10) * cos(startAngle) -
                textPainter.width / 2,
            center.dy +
                (outerRadius + 10) * sin(startAngle) -
                textPainter.height / 2,
          ),
        );

        // Draw arcs for each cycle in this section
        for (final cycle in cyclesInSection) {
          final int startMinutes =
              cycle.startTime.hour * 60 + cycle.startTime.minute;
          final int endMinutes = cycle.endTime.hour * 60 + cycle.endTime.minute;

          final double startAngleNormalized =
              startAngle + (startMinutes / 1440) * sectionAngle;
          final double endAngleNormalized =
              startAngle + (endMinutes / 1440) * sectionAngle;

          final arcPath = Path()
            ..moveTo(
              center.dx + innerRadius * cos(startAngleNormalized),
              center.dy + innerRadius * sin(startAngleNormalized),
            )
            ..lineTo(
              center.dx + outerRadius * cos(startAngleNormalized),
              center.dy + outerRadius * sin(startAngleNormalized),
            )
            ..arcTo(
              Rect.fromCircle(center: center, radius: outerRadius),
              startAngleNormalized,
              endAngleNormalized - startAngleNormalized,
              false,
            )
            ..lineTo(
              center.dx + innerRadius * cos(endAngleNormalized),
              center.dy + innerRadius * sin(endAngleNormalized),
            )
            ..arcTo(
              Rect.fromCircle(center: center, radius: innerRadius),
              endAngleNormalized,
              startAngleNormalized - endAngleNormalized,
              false,
            );

          final fillPaint = Paint()
            ..color = Colors.blue.withValues(alpha: 0.3)
            ..style = PaintingStyle.fill;

          final outlinePaint = Paint()
            ..color = Colors.blue
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.5;

          canvas
            ..drawPath(arcPath, fillPaint)
            ..drawPath(arcPath, outlinePaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
