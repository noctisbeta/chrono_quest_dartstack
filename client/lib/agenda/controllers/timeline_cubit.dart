import 'package:chrono_quest/agenda/models/timeline_state.dart';
import 'package:flutter/animation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TimelineCubit extends Cubit<TimelineState> {
  TimelineCubit({required TickerProvider vsync})
      : _resetScrollAnimationController = AnimationController(
          vsync: vsync,
          duration: const Duration(milliseconds: 800),
        ),
        _resetZoomAnimationController = AnimationController(
          vsync: vsync,
          duration: const Duration(milliseconds: 800),
        ),
        super(const TimelineState.initial());

  DateTime get currentTime => DateTime.now();

  final AnimationController _resetScrollAnimationController;
  late Animation<double> _resetScrollAnimation;

  final AnimationController _resetZoomAnimationController;
  late Animation<double> _resetZoomAnimation;

  void zoomTimeline(
    double scale,
  ) {
    final double newZoomFactor =
        (state.zoomFactor * scale.clamp(0.98, 1.02)).clamp(0.3, 4);

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
        scrollOffset: state.scrollOffset + delta / state.zoomFactor,
        zoomFactor: state.zoomFactor,
      ),
    );
  }

  void _resetScrollAnimationListener() {
    emit(
      TimelineState(
        scrollOffset: _resetScrollAnimation.value,
        zoomFactor: state.zoomFactor,
      ),
    );
  }

  void _resetZoomAnimationListener() {
    emit(
      TimelineState(
        scrollOffset: state.scrollOffset,
        zoomFactor: _resetZoomAnimation.value,
      ),
    );
  }

  void resetTimeline() {
    _resetScroll();
    _resetZoom();
  }

  void _resetZoom() {
    _resetZoomAnimationController
      ..removeListener(_resetZoomAnimationListener)
      ..value = 0;

    _resetZoomAnimation =
        Tween<double>(begin: state.zoomFactor, end: 1).animate(
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
