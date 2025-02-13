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
    required this.timeBlockConfirmed,
    required this.period,
  });

  TimelineState.initial()
    : scrollOffset = 0,
      zoomFactor = 3,
      currentTime = DateTime.now(),
      timeBlockStartOffset = null,
      timeBlockDurationMinutes = null,
      timeBlockConfirmed = false,
      period = null;

  final double scrollOffset;
  final double zoomFactor;
  final DateTime currentTime;
  final double? timeBlockStartOffset;
  final double? timeBlockDurationMinutes;
  final bool timeBlockConfirmed;

  static const double maxZoomFactor = 6;
  static const double minZoomFactor = 1;

  final int? period;

  TimelineState copyWith({
    double? scrollOffset,
    double? zoomFactor,
    DateTime? currentTime,
    double? Function()? timeBlockStartOffsetFn,
    double? Function()? timeBlockDurationMinutesFn,
    bool? timeBlockConfirmed,
    int? Function()? periodFn,
  }) => TimelineState(
    scrollOffset: scrollOffset ?? this.scrollOffset,
    zoomFactor: zoomFactor ?? this.zoomFactor,
    currentTime: currentTime ?? this.currentTime,
    timeBlockStartOffset:
        timeBlockStartOffsetFn != null
            ? timeBlockStartOffsetFn()
            : timeBlockStartOffset,
    timeBlockDurationMinutes:
        timeBlockDurationMinutesFn != null
            ? timeBlockDurationMinutesFn()
            : timeBlockDurationMinutes,
    timeBlockConfirmed: timeBlockConfirmed ?? this.timeBlockConfirmed,
    period: periodFn != null ? periodFn() : period,
  );

  @override
  List<Object?> get props => [
    scrollOffset,
    zoomFactor,
    currentTime,
    timeBlockStartOffset,
    timeBlockDurationMinutes,
    timeBlockConfirmed,
    period,
  ];
}
