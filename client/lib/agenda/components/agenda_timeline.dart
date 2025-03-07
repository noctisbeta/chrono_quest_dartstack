import 'package:chrono_quest/agenda/components/timeline_painter.dart';
import 'package:chrono_quest/agenda/controllers/agenda_bloc.dart';
import 'package:chrono_quest/agenda/controllers/timeline_cubit.dart';
import 'package:chrono_quest/agenda/models/agenda_state.dart';
import 'package:chrono_quest/agenda/models/timeline_state.dart';
import 'package:chrono_quest/common/constants/colors.dart';
import 'package:common/agenda/cycle.dart';
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
        builder:
            (context, timelineState) => BlocBuilder<AgendaBloc, AgendaState>(
              builder: (context, agendaState) {
                final int? period = context.read<TimelineCubit>().state.period;

                final List<Cycle> cycles = switch (agendaState) {
                  AgendaStateCyclesLoaded(:final List<Cycle> cycles) =>
                    cycles
                        .where(
                          (cycle) =>
                              period != null && (period % cycle.period == 0),
                        )
                        .toList(),
                  _ => [],
                };

                return LayoutBuilder(
                  builder:
                      (context, constraints) => SizedBox(
                        height: constraints.maxHeight,
                        width: constraints.maxWidth,
                        child: DecoratedBox(
                          decoration: const BoxDecoration(color: kWhite),
                          child: CustomPaint(
                            painter: TimelinePainter(
                              scrollOffset: timelineState.scrollOffset,
                              currentTime: timelineState.currentTime,
                              zoomFactor: timelineState.zoomFactor,
                              timeBlockStartOffset:
                                  timelineState.timeBlockStartOffset,
                              timeBlockDurationMinutes:
                                  timelineState.timeBlockDurationMinutes,
                              cycles: cycles,
                            ),
                          ),
                        ),
                      ),
                );
              },
            ),
      );
}
