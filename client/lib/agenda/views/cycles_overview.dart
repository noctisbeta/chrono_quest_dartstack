import 'package:chrono_quest/agenda/components/cycles_painter.dart';
import 'package:chrono_quest/agenda/controllers/agenda_bloc.dart';
import 'package:chrono_quest/agenda/models/agenda_state.dart';
import 'package:chrono_quest/authentication/components/my_elevated_button.dart';
import 'package:chrono_quest/authentication/components/my_outlined_text.dart';
import 'package:chrono_quest/common/constants/colors.dart';
import 'package:chrono_quest/router/router_path.dart';
import 'package:common/agenda/cycle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class CyclesOverview extends StatelessWidget {
  const CyclesOverview({super.key});

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: false,
        child: Scaffold(
          backgroundColor: kPrimaryColor,
          body: SafeArea(
            child: BlocBuilder<AgendaBloc, AgendaState>(
              builder: (context, state) {
                final List<Cycle> cycles = switch (state) {
                  AgendaStateCyclesLoaded(:final cycles) => cycles,
                  _ => [],
                };

                if (cycles.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const MyOutlinedText(
                          text: 'No cycles yet',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          strokeWidth: 2,
                          foreground: Colors.white,
                          background: Colors.black,
                        ),
                        const SizedBox(height: 16),
                        const MyOutlinedText(
                          text: 'Add a cycle to get started',
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          strokeWidth: 1,
                          foreground: Colors.white,
                          background: Colors.black,
                        ),
                        const SizedBox(height: 32),
                        MyElevatedButton(
                          label: 'Add First Cycle',
                          backgroundColor: kQuaternaryColor,
                          trailing: const Icon(
                            Icons.add,
                            size: 20,
                            color: kWhite,
                          ),
                          onPressed: () {
                            context.goNamed(RouterPath.agendaAddCycle.name);
                          },
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    Expanded(
                      child: CustomPaint(
                        painter: CyclesPainter(),
                        size: const Size.square(300),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: cycles
                                  .map((c) => c.period)
                                  .toSet()
                                  .toList()
                                  .length,
                              itemBuilder: (context, horizontalIndex) {
                                final List<Cycle> sortedCycles = cycles
                                  ..sort(
                                    (a, b) => a.period.compareTo(b.period),
                                  );

                                final int period = sortedCycles
                                    .map((c) => c.period)
                                    .toSet()
                                    .toList()[horizontalIndex];

                                final List<Cycle> cyclesWithPeriod = cycles
                                    .where((c) => c.period == period)
                                    .toList();

                                return SizedBox(
                                  width: 200,
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Text(
                                          'Period: $period days',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: ListView.builder(
                                          itemCount: cyclesWithPeriod.length,
                                          itemBuilder:
                                              (context, verticalIndex) {
                                            final Cycle cycle =
                                                cyclesWithPeriod[verticalIndex];
                                            return Card(
                                              margin: const EdgeInsets.all(8),
                                              child: ListTile(
                                                title: Text(cycle.title),
                                                subtitle: Text(cycle.note),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          MyElevatedButton(
                            label: 'Add Cycle',
                            backgroundColor: kQuaternaryColor,
                            onPressed: () {
                              context.goNamed(RouterPath.agendaAddCycle.name);
                            },
                          ),
                          const SizedBox(height: 16),
                          MyElevatedButton(
                            label: 'Go to Overview',
                            backgroundColor: kQuaternaryColor,
                            trailing: const Icon(
                              Icons.arrow_forward,
                              size: 20,
                              color: kWhite,
                            ),
                            onPressed: () {
                              context.goNamed(RouterPath.agendaOverview.name);
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );
}
