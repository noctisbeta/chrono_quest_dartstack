import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
final class TimelineState extends Equatable {
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
    double? Function()? timeBlockStartOffsetFn,
    double? Function()? timeBlockDurationMinutesFn,
  }) =>
      TimelineState(
        scrollOffset: scrollOffset ?? this.scrollOffset,
        zoomFactor: zoomFactor ?? this.zoomFactor,
        currentTime: currentTime ?? this.currentTime,
        timeBlockStartOffset: timeBlockStartOffsetFn != null
            ? timeBlockStartOffsetFn()
            : timeBlockStartOffset,
        timeBlockDurationMinutes: timeBlockDurationMinutesFn != null
            ? timeBlockDurationMinutesFn()
            : timeBlockDurationMinutes,
      );

  @override
  List<Object?> get props => [
        scrollOffset,
        zoomFactor,
        currentTime,
        timeBlockStartOffset,
        timeBlockDurationMinutes,
      ];
}
