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
        zoomFactor = 3,
        currentTime = DateTime.now(),
        timeBlockStartOffset = null,
        timeBlockDurationMinutes = null;

  final double scrollOffset;
  final double zoomFactor;

  final DateTime currentTime;
  final double? timeBlockStartOffset;
  final double? timeBlockDurationMinutes;

  static const double maxZoomFactor = 6;
  static const double minZoomFactor = 3;

  TimelineState copyWith({
    double? scrollOffset,
    double? zoomFactor,
    DateTime? currentTime,
    double? timeBlockStartOffset,
    double? timeBlockDurationMinutes,
  }) =>
      TimelineState(
        scrollOffset: scrollOffset ?? this.scrollOffset,
        zoomFactor: zoomFactor ?? this.zoomFactor,
        currentTime: currentTime ?? this.currentTime,
        timeBlockStartOffset: timeBlockStartOffset ?? this.timeBlockStartOffset,
        timeBlockDurationMinutes:
            timeBlockDurationMinutes ?? this.timeBlockDurationMinutes,
      );
}
