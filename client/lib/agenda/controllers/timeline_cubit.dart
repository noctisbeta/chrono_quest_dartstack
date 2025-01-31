import 'package:chrono_quest/agenda/models/timeline_state.dart';
import 'package:flutter/animation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TimelineCubit extends Cubit<TimelineState> {
  TimelineCubit({required TickerProvider vsync})
      : _resetTimeAnimationController = AnimationController(
          vsync: vsync,
          duration: const Duration(milliseconds: 800),
        ),
        super(const TimelineState.initial()) {
    // _resetTimeAnimationController.addListener(_resetTimeAnimationListener);
  }

  DateTime get currentTime => DateTime.now();

  final AnimationController _resetTimeAnimationController;
  late Animation<double> _resetTimeAnimation;

  void zoomTimeline(
    double newZoomFactor,
  ) {
    emit(
      TimelineState(
        scrollOffset: state.scrollOffset,
        zoomFactor: newZoomFactor,
      ),
    );
  }

  void scrollTimeline(double delta) {
    emit(
      TimelineState(
        scrollOffset: state.scrollOffset + delta,
        zoomFactor: state.zoomFactor,
      ),
    );
  }

  void _resetTimeAnimationListener() {
    emit(
      TimelineState(
        scrollOffset: _resetTimeAnimation.value,
        zoomFactor: state.zoomFactor,
      ),
    );
  }

  void resetTimeline() {
    _resetTimeAnimationController
      ..removeListener(_resetTimeAnimationListener)
      ..value = 0;

    _resetTimeAnimation =
        Tween<double>(begin: state.scrollOffset, end: 0).animate(
      CurvedAnimation(
        parent: _resetTimeAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _resetTimeAnimationController
      ..removeListener(_resetTimeAnimationListener)
      ..addListener(_resetTimeAnimationListener)
      ..forward();
  }

  @override
  Future<void> close() {
    _resetTimeAnimationController.dispose();
    return super.close();
  }
}
