import 'package:flutter/material.dart';

class AgendaPainter extends CustomPainter {
  const AgendaPainter({
    required this.offset,
    required this.currentTime,
    required this.zoomFactor,
  });

  final double offset;
  final DateTime currentTime;

  final double zoomFactor;

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

    final int timeStart = currentTime.hour;

    final double centerX = size.width / 2 - offset;

    final indicatorPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0;

    final double indicatorX = centerX + offset;
    final double indicatorY = size.height * 0.81;

    final Path indicatorPath = Path()
      ..moveTo(indicatorX, indicatorY)
      ..lineTo(indicatorX - 5, indicatorY + 10)
      ..lineTo(indicatorX + 5, indicatorY + 10)
      ..close();

    canvas.drawPath(indicatorPath, indicatorPaint);

    int i = 0;
    for (int h = timeStart; h >= 0; h -= 1) {
      final double x = centerX +
          offset -
          currentTime.minute * (zoomFactor * 80) / 60 +
          i * (zoomFactor * 80);
      final int hour = h;
      final span =
          TextSpan(style: textStyle, text: hour.toString().padLeft(2, '0'));
      final tp = TextPainter(
        text: span,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(x + offset - tp.width / 2, size.height * 0.3 - tp.height),
      );

      canvas.drawLine(
        Offset(x + offset, size.height * 0.3),
        Offset(x + offset, size.height * 0.8),
        linePaint,
      );

      i -= 1;
    }

    int j = 1;
    for (int h = timeStart + 1; h < 24; h += 1) {
      final double x = centerX +
          offset -
          currentTime.minute * (zoomFactor * 80) / 60 +
          j * (zoomFactor * 80);
      final int hour = h;
      final span =
          TextSpan(style: textStyle, text: hour.toString().padLeft(2, '0'));
      final tp = TextPainter(
        text: span,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(x + offset - tp.width / 2, size.height * 0.3 - tp.height),
      );

      canvas.drawLine(
        Offset(x + offset, size.height * 0.3),
        Offset(x + offset, size.height * 0.8),
        linePaint,
      );

      j += 1;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
