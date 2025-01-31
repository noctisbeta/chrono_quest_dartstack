import 'package:chrono_quest/agenda/components/timeline_painter.dart';
import 'package:chrono_quest/agenda/controllers/timeline_cubit.dart';
import 'package:chrono_quest/agenda/models/timeline_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AgendaTimeline extends StatefulWidget {
  const AgendaTimeline({super.key});

  @override
  State<AgendaTimeline> createState() => _AgendaTimelineState();
}

class _AgendaTimelineState extends State<AgendaTimeline>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<TimelineCubit, TimelineState>(
        builder: (context, state) => Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: TimelinePainter(
                  scrollOffset: state.scrollOffset,
                  currentTime: context.read<TimelineCubit>().currentTime,
                  zoomFactor: state.zoomFactor,
                ),
              ),
            ),
          ],
        ),
      );
}
