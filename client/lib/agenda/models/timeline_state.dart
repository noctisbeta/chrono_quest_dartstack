import 'package:flutter/foundation.dart';

@immutable
final class TimelineState {
  const TimelineState({
    required this.scrollOffset,
    required this.zoomFactor,
    required this.currentTime,
    required this.timeBlockStartOffset,
    required this.timeBlockDurationMinutes,
  });

  TimelineState.initial()
      : scrollOffset = 0,
        zoomFactor = 1,
        currentTime = DateTime.now(),
        timeBlockStartOffset = null,
        timeBlockDurationMinutes = null;

  final double scrollOffset;
  final double zoomFactor;
  final DateTime currentTime;
  final double? timeBlockStartOffset;
  final double? timeBlockDurationMinutes;
}
