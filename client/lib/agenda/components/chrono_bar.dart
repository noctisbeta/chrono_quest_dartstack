import 'dart:async';

import 'package:chrono_quest/agenda/components/chrono_bar_animation_manager.dart';
import 'package:chrono_quest/agenda/controllers/timeline_cubit.dart';
import 'package:chrono_quest/agenda/models/chrono_bar_state.dart';
import 'package:chrono_quest/agenda/models/timeline_state.dart';
import 'package:chrono_quest/authentication/components/my_outlined_text.dart';
import 'package:chrono_quest/common/constants/colors.dart';
import 'package:chrono_quest/common/constants/numbers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChronoBar extends StatefulWidget {
  const ChronoBar({
    super.key,
    this.isOnAddCycleView = false,
  });

  final bool isOnAddCycleView;

  @override
  State<ChronoBar> createState() => _ChronoBarState();
}

class _ChronoBarState extends State<ChronoBar> with TickerProviderStateMixin {
  ChronoBarState chronoBarState = ChronoBarState.line;

  late final ChronoBarAnimationManager _animationManager;

  static const double chronoBarLineHeight = 50;
  static const double chronoBarCircleHeight = 100;

  bool isBlockingTime = false;

  final TextEditingController textFieldController = TextEditingController();
  final textFieldFocusNode = FocusNode();

  String textFieldHint = 'Enter cycle name';
  int textFieldStep = 1;
  String? cycleName;
  String? cycleNote;
  int? period;

  @override
  void initState() {
    super.initState();

    _animationManager = ChronoBarAnimationManager(
      vsync: this,
    );
  }

  @override
  void dispose() {
    textFieldController.dispose();
    textFieldFocusNode.dispose();

    super.dispose();
  }

  void _onTextFieldSubmit(String value) {
    if (textFieldStep == 3) {}

    if (textFieldStep == 2) {
      setState(() {
        cycleNote = textFieldController.text;
        textFieldHint = 'Enter cycle repetition';
      });
      textFieldStep = 3;
      textFieldController.clear();
    }

    if (textFieldStep == 1) {
      if (textFieldController.text.isEmpty) {
        return;
      }

      setState(() {
        cycleName = textFieldController.text;
        textFieldHint = 'Enter cycle note';
      });

      textFieldController.clear();
      textFieldFocusNode.requestFocus();
      textFieldStep = 2;
    }
  }

