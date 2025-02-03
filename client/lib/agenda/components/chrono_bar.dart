import 'dart:async';

import 'package:chrono_quest/agenda/controllers/timeline_cubit.dart';
import 'package:chrono_quest/agenda/models/chrono_bar_state.dart';
import 'package:chrono_quest/agenda/models/timeline_state.dart';
import 'package:chrono_quest/common/constants/colors.dart';
import 'package:chrono_quest/common/constants/numbers.dart';
import 'package:common/agenda/task_type.dart';
import 'package:common/logger/logger.dart';
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

  late final AnimationController _resetScrollAnimationController;
  late Animation<double> _resetScrollAnimation;

  late final AnimationController _resetZoomAnimationController;
  late Animation<double> _resetZoomAnimation;

  late final AnimationController _animationController;
  late final AnimationController _shadowHorizontalAnimationController;
  late final AnimationController _shadowVerticalAnimationController;
  late final AnimationController _shadowPulseAnimationController;
  late final AnimationController _confirmedShadowAnimationController;

  late final Animation<double> _animation;

  late Animation<double> _shadowHorizontalAnimation;
  late Animation<double> _shadowVerticalAnimation;
  late Animation<double> _shadowPulseAnimation;

  late final Animation<double> _confirmedShadowAnimation;

  double horizontalDelta = 0;
  double verticalDelta = 0;

  double dialRotation = 0;

  double shadowPulseDelta = 0;

  final double chronoBarLineHeight = 50;
  final double chronoBarCircleHeight = 100;

  bool isBlockingTime = false;
  bool isConfirmed = false;

  double _confirmedShadowSpread = 0;

  final TextEditingController textFieldController = TextEditingController();
  final textFieldFocusNode = FocusNode();

  String textFieldLabel = 'Enter task name';
  int textFieldStep = 1;
  String? taskName;
  String? taskDescription;
  TaskType? taskType;

  void _onTextFieldSubmit(String value) {
    if (textFieldStep == 2) {
      LOG.d('Task description: ${textFieldController.text}');
      setState(() {
        taskDescription = textFieldController.text;
      });
      textFieldStep = 3;
      textFieldController.clear();
    }

    if (textFieldStep == 1) {
      if (textFieldController.text.isEmpty) {
        return;
      }

      setState(() {
        taskName = textFieldController.text;
        textFieldLabel = 'Enter task description';
      });

      textFieldController.clear();
      textFieldFocusNode.requestFocus();
      textFieldStep = 2;
    }
  }

  void resetTimeline() {
    context.read<TimelineCubit>().resetTimeline();

    _resetScroll();
    _resetZoom();
  }

  void _resetZoom() {
    _resetZoomAnimationController
      ..removeListener(_resetZoomAnimationListener)
      ..value = 0;

    final double currentZoomFactor =
        context.read<TimelineCubit>().state.zoomFactor;

    _resetZoomAnimation =
        Tween<double>(begin: currentZoomFactor, end: 3).animate(
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

  void _resetZoomAnimationListener() {
    context.read<TimelineCubit>().setZoomFactor(
          _resetZoomAnimation.value,
        );
  }

  void _resetScrollAnimationListener() {
    context.read<TimelineCubit>().setScrollOffset(
          _resetScrollAnimation.value,
        );
  }

  void _resetScroll() {
    _resetScrollAnimationController
      ..removeListener(_resetScrollAnimationListener)
      ..value = 0;

    final double currentScrollOffset =
        context.read<TimelineCubit>().state.scrollOffset;

    _resetScrollAnimation =
        Tween<double>(begin: currentScrollOffset, end: 0).animate(
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
  void initState() {
    super.initState();

    _resetScrollAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _resetZoomAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

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

    _confirmedShadowAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
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

    _confirmedShadowAnimation = Tween<double>(
      begin: 0,
      end: 10,
    ).animate(
      CurvedAnimation(
        parent: _confirmedShadowAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _confirmedShadowAnimation.addListener(_confirmedShadowAnimationListener);

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _shadowHorizontalAnimationController.dispose();
    _shadowVerticalAnimationController.dispose();
    _shadowPulseAnimationController.dispose();

    _confirmedShadowAnimationController.dispose();

    textFieldController.dispose();
    textFieldFocusNode.dispose();

    super.dispose();
  }

  void _toggleAnimation() {
    if (_animationController.isCompleted ||
        _animationController.status == AnimationStatus.forward) {
      _animationController.reverse();
    } else if (_animationController.status == AnimationStatus.reverse) {
      _animationController.forward();
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

  void _confirmedShadowAnimationListener() {
    setState(() {
      _confirmedShadowSpread = _confirmedShadowAnimation.value;
    });

    if (isConfirmed) {
      if (_confirmedShadowAnimationController.isCompleted) {
        _confirmedShadowAnimationController.reverse();
      } else if (_confirmedShadowAnimationController.isDismissed) {
        _confirmedShadowAnimationController.forward();
      }
    } else {
      _confirmedShadowAnimationController.reverse();
    }
  }

  void _runConfirmedShadowAnimation() {
    if (_confirmedShadowAnimationController.isCompleted ||
        _confirmedShadowAnimationController.status == AnimationStatus.forward) {
      _confirmedShadowAnimationController.reverse();
    } else if (_confirmedShadowAnimationController.status ==
        AnimationStatus.reverse) {
      _confirmedShadowAnimationController.forward();
    } else {
      _confirmedShadowAnimationController.forward();
    }
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

              return Material(
                color: Colors.transparent,
                child: SizedBox(
                  height: chronoBarCircleHeight,
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        left: kPadding + 1,
                        child: Text(taskName ?? ''),
                      ),
                      Positioned(
                        top: 0,
                        right: kPadding + 1,
                        child: Text(taskDescription ?? ''),
                      ),
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
                                spreadRadius: _confirmedShadowSpread +
                                    -10 +
                                    shadowPulseDelta * 10,
                                blurRadius: (20 +
                                        horizontalDelta.abs() +
                                        verticalDelta.abs())
                                    .abs(),
                              ),
                              BoxShadow(
                                color: Colors.pinkAccent,
                                spreadRadius: _confirmedShadowSpread -
                                    10.0 +
                                    (-1 *
                                        ((horizontalDelta + verticalDelta) ~/
                                            5)) +
                                    shadowPulseDelta * 7,
                                blurRadius: (20 +
                                            horizontalDelta.abs() +
                                            verticalDelta.abs())
                                        .abs() +
                                    shadowPulseDelta * 3,
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
                        child: isConfirmed
                            ? _buildGestureDetectorChildren(
                                screenWidth,
                                value,
                                widgetMaxWidth,
                                context,
                              )
                            : GestureDetector(
                                behavior: HitTestBehavior.deferToChild,
                                onVerticalDragUpdate: (details) {
                                  if (isConfirmed) {
                                    return;
                                  }

                                  setState(() {
                                    verticalDelta += details.delta.dy / 5;
                                    dialRotation += details.delta.dy / 5;
                                  });

                                  if (chronoBarState == ChronoBarState.circle) {
                                    context
                                        .read<TimelineCubit>()
                                        .addTimeBlockDuration(
                                          details.delta.dy / 4,
                                        );

                                    return;
                                  }

                                  if (context
                                              .read<TimelineCubit>()
                                              .state
                                              .zoomFactor >
                                          TimelineState.maxZoomFactor ||
                                      context
                                              .read<TimelineCubit>()
                                              .state
                                              .zoomFactor <
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

                                  context
                                      .read<TimelineCubit>()
                                      .zoomTimeline(factor);
                                },
                                onVerticalDragEnd: (details) {
                                  if (isConfirmed) {
                                    return;
                                  }

                                  if (chronoBarState == ChronoBarState.circle) {
                                    context
                                        .read<TimelineCubit>()
                                        .snapTimeBlock();
                                  }

                                  _startVerticalShadowAnimation();
                                },
                                onDoubleTap: () async {
                                  if (isConfirmed) {
                                    return;
                                  }

                                  _startShadowPulseAnimation();

                                  if (chronoBarState == ChronoBarState.line) {
                                    resetTimeline();
                                    unawaited(HapticFeedback.mediumImpact());
                                    return;
                                  }

                                  if (chronoBarState == ChronoBarState.circle) {
                                    unawaited(HapticFeedback.mediumImpact());
                                    if (isBlockingTime) {
                                      setState(() {
                                        isConfirmed = true;
                                        chronoBarState = ChronoBarState.line;
                                      });
                                      _runConfirmedShadowAnimation();
                                      _toggleAnimation();
                                      _startShadowPulseAnimation();
                                      textFieldFocusNode.requestFocus();
                                    } else {
                                      context
                                          .read<TimelineCubit>()
                                          .startTimeBlock();
                                      isBlockingTime = true;
                                    }
                                  }
                                },
                                onLongPress: () {
                                  if (isConfirmed) {
                                    return;
                                  }

                                  _toggleAnimation();
                                  _startShadowPulseAnimation();

                                  if (chronoBarState == ChronoBarState.circle) {
                                    context
                                        .read<TimelineCubit>()
                                        .cancelTimeBlock();
                                    isBlockingTime = false;
                                  }

                                  setState(() {
                                    switch (chronoBarState) {
                                      case ChronoBarState.line:
                                        chronoBarState = ChronoBarState.circle;
                                      case ChronoBarState.circle:
                                        chronoBarState = ChronoBarState.line;
                                    }
                                  });

                                  unawaited(HapticFeedback.heavyImpact());
                                },
                                onHorizontalDragEnd: (details) {
                                  if (isConfirmed) {
                                    return;
                                  }

                                  if (chronoBarState == ChronoBarState.circle) {
                                    return;
                                  }

                                  context.read<TimelineCubit>().snapToMinute();
                                  _startHorizontalShadowAnimation();
                                },
                                onHorizontalDragUpdate: (details) {
                                  if (isConfirmed) {
                                    return;
                                  }

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
                                child: _buildGestureDetectorChildren(
                                  screenWidth,
                                  value,
                                  widgetMaxWidth,
                                  context,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );

  ClipRRect _buildGestureDetectorChildren(
    double screenWidth,
    double value,
    double widgetMaxWidth,
    BuildContext context,
  ) =>
      ClipRRect(
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
          width: (screenWidth - chronoBarCircleHeight) * value +
              chronoBarCircleHeight,
          //f(0) = 72
          //f(1) = 36
          //f(x) = kx + n
          // 72 = n
          // 36 = k + n
          // 36 = -k
          // k = -36
          // f(x) = -36x + 72
          height: -chronoBarLineHeight * value + chronoBarCircleHeight,
          decoration: BoxDecoration(
            border: Border.all(
              color: kBlack,
            ),
            // gradient: chronoBarState ==
            // ChronoBarState.circle
            //     ? SweepGradient(
            //         colors: [
            //           kSecondaryColor.withAlpha(255),
            //           kPrimaryColor.withAlpha(255),
            //         ],
            //         stops: const [0.2, 0.8],
            //         transform: GradientRotation(
            //           // -verticalDelta / 50,
            //           3 * pi / 2 + dialRotation / 50,
            //         ),
            //       )
            //     : null,
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
          child: isConfirmed
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: kPadding,
                  ),
                  child: LayoutBuilder(
                    builder: (context, rowConstraints) {
                      final double rowMaxWidth = rowConstraints.maxWidth;

                      return Row(
                        children: [
                          if (textFieldStep != 3)
                            Expanded(
                              child: TextField(
                                focusNode: textFieldFocusNode,
                                controller: textFieldController,
                                textInputAction: TextInputAction.newline,
                                onSubmitted: _onTextFieldSubmit,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: textFieldLabel,
                                ),
                              ),
                            ),
                          if (textFieldStep == 3)
                            Row(
                              children: TaskType.values
                                  .map(
                                    (type) => SizedBox(
                                      width: (rowMaxWidth - 4 * kPadding) /
                                          TaskType.values.length,
                                      child: IconButton(
                                        onPressed: () async {
                                          setState(() {
                                            taskType = type;
                                          });

                                          await context
                                              .read<TimelineCubit>()
                                              .addTask(
                                                title: taskName!,
                                                description: taskDescription!,
                                                taskType: type,
                                              );

                                          setState(() {
                                            isConfirmed = false;
                                            isBlockingTime = false;
                                            chronoBarState =
                                                ChronoBarState.line;
                                            taskName = null;
                                            taskDescription = null;
                                            taskType = null;
                                            textFieldLabel = 'Enter task name';
                                            textFieldStep = 1;
                                          });

                                          _runConfirmedShadowAnimation();
                                        },
                                        icon: Text(
                                          type.identifier,
                                          style: const TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          const SizedBox(
                            width: kPadding,
                          ),
                          SizedBox(
                            width: kPadding * 2,
                            child: IconButton(
                              icon: const Icon(Icons.cancel),
                              onPressed: () {
                                context.read<TimelineCubit>().cancelTimeBlock();
                                setState(() {
                                  isConfirmed = false;
                                  isBlockingTime = false;
                                  chronoBarState = ChronoBarState.line;
                                });
                                _runConfirmedShadowAnimation();
                              },
                            ),
                          ),
                          const SizedBox(
                            width: kPadding,
                          ),
                        ],
                      );
                    },
                  ),
                )
              : null,
        ),
      );
}
