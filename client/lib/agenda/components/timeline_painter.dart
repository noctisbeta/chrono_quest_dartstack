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

  static const double _horizontalGap = 80;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final linePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0;

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
        linePaint,
      );

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
        linePaint,
      );

      j += 1;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
