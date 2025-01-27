import 'package:equatable/equatable.dart';
import 'package:flutter/animation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ScrollCubit extends Cubit<ScrollState> {
  ScrollCubit({required TickerProvider vsync})
      : _animationController = AnimationController(
          vsync: vsync,
          duration: const Duration(milliseconds: 400),
        ),
        super(const ScrollState(offset: 0)) {
    _animationController.addListener(_animationListener);
  }

  final AnimationController _animationController;
  late Animation<double> _animation;

  void updateOffset(double delta) {
    emit(ScrollState(offset: state.offset + delta));
  }

  void _animationListener() {
    emit(ScrollState(offset: _animation.value));
  }

  void startAnimation() {
    _animationController
      ..removeListener(_animationListener)
      ..value = 0;

    _animation = Tween<double>(begin: state.offset, end: 0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _animationController
      ..removeListener(_animationListener)
      ..addListener(_animationListener)
      ..forward();
  }

  void resetOffset() {
    startAnimation();
  }

  @override
  Future<void> close() {
    _animationController.dispose();
    return super.close();
  }
}

final class ScrollState extends Equatable {
  const ScrollState({
    required this.offset,
  });

  final double offset;

  @override
  List<Object> get props => [offset];
}
