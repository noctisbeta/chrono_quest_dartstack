import 'package:chrono_quest/agenda/models/timeline_state.dart';
import 'package:flutter/animation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TimelineCubit extends Cubit<TimelineState> {
  TimelineCubit({
    required TickerProvider vsync,
  })  : _resetScrollAnimationController = AnimationController(
          vsync: vsync,
          duration: const Duration(milliseconds: 800),
        ),
        _resetZoomAnimationController = AnimationController(
          vsync: vsync,
          duration: const Duration(milliseconds: 800),
        ),
        super(TimelineState.initial());

  final AnimationController _resetScrollAnimationController;
  late Animation<double> _resetScrollAnimation;

  final AnimationController _resetZoomAnimationController;
  late Animation<double> _resetZoomAnimation;

  int offsetFromTime(DateTime time) {
    final Duration difference = time.difference(state.currentTime);
    final int offset = -difference.inMinutes;

    return offset;
  }

  DateTime timeFromOffset(double offset) {
    // 00 => currentTime
    // 1 => currentTime - 1 minutes
    // n => currentTime - n minutes

    final DateTime time =
        state.currentTime.subtract(Duration(minutes: offset.toInt()));

    return time;
  }

  void snapToMinute() {
    final DateTime newTime = timeFromOffset(state.scrollOffset);

    final int minute = newTime.minute;
    final int remainder = minute % 5;
    final int offset = remainder < 3 ? -remainder : (5 - remainder);
    final DateTime roundedTime = newTime.add(Duration(minutes: offset));

    final int newOffset = offsetFromTime(roundedTime);

    emit(
      TimelineState(
        scrollOffset: newOffset.toDouble(),
        zoomFactor: state.zoomFactor,
        currentTime: state.currentTime,
        timeBlockStartOffset: state.timeBlockStartOffset,
        timeBlockDurationMinutes: state.timeBlockDurationMinutes,
      ),
    );
  }

  void addTimeBlockDuration(double minutes) {
    final double newDuration = (state.timeBlockDurationMinutes ?? 0) + minutes;

    if (newDuration < 0) {
      return;
    }

    emit(
      TimelineState(
        scrollOffset: state.scrollOffset,
        zoomFactor: state.zoomFactor,
        currentTime: state.currentTime,
        timeBlockStartOffset: state.timeBlockStartOffset,
        timeBlockDurationMinutes: newDuration,
      ),
    );
  }

  void startTimeBlock() {
    emit(
      TimelineState(
        scrollOffset: state.scrollOffset,
        zoomFactor: state.zoomFactor,
        currentTime: state.currentTime,
        timeBlockStartOffset: state.scrollOffset,
        timeBlockDurationMinutes: state.timeBlockDurationMinutes,
      ),
    );
  }

  void zoomTimeline(
    double scale,
  ) {
    final double newZoomFactor =
        (state.zoomFactor * scale.clamp(0.98, 1.02)).clamp(0.3, 4);

    emit(
      TimelineState(
        scrollOffset: state.scrollOffset,
        zoomFactor: newZoomFactor,
        currentTime: state.currentTime,
        timeBlockStartOffset: state.timeBlockStartOffset,
        timeBlockDurationMinutes: state.timeBlockDurationMinutes,
      ),
    );
  }

  void scrollTimeline(double delta) {
    emit(
      TimelineState(
        scrollOffset: state.scrollOffset + delta / state.zoomFactor,
        zoomFactor: state.zoomFactor,
        currentTime: state.currentTime,
        timeBlockStartOffset: state.timeBlockStartOffset,
        timeBlockDurationMinutes: state.timeBlockDurationMinutes,
      ),
    );
  }

  void _resetScrollAnimationListener() {
    emit(
      TimelineState(
        scrollOffset: _resetScrollAnimation.value,
        zoomFactor: state.zoomFactor,
        currentTime: state.currentTime,
        timeBlockStartOffset: state.timeBlockStartOffset,
        timeBlockDurationMinutes: state.timeBlockDurationMinutes,
      ),
    );
  }

  void _resetZoomAnimationListener() {
    emit(
      TimelineState(
        scrollOffset: state.scrollOffset,
        zoomFactor: _resetZoomAnimation.value,
        currentTime: state.currentTime,
        timeBlockStartOffset: state.timeBlockStartOffset,
        timeBlockDurationMinutes: state.timeBlockDurationMinutes,
      ),
    );
  }

  void resetTimeline() {
    emit(
      TimelineState(
        scrollOffset: state.scrollOffset,
        zoomFactor: state.zoomFactor,
        currentTime: DateTime.now(),
        timeBlockStartOffset: state.timeBlockStartOffset,
        timeBlockDurationMinutes: state.timeBlockDurationMinutes,
      ),
    );
    _resetScroll();
    _resetZoom();
  }

  void _resetZoom() {
    _resetZoomAnimationController
      ..removeListener(_resetZoomAnimationListener)
      ..value = 0;

    _resetZoomAnimation =
        Tween<double>(begin: state.zoomFactor, end: 2).animate(
      CurvedAnimation(
        parent: _resetZoomAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _resetZoomAnimationController
      ..removeListener(_resetZoomAnimationListener)
      ..addListener(_resetZoomAnimationListener)
      ..forward();
  }

  void _resetScroll() {
    _resetScrollAnimationController
      ..removeListener(_resetScrollAnimationListener)
      ..value = 0;

    _resetScrollAnimation =
        Tween<double>(begin: state.scrollOffset, end: 0).animate(
      CurvedAnimation(
        parent: _resetScrollAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _resetScrollAnimationController
      ..removeListener(_resetScrollAnimationListener)
      ..addListener(_resetScrollAnimationListener)
      ..forward();
  }

  @override
  Future<void> close() {
    _resetScrollAnimationController.dispose();
    return super.close();
  }
}
