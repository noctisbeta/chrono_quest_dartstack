import 'dart:async';

import 'package:chrono_quest/agenda/controllers/agenda_cubit.dart';
import 'package:chrono_quest/agenda/models/timeline_state.dart';
import 'package:common/agenda/task_type.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TimelineCubit extends Cubit<TimelineState> {
  TimelineCubit({
    required AgendaCubit agendaBloc,
  })  : _agendaCubit = agendaBloc,
        super(TimelineState.initial()) {
    emit(
      state.copyWith(
        currentTime: _roundToNearestFive(DateTime.now()),
      ),
    );
  }

  final AgendaCubit _agendaCubit;

  DateTime? _lastTriggeredHaptic;

  Future<void> addTask({
    required String title,
    required String description,
    required TaskType taskType,
  }) async {
    final DateTime startTime = timeFromOffset(state.timeBlockStartOffset!);
    final DateTime endTime = timeFromOffset(
      state.timeBlockStartOffset! + state.timeBlockDurationMinutes!,
    );

    await _agendaCubit.addTask(
      title,
      description,
      taskType,
      startTime,
      endTime,
    );

    cancelTimeBlock();
  }

  int offsetFromTime(DateTime time) {
    final Duration difference = time.difference(state.currentTime);
    final int offset = -difference.inMinutes;

    return offset;
  }

  DateTime _roundToNearestFive(DateTime time) {
    final int minute = time.minute;
    final int remainder = minute % 5;
    final int offset = remainder < 3 ? -remainder : (5 - remainder);
    final DateTime roundedTime = time.add(Duration(minutes: offset));

    return roundedTime;
  }

  DateTime timeFromOffset(double offset) {
    // 00 => currentTime
    // 1 => currentTime - 1 minutes
    // n => currentTime - n minutes

    final DateTime time = state.currentTime.subtract(
      Duration(minutes: offset.toInt()),
    );

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
      state.copyWith(
        scrollOffset: newOffset.toDouble(),
      ),
    );
  }

  void snapTimeBlock() {
    final DateTime newTime = timeFromOffset(
      state.timeBlockDurationMinutes ?? 0,
    );

    final int minute = newTime.minute;
    final int remainder = minute % 5;
    final int offset = remainder < 3 ? -remainder : (5 - remainder);
    final DateTime roundedTime = newTime.add(Duration(minutes: offset));

    final int newOffset = offsetFromTime(roundedTime);

    emit(
      state.copyWith(
        timeBlockStartOffsetFn: () => state.timeBlockStartOffset,
        timeBlockDurationMinutesFn: newOffset.toDouble,
      ),
    );
  }

  void addTimeBlockDuration(double offset) {
    final double newDuration = (state.timeBlockDurationMinutes ?? 0) + offset;

    if (newDuration < 5) {
      return;
    }

    final DateTime newTime =
        timeFromOffset((state.timeBlockStartOffset ?? 0) + newDuration);

    if (newTime.minute % 5 == 0) {
      if (_lastTriggeredHaptic == null) {
        unawaited(HapticFeedback.lightImpact());
        _lastTriggeredHaptic = newTime;
      } else if (_lastTriggeredHaptic!.minute != newTime.minute) {
        _lastTriggeredHaptic = newTime;
        unawaited(HapticFeedback.lightImpact());
      }
    }

    emit(
      state.copyWith(
        timeBlockDurationMinutesFn: () => newDuration,
      ),
    );
  }

  void startTimeBlock() {
    emit(
      state.copyWith(
        timeBlockDurationMinutesFn: () => 5,
        timeBlockStartOffsetFn: () => state.scrollOffset,
      ),
    );
  }

  void cancelTimeBlock() {
    emit(
      state.copyWith(
        timeBlockDurationMinutesFn: () => null,
        timeBlockStartOffsetFn: () => null,
      ),
    );
  }

  void zoomTimeline(
    double scale,
  ) {
    final double newZoomFactor = (state.zoomFactor *
            scale.clamp(
              0.98,
              1.02,
            ))
        .clamp(
      TimelineState.minZoomFactor,
      TimelineState.maxZoomFactor,
    );

    emit(
      state.copyWith(
        zoomFactor: newZoomFactor,
      ),
    );
  }

  void scrollTimeline(double delta) {
    // dampen the scrolling speed
    final double localDelta = delta / state.zoomFactor;

    final double newScrollOffset = state.scrollOffset + localDelta;
    final DateTime newTime = timeFromOffset(newScrollOffset);

    if (newTime.minute % 5 == 0) {
      if (_lastTriggeredHaptic == null ||
          _lastTriggeredHaptic!.minute != newTime.minute) {
        unawaited(HapticFeedback.lightImpact());
        _lastTriggeredHaptic = newTime;
      }
    }

    emit(
      state.copyWith(
        scrollOffset: newScrollOffset,
      ),
    );
  }

  void resetTimeline() {
    emit(
      state.copyWith(
        currentTime: _roundToNearestFive(DateTime.now()),
      ),
    );
  }

  void setZoomFactor(double factor) {
    emit(
      state.copyWith(
        zoomFactor: factor,
      ),
    );
  }

  void setScrollOffset(double offset) {
    emit(
      state.copyWith(
        scrollOffset: offset,
      ),
    );
  }
}