  void resetTimeline() {
    context.read<TimelineCubit>().resetTimeline();

    _animationManager
      ..resetScroll(
        context.read<TimelineCubit>().state.scrollOffset,
        () => context.read<TimelineCubit>().setScrollOffset(
              _animationManager.resetScrollAnimation!.value,
            ),
      )
      ..resetZoom(
        context.read<TimelineCubit>().state.zoomFactor,
        () => context.read<TimelineCubit>().setZoomFactor(
              _animationManager.resetZoomAnimation!.value,
            ),
      );
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final double widgetMaxWidth = constraints.maxWidth;

          return AnimatedBuilder(
            animation: _animationManager.mergedAnimations,
            builder: (context, child) {
              final double chronoBarStateValue =
                  _animationManager.chronoBarStateAnimation!.value;

              final double confirmedShadowSpread =
                  _animationManager.confirmedShadowAnimation!.value;

              final double shadowPulseDelta =
                  _animationManager.shadowPulseDelta.value;

              final double horizontalDelta =
                  _animationManager.horizontalDelta.value;

              final double verticalDelta =
                  _animationManager.verticalDelta.value;

              final double screenWidth = MediaQuery.of(context).size.width;

              return Material(
                color: Colors.transparent,
                child: SizedBox(
                  height: chronoBarCircleHeight,
                  child: Stack(
                    children: [
                      Positioned(
                        top: chronoBarLineHeight / 2 * chronoBarStateValue,
                        left: (1 - chronoBarStateValue) *
                            (widgetMaxWidth - chronoBarCircleHeight) /
                            2,
                        right: (1 - chronoBarStateValue) *
                            (widgetMaxWidth - chronoBarCircleHeight) /
                            2,
                        child: Container(
                          width: (screenWidth - chronoBarCircleHeight) *
                                  chronoBarStateValue +
                              chronoBarCircleHeight,
                          height: -chronoBarLineHeight * chronoBarStateValue +
                              chronoBarCircleHeight,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(
                              kBorderRadius * 6,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue,
                                spreadRadius: confirmedShadowSpread +
                                    -10 +
                                    shadowPulseDelta * 10,
                                blurRadius: (20 +
                                        horizontalDelta.abs() +
                                        verticalDelta.abs())
                                    .abs(),
                              ),
                              BoxShadow(
                                color: Colors.pinkAccent,
                                spreadRadius: confirmedShadowSpread -
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
                        top: 0,
                        left: kPadding + 1,
                        child: MyOutlinedText(
                          text: cycleName ?? '',
                          fontSize: 16,
                          strokeWidth: 3,
                          foreground: kBlack,
                          background: kWhite,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Positioned(
                        top: chronoBarLineHeight / 2 * chronoBarStateValue,
                        left: (1 - chronoBarStateValue) *
                            (widgetMaxWidth - chronoBarCircleHeight) /
                            2,
                        right: (1 - chronoBarStateValue) *
                            (widgetMaxWidth - chronoBarCircleHeight) /
                            2,
                        child: _animationManager.isConfirmed.value
                            ? _buildGestureDetectorChildren(
                                screenWidth,
                                chronoBarStateValue,
                                widgetMaxWidth,
                                context,
                                horizontalDelta,
                                verticalDelta,
                              )
                            : GestureDetector(
                                behavior: HitTestBehavior.deferToChild,
                                onVerticalDragUpdate: (details) {
                                  if (_animationManager.isConfirmed.value) {
                                    return;
                                  }

                                  _animationManager.verticalDelta.value +=
                                      details.delta.dy / 5;

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
                                  if (_animationManager.isConfirmed.value) {
                                    return;
                                  }

                                  if (chronoBarState == ChronoBarState.circle) {
                                    context
                                        .read<TimelineCubit>()
                                        .snapTimeBlock();
                                  }

                                  _animationManager
                                      .startVerticalShadowAnimation(
                                    verticalDelta,
                                  );
                                },
                                onDoubleTap: () async {
                                  if (_animationManager.isConfirmed.value) {
                                    return;
                                  }

                                  _animationManager.startShadowPulseAnimation();
                                  unawaited(HapticFeedback.mediumImpact());

                                  if (chronoBarState == ChronoBarState.line) {
                                    resetTimeline();
                                    return;
                                  }

                                  if (chronoBarState == ChronoBarState.circle) {
                                    if (isBlockingTime) {
                                      context
                                          .read<TimelineCubit>()
                                          .confirmTimeBlock();
                                      setState(() {
                                        _animationManager.isConfirmed.value =
                                            true;
                                        chronoBarState = ChronoBarState.line;
                                      });
                                      _animationManager
                                        ..runConfirmedShadowAnimation()
                                        ..toggleAnimation()
                                        ..startShadowPulseAnimation();
                                      textFieldFocusNode.requestFocus();
                                    }
                                  }
                                },
                                onLongPress: () {
                                  if (_animationManager.isConfirmed.value) {
                                    return;
                                  }

                                  _animationManager
                                    ..toggleAnimation()
                                    ..startShadowPulseAnimation();

                                  if (chronoBarState == ChronoBarState.line) {
                                    context
                                        .read<TimelineCubit>()
                                        .startTimeBlock();
                                    isBlockingTime = true;
                                  }

                                  if (chronoBarState == ChronoBarState.circle) {
                                    context
                                        .read<TimelineCubit>()
                                        .cancelTimeBlock();
                                    setState(() {
                                      _animationManager.isConfirmed.value =
                                          false;
                                      isBlockingTime = false;
                                      cycleNote = null;
                                      cycleName = null;
                                      period = null;
                                      textFieldHint = 'Enter cycle name';
                                      textFieldStep = 1;
                                    });
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
                                  if (_animationManager.isConfirmed.value) {
                                    return;
                                  }

                                  context.read<TimelineCubit>().snapToMinute();

                                  _animationManager
                                      .startHorizontalShadowAnimation();
                                },
                                onHorizontalDragUpdate: (details) {
                                  if (_animationManager.isConfirmed.value) {
                                    return;
                                  }

                                  final double deltaX = details.delta.dx;

                                  context.read<TimelineCubit>().scrollTimeline(
                                        details.primaryDelta ?? 0,
                                      );

                                  _animationManager.horizontalDelta.value +=
                                      deltaX / 10;
                                },
                                child: _buildGestureDetectorChildren(
                                  screenWidth,
                                  chronoBarStateValue,
                                  widgetMaxWidth,
                                  context,
                                  horizontalDelta,
                                  verticalDelta,
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
    double horizontalDelta,
    double verticalDelta,
  ) =>
      ClipRRect(
        borderRadius: BorderRadius.circular(
          kBorderRadius * 6,
        ),
        child: Container(
          width: (screenWidth - chronoBarCircleHeight) * value +
              chronoBarCircleHeight,
          height: -chronoBarLineHeight * value + chronoBarCircleHeight,
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
          child: _animationManager.isConfirmed.value
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: kPadding,
                  ),
                  child: LayoutBuilder(
                    builder: (context, rowConstraints) => Row(
                      children: [
                        if (widget.isOnAddCycleView)
                          const Expanded(
                            child: TextField(
                              autofocus: true,
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.number,
                              style: TextStyle(
                                color: kBlack,
                                fontWeight: FontWeight.w900,
                              ),
                              cursorColor: kBlack,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Enter period',
                                hintStyle: TextStyle(
                                  color: kBlack,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        if (textFieldStep != 3)
                          Expanded(
                            child: TextField(
                              textCapitalization: TextCapitalization.words,
                              style: const TextStyle(
                                color: kBlack,
                                fontWeight: FontWeight.w900,
                              ),
                              cursorColor: kBlack,
                              focusNode: textFieldFocusNode,
                              controller: textFieldController,
                              textInputAction: TextInputAction.newline,
                              onSubmitted: _onTextFieldSubmit,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: textFieldHint,
                                hintStyle: const TextStyle(
                                  color: kBlack,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        if (textFieldStep == 3)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(width: 8),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 50,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      border: Border(
                                        left: BorderSide(
                                          color: kBlack.withValues(alpha: 0.4),
                                          width: 2,
                                        ),
                                        right: BorderSide(
                                          color: kBlack.withValues(alpha: 0.4),
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    child: ListWheelScrollView(
                                      physics: const FixedExtentScrollPhysics(),
                                      diameterRatio: 1.2,
                                      perspective: 0.005,
                                      itemExtent: 24,
                                      onSelectedItemChanged: (int value) {
                                        unawaited(
                                          HapticFeedback.selectionClick(),
                                        );
                                        setState(() {
                                          period = value;
                                        });
                                      },
                                      children: List<Widget>.generate(
                                        100,
                                        (int index) => Center(
                                          child: MyOutlinedText(
                                            text: '$index',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                            strokeWidth: 2,
                                            foreground: kSecondaryColor,
                                            background: kWhite,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const MyOutlinedText(
                                    text: 'H',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                    strokeWidth: 2,
                                    foreground: kBlack,
                                    background: kWhite,
                                  ),
                                ],
                              ),
                              const SizedBox(width: 16),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 50,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      border: Border(
                                        left: BorderSide(
                                          color: kBlack.withValues(alpha: 0.4),
                                          width: 2,
                                        ),
                                        right: BorderSide(
                                          color: kBlack.withValues(alpha: 0.4),
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    child: ListWheelScrollView(
                                      physics: const FixedExtentScrollPhysics(),
                                      diameterRatio: 1.2,
                                      perspective: 0.005,
                                      itemExtent: 24,
                                      onSelectedItemChanged: (int value) {
                                        unawaited(
                                          HapticFeedback.selectionClick(),
                                        );
                                        setState(() {
                                          period = value;
                                        });
                                      },
                                      children: List<Widget>.generate(
                                        100,
                                        (int index) => Center(
                                          child: MyOutlinedText(
                                            text: '$index',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                            strokeWidth: 2,
                                            foreground: kSecondaryColor,
                                            background: kWhite,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const MyOutlinedText(
                                    text: 'D',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                    strokeWidth: 2,
                                    foreground: kBlack,
                                    background: kWhite,
                                  ),
                                ],
                              ),
                              const SizedBox(width: 16),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 50,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      border: Border(
                                        left: BorderSide(
                                          color: kBlack.withValues(alpha: 0.4),
                                          width: 2,
                                        ),
                                        right: BorderSide(
                                          color: kBlack.withValues(alpha: 0.4),
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    child: ListWheelScrollView(
                                      physics: const FixedExtentScrollPhysics(),
                                      diameterRatio: 1.2,
                                      perspective: 0.005,
                                      itemExtent: 24,
                                      onSelectedItemChanged: (int value) {
                                        unawaited(
                                          HapticFeedback.selectionClick(),
                                        );
                                        setState(() {
                                          period = value;
                                        });
                                      },
                                      children: List<Widget>.generate(
                                        100,
                                        (int index) => Center(
                                          child: MyOutlinedText(
                                            text: '$index',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                            strokeWidth: 2,
                                            foreground: kSecondaryColor,
                                            background: kWhite,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const MyOutlinedText(
                                    text: 'W',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                    strokeWidth: 2,
                                    foreground: kBlack,
                                    background: kWhite,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        if (textFieldStep == 3)
                          IconButton(
                            icon: const Icon(
                              Icons.check,
                              color: kBlack,
                            ),
                            onPressed: () async {
                              period ??= 0;

                              await context.read<TimelineCubit>().addCycle(
                                    title: cycleName!,
                                    note: cycleNote!,
                                    period: period!,
                                  );

                              setState(() {
                                _animationManager.isConfirmed.value = false;
                                isBlockingTime = false;
                                chronoBarState = ChronoBarState.line;
                                cycleName = null;
                                cycleNote = null;
                                period = null;
                                textFieldHint = 'Enter cycle name';
                                textFieldStep = 1;
                              });

                              _animationManager.runConfirmedShadowAnimation();
                            },
                          ),
                        IconButton(
                          icon: const Icon(
                            Icons.cancel,
                            color: kBlack,
                          ),
                          onPressed: () {
                            context.read<TimelineCubit>().cancelTimeBlock();
                            setState(() {
                              _animationManager.isConfirmed.value = false;
                              isBlockingTime = false;
                              chronoBarState = ChronoBarState.line;
                              cycleName = null;
                              cycleNote = null;
                              period = null;
                              textFieldHint = 'Enter cycle name';
                              textFieldStep = 1;
                            });
                            _animationManager.runConfirmedShadowAnimation();
                          },
                        ),
                      ],
                    ),
                  ),
                )
              : null,
        ),
      );
}
