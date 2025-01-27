import 'package:flutter/material.dart';

class AgendaPainter extends CustomPainter {
  const AgendaPainter({
    required this.offset,
    required this.currentTime,
  });

  final double offset;
  final DateTime currentTime;

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
    final double indicatorY = size.height * 0.6;

    final Path indicatorPath = Path()
      ..moveTo(indicatorX, indicatorY)
      ..lineTo(indicatorX - 5, indicatorY + 10)
      ..lineTo(indicatorX + 5, indicatorY + 10)
      ..close();

    canvas.drawPath(indicatorPath, indicatorPaint);

    int i = 0;
    for (int h = timeStart; h >= 0; h -= 1) {
      final double x = centerX + offset - currentTime.minute * 20 / 60 + i * 20;
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
        Offset(x + offset - tp.width / 2, size.height * 0.48 - tp.height),
      );

      canvas.drawLine(
        Offset(x + offset, size.height * 0.5),
        Offset(x + offset, size.height * 0.6),
        linePaint,
      );

      i -= 1;
    }

    int j = 0;
    for (int h = timeStart; h < 24; h += 1) {
      final double x = centerX + offset - currentTime.minute * 20 / 60 + j * 20;
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
        Offset(x + offset - tp.width / 2, size.height * 0.48 - tp.height),
      );

      canvas.drawLine(
        Offset(x + offset, size.height * 0.5),
        Offset(x + offset, size.height * 0.6),
        linePaint,
      );

      j += 1;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
