import 'package:flutter/foundation.dart';

@immutable
final class TimelineState {
  const TimelineState({
    required this.scrollOffset,
    required this.zoomFactor,
  });

  const TimelineState.initial()
      : scrollOffset = 0,
        zoomFactor = 1;

  final double scrollOffset;
  final double zoomFactor;
}
