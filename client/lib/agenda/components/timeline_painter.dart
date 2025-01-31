import 'package:flutter/material.dart';

class TimelinePainter extends CustomPainter {
  const TimelinePainter({
    required this.scrollOffset,
    required this.currentTime,
    required this.zoomFactor,
  });

  final double scrollOffset;
  final DateTime currentTime;

  final double zoomFactor;

  static const double _horizontalGap = 150;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final hourPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0;

    final minutePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.0;

    const textStyle = TextStyle(
      color: Colors.black,
      fontSize: 12,
    );

    final double centerX = size.width / 2;

    final indicatorPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0;

    final double indicatorX = centerX;
    final double indicatorY = size.height * 0.81;

    final Path indicatorPath = Path()
      ..moveTo(indicatorX, indicatorY)
      ..lineTo(indicatorX - 5, indicatorY + 10)
      ..lineTo(indicatorX + 5, indicatorY + 10)
      ..close();

    canvas.drawPath(indicatorPath, indicatorPaint);

    final int hourStart = currentTime.hour;
    final int minuteStart = currentTime.minute;
    final double centerPoint = centerX + (zoomFactor - 1) * scrollOffset;

    int i = 0;
    for (int h = hourStart; h >= 0; h -= 1) {
      final double x = centerPoint -
          (minuteStart / 60) * (zoomFactor * _horizontalGap) -
          i * (zoomFactor * _horizontalGap);
      final span =
          TextSpan(style: textStyle, text: h.toString().padLeft(2, '0'));
      final tp = TextPainter(
        text: span,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(x + scrollOffset - tp.width / 2, size.height * 0.3 - tp.height),
      );

      canvas.drawLine(
        Offset(x + scrollOffset, size.height * 0.3),
        Offset(x + scrollOffset, size.height * 0.8),
        hourPaint,
      );

      // 0 - 5, 1.67-3.34

      // Draw lines for every 5 minutes between the hours
      for (int m = 5; m < 60; m += 5) {
        final double minuteX = x - (m / 60) * (zoomFactor * _horizontalGap);
        double topFactor = 0.467;
        double bottomFactor = 0.634;

        if (m == 30) {
          topFactor = 0.4;
          bottomFactor = 0.7;
        }

        canvas.drawLine(
          Offset(minuteX + scrollOffset, size.height * topFactor),
          Offset(minuteX + scrollOffset, size.height * bottomFactor),
          minutePaint,
        );
      }

      i += 1;
    }

    int j = 1;
    for (int h = hourStart + 1; h <= 23; h += 1) {
      final double x = centerPoint -
          (minuteStart / 60) * (zoomFactor * _horizontalGap) +
          j * (zoomFactor * _horizontalGap);

      final double newScrollOffset = scrollOffset + x;

      final span =
          TextSpan(style: textStyle, text: h.toString().padLeft(2, '0'));
      final tp = TextPainter(
        text: span,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(
          newScrollOffset - tp.width / 2,
          size.height * 0.3 - tp.height,
        ),
      );

      canvas.drawLine(
        Offset(newScrollOffset, size.height * 0.3),
        Offset(newScrollOffset, size.height * 0.8),
        hourPaint,
      );

      // 0 - 5, 1.67-3.34

      // Draw lines for every 5 minutes between the hours
      for (int m = 5; m < 60; m += 5) {
        final double minuteX = x - (m / 60) * (zoomFactor * _horizontalGap);
        double topFactor = 0.467;
        double bottomFactor = 0.634;

        if (m == 30) {
          topFactor = 0.4;
          bottomFactor = 0.7;
        }

        canvas.drawLine(
          Offset(minuteX + scrollOffset, size.height * topFactor),
          Offset(minuteX + scrollOffset, size.height * bottomFactor),
          minutePaint,
        );
      }

      j += 1;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
