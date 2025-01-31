import 'dart:async';

import 'package:chrono_quest/agenda/components/add_task_dialog.dart';
import 'package:chrono_quest/agenda/controllers/timeline_cubit.dart';
import 'package:chrono_quest/agenda/models/chrono_bar_state.dart';
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
  late final AnimationController _shadowAnimationController;
  late final AnimationController _shadowPulseAnimationController;

  late final Animation<double> _animation;

  late Animation<double> _shadowAnimation;
  late Animation<double> _shadowPulseAnimation;

  double horizontalDelta = 0;

  double shadowPulseDelta = 0;

  double previousHapticAt = 0;

  final double chronoBarLineHeight = 36;
  final double chronoBarCircleHeight = 72;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _shadowAnimationController = AnimationController(
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
    super.dispose();
  }

  void toggleAnimation() {
    if (_animationController.isCompleted) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
  }

  void _shadowAnimationListener() {
    setState(() {
      horizontalDelta = _shadowAnimation.value;
    });
  }

  void _startShadowAnimation() {
    _shadowAnimationController
      ..removeListener(_shadowAnimationListener)
      ..value = 0;

    _shadowAnimation = Tween<double>(begin: horizontalDelta, end: 0).animate(
      CurvedAnimation(
        parent: _shadowAnimationController,
        curve: Curves.linear,
      ),
    );

    _shadowAnimationController
      ..removeListener(_shadowAnimationListener)
      ..addListener(_shadowAnimationListener)
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
                              blurRadius: (20 + horizontalDelta.abs()).abs(),
                            ),
                            BoxShadow(
                              color: Colors.pinkAccent,
                              spreadRadius: -10.0 +
                                  (-1 * (horizontalDelta ~/ 5)) +
                                  shadowPulseDelta * 7,
                              blurRadius: (20 + horizontalDelta.abs()).abs() +
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
                        onScaleUpdate: (details) {
                          if (chronoBarState == ChronoBarState.circle) {
                            return;
                          }

                          context
                              .read<TimelineCubit>()
                              .zoomTimeline(details.scale);
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

                            await showDialog(
                              context: context,
                              builder: (context) => const AddTaskDialog(),
                            );
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
                          _startShadowAnimation();
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

                          if ((previousHapticAt - horizontalDelta).abs() > 2) {
                            unawaited(HapticFeedback.lightImpact());
                            previousHapticAt = horizontalDelta;
                          }
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
                                    0,
                                  ),
                                ),
                                BoxShadow(
                                  color: kWhite.withValues(alpha: 0.2),
                                  spreadRadius: -20,
                                  blurRadius: 1,
                                  offset: Offset(
                                    horizontalDelta.clamp(-20, 20),
                                    0,
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
