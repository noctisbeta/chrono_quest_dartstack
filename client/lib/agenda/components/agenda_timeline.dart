import 'package:chrono_quest/agenda/components/agenda_painter.dart';
import 'package:chrono_quest/agenda/controllers/scroll_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AgendaTimeline extends StatefulWidget {
  const AgendaTimeline({super.key});

  @override
  State<AgendaTimeline> createState() => _AgendaTimelineState();
}

class _AgendaTimelineState extends State<AgendaTimeline>
    with TickerProviderStateMixin {
  DateTime currentTime = DateTime.now();

  // late AnimationController _animationController;

  // late Animation<double> _animation;

  // @override
  // void initState() {
  //   super.initState();
  //   _animationController = AnimationController(
  //     vsync: this,
  //     duration: const Duration(seconds: 1),
  //   );
  // }

  // @override
  // void dispose() {
  //   _animationController.dispose();
  //   super.dispose();
  // }

  // void _animationListener() {
  //   setState(() {
  //     offset = _animation.value;
  //   });
  // }

  // void _startAnimation() {
  //   _animationController
  //     ..removeListener(_animationListener)
  //     ..value = 0;

  //   _animation = Tween<double>(begin: offset, end: 0).animate(
  //     CurvedAnimation(
  //       parent: _animationController,
  //       curve: Curves.elasticOut,
  //     ),
  //   );
  //   _animationController
  //     ..removeListener(_animationListener)
  //     ..addListener(_animationListener)
  //     ..forward();
  // }

  @override
  Widget build(BuildContext context) => BlocBuilder<ScrollCubit, ScrollState>(
        builder: (context, state) => Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onHorizontalDragUpdate: (details) {
                  context
                      .read<ScrollCubit>()
                      .updateOffset(details.primaryDelta ?? 0);
                },
                child: CustomPaint(
                  painter: AgendaPainter(
                    offset: state.offset,
                    currentTime: currentTime,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}
