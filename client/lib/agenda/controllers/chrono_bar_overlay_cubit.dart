import 'package:chrono_quest/agenda/models/chrono_bar_overlay_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChronoBarOverlayCubit extends Cubit<ChronoBarOverlayState> {
  ChronoBarOverlayCubit(
      //   {
      //   required TickerProvider vsync,
      // }
      )
      :
        // _animationController = AnimationController(
        //         vsync: vsync,
        //         duration: const Duration(milliseconds: 500),
        //       ),
        super(
          const ChronoBarOverlayState.initial(),
        );

  // final AnimationController _animationController;
  // late Animation<double> _animation;

  // @override
  // Future<void> close() {
  // _animationController.dispose();
  // return super.close();
  // }

  // void _animationListener() {
  //   emit(state.copyWith(bottom: _animation.value));
  // }

  // void confirmTimeBlock(double offset) {
  //   _animationController
  //     ..removeListener(_animationListener)
  //     ..reset();

  //   _animation = Tween<double>(begin: state.bottom, end: offset)
  //       .animate(_animationController)
  //     ..addListener(_animationListener);

  //   _animationController.forward();
  // }

  // void cancelTimeBlock() {
  //   _animationController
  //     ..removeListener(_animationListener)
  //     ..reset();
  //   _animation = Tween<double>(
  //     begin: state.bottom,
  //     end: ChronoBarOverlayState.initialBottom,
  //   ).animate(_animationController)
  //     ..addListener(_animationListener);
  //   _animationController.forward();
  // }

  void showOverlay(BuildContext context, OverlayEntry overlayEntry) {
    emit(
      state.copyWith(
        overlayEntryFn: () => overlayEntry,
      ),
    );
    Overlay.of(context).insert(overlayEntry);
  }

  void removeOverlay() {
    state.overlayEntry?.remove();
    emit(
      const ChronoBarOverlayState.initial(),
    );
  }
}
