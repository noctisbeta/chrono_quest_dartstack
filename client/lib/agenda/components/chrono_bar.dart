import 'dart:async';

import 'package:chrono_quest/agenda/controllers/timeline_cubit.dart';
import 'package:chrono_quest/agenda/models/chrono_bar_state.dart';
import 'package:chrono_quest/agenda/models/timeline_state.dart';
import 'package:chrono_quest/common/constants/colors.dart';
import 'package:chrono_quest/common/constants/numbers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChronoBar extends StatefulWidget {
  const ChronoBar({super.key});

  @override
  State<ChronoBar> createState() => _ChronoBarState();
}

class _ChronoBarState extends State<ChronoBar> with TickerProviderStateMixin {
  ChronoBarState chronoBarState = ChronoBarState.line;

  late final AnimationController _animationController;
  late final AnimationController _shadowHorizontalAnimationController;
  late final AnimationController _shadowVerticalAnimationController;
  late final AnimationController _shadowPulseAnimationController;

  late final Animation<double> _animation;

  late Animation<double> _shadowHorizontalAnimation;
  late Animation<double> _shadowVerticalAnimation;
  late Animation<double> _shadowPulseAnimation;

  double horizontalDelta = 0;
  double verticalDelta = 0;

  double shadowPulseDelta = 0;

  final double chronoBarLineHeight = 50;
  final double chronoBarCircleHeight = 100;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _shadowHorizontalAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _shadowVerticalAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _shadowPulseAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _shadowHorizontalAnimationController.dispose();
    _shadowVerticalAnimationController.dispose();
    _shadowPulseAnimationController.dispose();

