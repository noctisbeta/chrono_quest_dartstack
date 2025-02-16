import 'dart:async';

import 'package:chrono_quest/agenda/components/chrono_bar_animation_manager.dart';
import 'package:chrono_quest/agenda/components/chrono_bar_text_field.dart';
import 'package:chrono_quest/agenda/controllers/agenda_bloc.dart';
import 'package:chrono_quest/agenda/controllers/timeline_cubit.dart';
import 'package:chrono_quest/agenda/models/agenda_event.dart';
import 'package:chrono_quest/agenda/models/chrono_bar_state.dart';
import 'package:chrono_quest/agenda/models/text_field_step.dart';
import 'package:chrono_quest/agenda/models/timeline_state.dart';
import 'package:chrono_quest/common/components/my_outlined_text.dart';
import 'package:chrono_quest/common/constants/colors.dart';
import 'package:chrono_quest/common/constants/numbers.dart';
import 'package:chrono_quest/common/util/conditional_child.dart';
import 'package:chrono_quest/common/util/conditional_parent.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChronoBar extends StatefulWidget {
  const ChronoBar({super.key, this.isOnAddCycleView = false});

  final bool isOnAddCycleView;

  @override
  State<ChronoBar> createState() => _ChronoBarState();
}

class _ChronoBarState extends State<ChronoBar> with TickerProviderStateMixin {
  static const double chronoBarLineHeight = 50;
  static const double chronoBarCircleHeight = 100;

  ChronoBarState chronoBarState = ChronoBarState.line;

  late final ChronoBarAnimationManager _animationManager =
      ChronoBarAnimationManager(vsync: this);

  bool isBlockingTime = false;

  static Map<TextFieldStep, String> textFieldHints = {
    TextFieldStep.from(1): 'Enter cycle period',
    TextFieldStep.from(2): 'Enter cycle name',
    TextFieldStep.from(3): 'Enter cycle note',
  };
  TextFieldStep textFieldStep = TextFieldStep.from(1);
  late String textFieldHint = textFieldHints[textFieldStep]!;
  TextInputType textInputType = TextInputType.number;
  final TextEditingController textFieldController = TextEditingController();
  final textFieldFocusNode = FocusNode();
  String? cycleName;
  String? cycleNote;
  int? period;
  late bool isEnteringPeriod = widget.isOnAddCycleView;

  @override
  void initState() {
    super.initState();

    _animationManager.chronoBarStateAnimation?.addStatusListener(
      _chronoBarStateStatusListener,
    );
  }

  @override
  void dispose() {
    _animationManager.chronoBarStateAnimation?.removeStatusListener(
      _chronoBarStateStatusListener,
    );

    textFieldController.dispose();
    textFieldFocusNode.dispose();

    _animationManager.dispose();

    super.dispose();
  }

  void _chronoBarStateStatusListener(AnimationStatus status) {
    if (status == AnimationStatus.completed && (widget.isOnAddCycleView)) {
      textFieldFocusNode.requestFocus();
    }
  }

  void _proceedToNextStep({required bool focus}) {
    textFieldStep++;
    textFieldController.clear();
    setState(() {
      textFieldHint = textFieldHints[textFieldStep]!;
    });
    if (focus) {
      textFieldFocusNode.requestFocus();
    } else {
      textFieldFocusNode.unfocus();
    }
  }

  void _resetEverything() {
    setState(() {
      _animationManager.isConfirmed.value = false;
      isBlockingTime = false;
      chronoBarState = ChronoBarState.line;
      cycleName = null;
      cycleNote = null;
      period = null;
      textFieldStep =
          isEnteringPeriod ? TextFieldStep.from(1) : TextFieldStep.from(2);
      textFieldHint = textFieldHints[textFieldStep]!;
      textFieldController.clear();
    });
  }

  Future<void> _submitAddingCycle() async {
    _animationManager.runConfirmedShadowAnimation();

    final TimelineState timelineState = context.read<TimelineCubit>().state;

    final DateTime startTime = context.read<TimelineCubit>().timeFromOffset(
      timelineState.timeBlockStartOffset!,
    );

    final DateTime endTime = context.read<TimelineCubit>().timeFromOffset(
      timelineState.timeBlockStartOffset! -
          timelineState.timeBlockDurationMinutes!,
    );

    context.read<TimelineCubit>().cancelTimeBlock();

    final AgendaEventAddCycle event = AgendaEventAddCycle(
      title: cycleName!,
      note: cycleNote!,
      period: period!,
      startTime: startTime,
      endTime: endTime,
    );

    context.read<AgendaBloc>().add(event);

    _resetEverything();
  }

