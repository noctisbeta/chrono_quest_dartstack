import 'dart:async';

import 'package:chrono_quest/agenda/controllers/scroll_cubit.dart';
import 'package:chrono_quest/agenda/models/chrono_bar_state.dart';
import 'package:chrono_quest/common/constants/colors.dart';
import 'package:chrono_quest/common/constants/numbers.dart';
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

  late final AnimationController _animationController;
  late final AnimationController _shadowAnimationController;

  late final Animation<double> _animation;

  late Animation<double> _shadowAnimation;

  double horizontalDelta = 0;

  double previousHapticAt = 0;

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
    LOG.d('Starting shadow animation');
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
                height: 72,
                child: Stack(
                  children: [
                    Positioned(
                      top: 18 * value,
                      left: (1 - value) * (widgetMaxWidth - 72) / 2,
                      right: (1 - value) * (widgetMaxWidth - 72) / 2,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onLongPress: () {
                          setState(() {
                            switch (chronoBarState) {
                              case ChronoBarState.line:
                                chronoBarState = ChronoBarState.circle;
                              case ChronoBarState.circle:
                                chronoBarState = ChronoBarState.line;
                            }
                          });

                          toggleAnimation();
                          unawaited(HapticFeedback.selectionClick());
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
                          context
                              .read<ScrollCubit>()
                              .updateOffset(details.primaryDelta ?? 0);

                          setState(() {
                            horizontalDelta += details.delta.dx / 10;
                          });

                          if ((previousHapticAt - horizontalDelta).abs() > 2) {
                            unawaited(HapticFeedback.lightImpact());
                            previousHapticAt = horizontalDelta;
                          }
                        },
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(kBorderRadius * 60),
                          child: Container(
                            // f(0) = 72
                            // f(1) = width
                            // f(x) = (width - 72) * x + 72
                            // f(x) = kx + n
                            // 72 = n
                            // width = k + n
                            // 72 - width = -k
                            // k = width - 72
                            width: (screenWidth - 72) * value + 72,
                            //f(0) = 72
                            //f(1) = 36
                            //f(x) = kx + n
                            // 72 = n
                            // 36 = k + n
                            // 36 = -k
                            // k = -36
                            // f(x) = -36x + 72
                            height: -36 * value + 72,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: kBlack,
                              ),
                              borderRadius: BorderRadius.circular(
                                kBorderRadius * 60,
                              ),
                              boxShadow: [
                                const BoxShadow(
                                  color: kTernaryColor,
                                ),
                                BoxShadow(
                                  color: Colors.white,
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
                  ],
                ),
              );
            },
          );
        },
      );
}