    super.dispose();
  }

  void toggleAnimation() {
    if (_animationController.isCompleted) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
  }

  void _shadowVerticalAnimationListener() {
    setState(() {
      verticalDelta = _shadowVerticalAnimation.value;
    });
  }

  void _shadowHorizontalAnimationListener() {
    setState(() {
      horizontalDelta = _shadowHorizontalAnimation.value;
    });
  }

  void _startVerticalShadowAnimation() {
    _shadowVerticalAnimationController
      ..removeListener(_shadowVerticalAnimationListener)
      ..value = 0;

    _shadowVerticalAnimation =
        Tween<double>(begin: verticalDelta, end: 0).animate(
      CurvedAnimation(
        parent: _shadowVerticalAnimationController,
        curve: Curves.linear,
      ),
    );

    _shadowVerticalAnimationController
      ..removeListener(_shadowVerticalAnimationListener)
      ..addListener(_shadowVerticalAnimationListener)
      ..forward();
  }

  void _startHorizontalShadowAnimation() {
    _shadowHorizontalAnimationController
      ..removeListener(_shadowHorizontalAnimationListener)
      ..value = 0;

    _shadowHorizontalAnimation =
        Tween<double>(begin: horizontalDelta, end: 0).animate(
      CurvedAnimation(
        parent: _shadowHorizontalAnimationController,
        curve: Curves.linear,
      ),
    );

    _shadowHorizontalAnimationController
      ..removeListener(_shadowHorizontalAnimationListener)
      ..addListener(_shadowHorizontalAnimationListener)
      ..forward();
  }

  void _shadowPulseAnimationListener() {
    setState(() {
      shadowPulseDelta = _shadowPulseAnimation.value;
    });

    if (_shadowPulseAnimationController.isCompleted) {
      _shadowPulseAnimationController.reverse();
    }
  }

  void _startShadowPulseAnimation() {
    _shadowPulseAnimationController
      ..removeListener(_shadowPulseAnimationListener)
      ..value = 0;

    _shadowPulseAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _shadowPulseAnimationController,
        curve: Curves.easeInOutSine,
      ),
    );

    _shadowPulseAnimationController
      ..removeListener(_shadowPulseAnimationListener)
      ..addListener(_shadowPulseAnimationListener)
      ..forward();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final double widgetMaxWidth = constraints.maxWidth;
          return AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final double value = _animation.value;

              final double screenWidth = MediaQuery.of(context).size.width;

              return SizedBox(
                height: chronoBarCircleHeight,
                child: Stack(
                  children: [
                    Positioned(
                      top: chronoBarLineHeight / 2 * value,
                      left: (1 - value) *
                          (widgetMaxWidth - chronoBarCircleHeight) /
                          2,
                      right: (1 - value) *
                          (widgetMaxWidth - chronoBarCircleHeight) /
                          2,
                      child: Container(
                        width: (screenWidth - chronoBarCircleHeight) * value +
                            chronoBarCircleHeight,
                        height: -chronoBarLineHeight * value +
                            chronoBarCircleHeight,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(
                            kBorderRadius * 6,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue,
                              spreadRadius: -10 + shadowPulseDelta * 10,
                              blurRadius: (20 +
                                      horizontalDelta.abs() +
                                      verticalDelta.abs())
                                  .abs(),
                            ),
                            BoxShadow(
                              color: Colors.pinkAccent,
                              spreadRadius: -10.0 +
                                  (-1 *
                                      ((horizontalDelta + verticalDelta) ~/
                                          5)) +
                                  shadowPulseDelta * 7,
                              blurRadius: (20 +
                                          horizontalDelta.abs() +
                                          verticalDelta.abs())
                                      .abs() +
                                  shadowPulseDelta * 3,
                              // offset: Offset(
                              //   horizontalDelta.clamp(-5, 5),
                              //   horizontalDelta.clamp(-1, 1),
                              // ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: chronoBarLineHeight / 2 * value,
                      left: (1 - value) *
                          (widgetMaxWidth - chronoBarCircleHeight) /
                          2,
                      right: (1 - value) *
                          (widgetMaxWidth - chronoBarCircleHeight) /
                          2,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onVerticalDragUpdate: (details) {
                          setState(() {
                            verticalDelta += details.delta.dy / 5;
                          });

                          if (chronoBarState == ChronoBarState.circle) {
                            context.read<TimelineCubit>().addTimeBlockDuration(
                                  details.delta.dy / 4,
                                );

                            return;
                          }

                          if (context.read<TimelineCubit>().state.zoomFactor >
                                  TimelineState.maxZoomFactor ||
                              context.read<TimelineCubit>().state.zoomFactor <
                                  TimelineState.minZoomFactor) {
                            return;
                          }

                          double factor;
                          if (details.delta.dy > 0) {
                            factor = 1 + details.delta.dy / 10;
                          } else if (details.delta.dy < 0) {
                            factor = 1 + details.delta.dy / 10;
                          } else {
                            factor = 1;
                          }

                          context.read<TimelineCubit>().zoomTimeline(factor);
                        },
                        onVerticalDragEnd: (details) {
                          if (chronoBarState == ChronoBarState.circle) {
                            context.read<TimelineCubit>().snapTimeBlock();
                          }

                          _startVerticalShadowAnimation();
                        },
                        onDoubleTap: () async {
                          _startShadowPulseAnimation();

                          if (chronoBarState == ChronoBarState.line) {
                            context.read<TimelineCubit>().resetTimeline();
                            unawaited(HapticFeedback.mediumImpact());
                            return;
                          }

                          if (chronoBarState == ChronoBarState.circle) {
                            unawaited(HapticFeedback.mediumImpact());

                            context.read<TimelineCubit>().startTimeBlock();
                          }
                        },
                        onLongPress: () {
                          _startShadowPulseAnimation();

                          setState(() {
                            switch (chronoBarState) {
                              case ChronoBarState.line:
                                chronoBarState = ChronoBarState.circle;
                              case ChronoBarState.circle:
                                chronoBarState = ChronoBarState.line;
                            }
                          });

                          toggleAnimation();
                          unawaited(HapticFeedback.heavyImpact());
                        },
                        onHorizontalDragEnd: (details) {
                          if (chronoBarState == ChronoBarState.circle) {
                            return;
                          }

                          context.read<TimelineCubit>().snapToMinute();
                          _startHorizontalShadowAnimation();
                        },
                        onHorizontalDragUpdate: (details) {
                          if (chronoBarState == ChronoBarState.circle) {
                            return;
                          }

                          context.read<TimelineCubit>().scrollTimeline(
                                details.primaryDelta ?? 0,
                              );

                          setState(() {
                            horizontalDelta += details.delta.dx / 10;
                          });
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            kBorderRadius * 6,
                          ),
                          child: Container(
                            // f(0) = 72
                            // f(1) = width
                            // f(x) = (width - 72) * x + 72
                            // f(x) = kx + n
                            // 72 = n
                            // width = k + n
                            // 72 - width = -k
                            // k = width - 72
                            width:
                                (screenWidth - chronoBarCircleHeight) * value +
                                    chronoBarCircleHeight,
                            //f(0) = 72
                            //f(1) = 36
                            //f(x) = kx + n
                            // 72 = n
                            // 36 = k + n
                            // 36 = -k
                            // k = -36
                            // f(x) = -36x + 72
                            height: -chronoBarLineHeight * value +
                                chronoBarCircleHeight,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: kBlack,
                              ),
                              borderRadius: BorderRadius.circular(
                                kBorderRadius * 6,
                              ),
                              boxShadow: [
                                const BoxShadow(
                                  color: kTernaryColor,
                                ),
                                BoxShadow(
                                  color: kWhite,
                                  spreadRadius: -20,
                                  blurRadius: 10,
                                  offset: Offset(
                                    horizontalDelta.clamp(-20, 20),
                                    verticalDelta.clamp(-20, 20),
                                  ),
                                ),
                                BoxShadow(
                                  color: kWhite.withValues(alpha: 0.2),
                                  spreadRadius: -20,
                                  blurRadius: 1,
                                  offset: Offset(
                                    horizontalDelta.clamp(-20, 20),
                                    verticalDelta.clamp(-20, 20),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
}