  Future<void> _onTextFieldSubmit(String value) async {
    switch (textFieldStep) {
      case 1:
        period = int.tryParse(value);
        _proceedToNextStep(focus: false);
        isEnteringPeriod = false;
        context.read<TimelineCubit>().setPeriod(period);
      case 2:
        cycleName = value;
        _proceedToNextStep(focus: true);
      case 3:
        cycleNote = value;
        await _submitAddingCycle();
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

  void _handleVerticalDragUpdate(DragUpdateDetails details) {
    if (_animationManager.isConfirmed.value) {
      return;
    }

    _animationManager.verticalDelta.value += details.delta.dy / 5;

    if (chronoBarState == ChronoBarState.circle) {
      context.read<TimelineCubit>().addTimeBlockDuration(details.delta.dy / 4);
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
  }

  void _handleVerticalDragEnd(DragEndDetails details) {
    if (_animationManager.isConfirmed.value) {
      return;
    }

    if (chronoBarState == ChronoBarState.circle) {
      context.read<TimelineCubit>().snapTimeBlock();
    }

    _animationManager.startVerticalShadowAnimation();
  }

  void _handleDoubleTap() {
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
        context.read<TimelineCubit>().confirmTimeBlock();
        setState(() {
          _animationManager.isConfirmed.value = true;
          chronoBarState = ChronoBarState.line;
        });
        _animationManager
          ..runConfirmedShadowAnimation()
          ..toggleAnimation()
          ..startShadowPulseAnimation();
        textFieldFocusNode.requestFocus();
      }
    }
  }

  void _handleLongPress() {
    if (_animationManager.isConfirmed.value) {
      return;
    }

    _animationManager
      ..toggleAnimation()
      ..startShadowPulseAnimation();

    if (chronoBarState == ChronoBarState.line) {
      context.read<TimelineCubit>().startTimeBlock();
      isBlockingTime = true;
    }

    if (chronoBarState == ChronoBarState.circle) {
      context.read<TimelineCubit>().cancelTimeBlock();

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
  }

  void _handleHorizontalDragEnd(DragEndDetails details) {
    if (_animationManager.isConfirmed.value) {
      return;
    }

    context.read<TimelineCubit>().snapToMinute();
    _animationManager.startHorizontalShadowAnimation();
  }

  void _handleHorizontalDragUpdate(DragUpdateDetails details) {
    if (_animationManager.isConfirmed.value) {
      return;
    }

    final double deltaX = details.delta.dx;

    context.read<TimelineCubit>().scrollTimeline(details.primaryDelta ?? 0);

    _animationManager.horizontalDelta.value += deltaX / 10;
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

          final double verticalDelta = _animationManager.verticalDelta.value;

          final bool isConfirmed = _animationManager.isConfirmed.value;

          final double screenWidth = MediaQuery.of(context).size.width;

          return Material(
            color: Colors.transparent,
            child: SizedBox(
              height: chronoBarCircleHeight,
              child: Stack(
                children: [
                  Positioned(
                    top: chronoBarLineHeight / 2 * chronoBarStateValue,
                    left:
                        (1 - chronoBarStateValue) *
                        (widgetMaxWidth - chronoBarCircleHeight) /
                        2,
                    right:
                        (1 - chronoBarStateValue) *
                        (widgetMaxWidth - chronoBarCircleHeight) /
                        2,
                    child: Container(
                      width:
                          (screenWidth - chronoBarCircleHeight) *
                              chronoBarStateValue +
                          chronoBarCircleHeight,
                      height:
                          -chronoBarLineHeight * chronoBarStateValue +
                          chronoBarCircleHeight,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(kBorderRadius * 6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue,
                            spreadRadius:
                                confirmedShadowSpread +
                                -10 +
                                shadowPulseDelta * 10,
                            blurRadius:
                                (20 +
                                        horizontalDelta.abs() +
                                        verticalDelta.abs())
                                    .abs(),
                          ),
                          BoxShadow(
                            color: Colors.pinkAccent,
                            spreadRadius:
                                confirmedShadowSpread -
                                10.0 +
                                (-1 *
                                    ((horizontalDelta + verticalDelta) ~/ 5)) +
                                shadowPulseDelta * 7,
                            blurRadius:
                                (20 +
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
                    left:
                        (1 - chronoBarStateValue) *
                        (widgetMaxWidth - chronoBarCircleHeight) /
                        2,
                    right:
                        (1 - chronoBarStateValue) *
                        (widgetMaxWidth - chronoBarCircleHeight) /
                        2,
                    child: ConditionalParent(
                      condition: !isConfirmed && !isEnteringPeriod,
                      parentBuilder:
                          (child) => GestureDetector(
                            behavior: HitTestBehavior.deferToChild,
                            onVerticalDragUpdate: _handleVerticalDragUpdate,
                            onVerticalDragEnd: _handleVerticalDragEnd,
                            onDoubleTap: _handleDoubleTap,
                            onLongPress: _handleLongPress,
                            onHorizontalDragEnd: _handleHorizontalDragEnd,
                            onHorizontalDragUpdate: _handleHorizontalDragUpdate,
                            child: child,
                          ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(kBorderRadius * 6),
                        child: Container(
                          width:
                              (screenWidth - chronoBarCircleHeight) *
                                  chronoBarStateValue +
                              chronoBarCircleHeight,
                          height:
                              -chronoBarLineHeight * chronoBarStateValue +
                              chronoBarCircleHeight,
                          decoration: BoxDecoration(
                            border: Border.all(color: kBlack),
                            borderRadius: BorderRadius.circular(
                              kBorderRadius * 6,
                            ),
                            boxShadow: [
                              const BoxShadow(color: kTernaryColor),
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
                          child: ConditionalChild(
                            condition:
                                isConfirmed ||
                                (widget.isOnAddCycleView &&
                                    textFieldStep == TextFieldStep.from(1)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: kPadding,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: ChronoBarTextField(
                                      textInputType: textInputType,
                                      onSubmitted: _onTextFieldSubmit,
                                      focusNode: textFieldFocusNode,
                                      hintText: textFieldHint,
                                      textEditingController:
                                          textFieldController,
                                    ),
                                  ),
                                  if (!isEnteringPeriod)
                                    IconButton(
                                      icon: const Icon(
                                        Icons.cancel,
                                        color: kBlack,
                                      ),
                                      onPressed: () {
                                        context
                                            .read<TimelineCubit>()
                                            .cancelTimeBlock();

                                        _resetEverything();

                                        _animationManager
                                            .runConfirmedShadowAnimation();
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
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
}
