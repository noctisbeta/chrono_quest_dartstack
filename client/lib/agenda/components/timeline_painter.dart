import 'package:common/agenda/cycle.dart';
import 'package:flutter/material.dart';

class TimelinePainter extends CustomPainter {
  const TimelinePainter({
    required double scrollOffset,
    required DateTime currentTime,
    required double zoomFactor,
    required double? timeBlockStartOffset,
    required double? timeBlockDurationMinutes,
    required List<Cycle> cycles,
  }) : _scrollOffset = scrollOffset,
       _currentTime = currentTime,
       _zoomFactor = zoomFactor,
       _timeBlockStartOffset = timeBlockStartOffset,
       _timeBlockDurationMinutes = timeBlockDurationMinutes,
       _cycles = cycles;

  final double _scrollOffset;
  final DateTime _currentTime;

  final double _zoomFactor;

  final double? _timeBlockStartOffset;
  final double? _timeBlockDurationMinutes;

  final List<Cycle> _cycles;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final hourPaint =
        Paint()
          ..color = Colors.black
          ..strokeWidth = 2.0;

    final minutePaint =
        Paint()
          ..color = Colors.black
          ..strokeWidth = 1.0;

    const textStyle = TextStyle(color: Colors.black, fontSize: 12);

    final double centerX = size.width / 2;

    final indicatorPaint =
        Paint()
          ..color = Colors.black
          ..strokeWidth = 2.0;

    final double indicatorX = centerX;
    final double indicatorY = size.height * 0.81;

    final Path indicatorPath =
        Path()
          ..moveTo(indicatorX, indicatorY)
          ..lineTo(indicatorX - 5, indicatorY + 10)
          ..lineTo(indicatorX + 5, indicatorY + 10)
          ..close();

    canvas.drawPath(indicatorPath, indicatorPaint);

    final double centerPoint = centerX + (_zoomFactor - 1) * _scrollOffset;

    final int currentTimeInMinutes =
        _currentTime.minute + _currentTime.hour * 60;

    final double currentTimeX = currentTimeInMinutes * _zoomFactor;

    for (int x = 0; x <= 1440; x += 1) {
      final int hour = x ~/ 60;

      // 0 is left side of painter, 1 minute is 1x
      // go right for centerPoint so 00 is in the middle
      // go left for currentTimeX so current time is in the middle
      final double lineX = x * _zoomFactor + centerPoint - currentTimeX;

      if (x % 60 == 0) {
        final span = TextSpan(
          style: textStyle,
          text: hour.toString().padLeft(2, '0'),
        );
        final tp = TextPainter(
          text: span,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(
          canvas,
          Offset(
            lineX + _scrollOffset - tp.width / 2,
            size.height * 0.3 - tp.height,
          ),
        );

        canvas.drawLine(
          Offset(lineX + _scrollOffset, size.height * 0.3),
          Offset(lineX + _scrollOffset, size.height * 0.8),
          hourPaint,
        );
      } else if (x % 5 == 0) {
        double topFactor = 0.467;
        double bottomFactor = 0.634;

        if (x % 30 == 0) {
          topFactor = 0.4;
          bottomFactor = 0.7;
        }

        canvas.drawLine(
          Offset(lineX + _scrollOffset, size.height * topFactor),
          Offset(lineX + _scrollOffset, size.height * bottomFactor),
          minutePaint,
        );
      }
    }

    if (_timeBlockStartOffset != null) {
      // _timeBlockStartOffset is _currentOffset at the start, then duration
      // is added to it. So no need to subtract currentTimeX
      final double blockStartX =
          centerPoint - _timeBlockStartOffset * _zoomFactor;

      final double blockEndX =
          blockStartX + ((_timeBlockDurationMinutes ?? 0) * _zoomFactor);

      final Rect blockRect = Rect.fromLTRB(
        blockStartX + _scrollOffset,
        size.height * 0.3,
        blockEndX + _scrollOffset,
        size.height * 0.8,
      );

      final Paint blockPaint = Paint()..color = Colors.blue.withAlpha(128);

      canvas.drawRect(blockRect, blockPaint);
    }

    for (final Cycle cycle in _cycles) {
      final double cycleStartX =
          (cycle.startTime.hour * 60 + cycle.startTime.minute) * _zoomFactor +
          centerPoint -
          currentTimeX;

      final double cycleEndX =
          (cycle.endTime.hour * 60 + cycle.endTime.minute) * _zoomFactor +
          centerPoint -
          currentTimeX;

      final Rect cycleRect = Rect.fromLTRB(
        cycleStartX + _scrollOffset,
        size.height * 0.3,
        cycleEndX + _scrollOffset,
        size.height * 0.8,
      );

      final Paint cyclePaint = Paint()..color = Colors.green.withAlpha(128);
      canvas.drawRect(cycleRect, cyclePaint);

      if (centerPoint - _scrollOffset * _zoomFactor >= cycleStartX &&
          centerPoint - _scrollOffset * _zoomFactor <= cycleEndX) {
        final Paint cycleBorderPaint =
            Paint()
              ..color = Colors.red
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2;

        canvas.drawRect(cycleRect, cycleBorderPaint);
      }
    }
  }

  @override
  bool shouldRepaint(TimelinePainter oldDelegate) => true;
}
