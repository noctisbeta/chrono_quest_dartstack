import 'dart:async';

import 'package:chrono_quest/agenda/components/activity_tile.dart';
import 'package:chrono_quest/agenda/components/agenda_timeline.dart';
import 'package:chrono_quest/agenda/controllers/agenda_bloc.dart';
import 'package:chrono_quest/agenda/controllers/scroll_cubit.dart';
import 'package:chrono_quest/agenda/models/agenda_state.dart';
import 'package:chrono_quest/common/constants/colors.dart';
import 'package:chrono_quest/common/constants/numbers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AgendaView extends StatefulWidget {
  const AgendaView({super.key});

  @override
  State<AgendaView> createState() => _AgendaViewState();
}

class _AgendaViewState extends State<AgendaView> with TickerProviderStateMixin {
  Offset horizontalOffset = Offset.zero;

  DragUpdateDetails horizontalDetails = DragUpdateDetails(
    primaryDelta: 0,
    globalPosition: Offset.zero,
    localPosition: Offset.zero,
  );

  double horizontalDelta = 0;
  double previousHapticAt = 0;

  late AnimationController _animationController;

  late Animation<double> _animation;

  bool chronoBarState = false;

  BorderRadius? chronoBarBorderRadius =
      BorderRadius.circular(kBorderRadius * 6);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _animationController
      ..removeListener(_animationListener)
      ..dispose();
    super.dispose();
  }

  void _animationListener() {
    setState(() {
      horizontalDelta = _animation.value;
    });
  }

  void _startAnimation() {
    _animationController
      ..removeListener(_animationListener)
      ..value = 0;

    _animation = Tween<double>(begin: horizontalDelta, end: 0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.linear,
      ),
    );

    _animationController
      ..removeListener(_animationListener)
      ..addListener(_animationListener)
      ..forward();
  }

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => ScrollCubit(
          vsync: this,
        ),
        child: SafeArea(
          child: BlocConsumer<AgendaBloc, AgendaState>(
            listener: (context, state) {},
            builder: (context, state) => Scaffold(
              backgroundColor: kPrimaryColor,
              body: Container(
                margin: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.4,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(),
                      ),
                      child: const AgendaTimeline(),
                    ),
                    const SizedBox(height: 20),
                    Column(
                      children: [
                        const Text(
                          'Upcoming Activities',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Column(
                          spacing: 12,
                          children: [
                            ActivityTile(
                              title: 'Activity 1',
                              subtitle: 'Details about activity 1',
                              icon: Icons.access_alarm,
                              onTap: () {},
                            ),
                            ActivityTile(
                              title: 'Activity 2',
                              subtitle: 'Details about activity 2',
                              icon: Icons.access_alarm,
                              onTap: () {},
                            ),
                            ActivityTile(
                              title: 'Activity 3',
                              subtitle: 'Details about activity 3',
                              icon: Icons.access_alarm,
                              onTap: () {},
                            ),
                          ],
                        ),
                        const SizedBox(height: kPadding * 3),
                        IgnorePointer(
                          ignoring: _animationController.isAnimating,
                          child: GestureDetector(
                            onLongPress: () {
                              setState(() {
                                chronoBarState = !chronoBarState;
                              });
                              unawaited(HapticFeedback.selectionClick());
                            },
                            onHorizontalDragEnd: (details) {
                              _startAnimation();
                            },
                            onHorizontalDragUpdate: (details) {
                              context
                                  .read<ScrollCubit>()
                                  .updateOffset(details.primaryDelta ?? 0);
                              setState(() {
                                horizontalDelta += details.delta.dx / 10;
                              });

                              if ((previousHapticAt - horizontalDelta).abs() >
                                  2) {
                                unawaited(HapticFeedback.lightImpact());
                                previousHapticAt = horizontalDelta;
                              }
                            },
                            child: TweenAnimationBuilder(
                              duration: const Duration(milliseconds: 400),
                              tween: Tween<double>(
                                begin: chronoBarState ? 1 : 0.1,
                                end: chronoBarState ? 0.1 : 1,
                              ),
                              builder: (context, value, child) => ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(kBorderRadius * 6),
                                child: Container(
                                  width: chronoBarState
                                      ? value * 360
                                      : value *
                                          MediaQuery.of(context).size.width,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    // shape: !chronoBarState
                                    //     ? BoxShape.rectangle
                                    //     : BoxShape.circle,
                                    border: Border.all(
                                      color: kBlack,
                                    ),
                                    // borderRadius: chronoBarState
                                    //     ? null
                                    //     : chronoBarBorderRadius,
                                    borderRadius: BorderRadius.circular(
                                      kBorderRadius *
                                          (chronoBarState ? 6 : 100),
                                    ),
                                    boxShadow: [
                                      const BoxShadow(
                                        color: kTernaryColor,
                                      ),
                                      BoxShadow(
                                        color: kWhite,
                                        spreadRadius: -5,
                                        blurRadius: 20,
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
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}
