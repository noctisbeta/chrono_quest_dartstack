import 'package:chrono_quest/agenda/components/cycles_painter.dart';
import 'package:chrono_quest/agenda/controllers/agenda_bloc.dart';
import 'package:chrono_quest/agenda/models/agenda_state.dart';
import 'package:chrono_quest/authentication/components/my_elevated_button.dart';
import 'package:chrono_quest/authentication/components/my_outlined_text.dart';
import 'package:chrono_quest/common/constants/colors.dart';
import 'package:chrono_quest/common/constants/numbers.dart';
import 'package:chrono_quest/router/router_path.dart';
import 'package:common/agenda/cycle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class CyclesOverview extends StatelessWidget {
  const CyclesOverview({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
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
                          context.goNamed(RouterPath.addCycle.name);
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
                      size: Size.infinite,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: (cycles.length / 3).ceil(),
                            itemBuilder: (context, horizontalIndex) => SizedBox(
                              width: 200,
                              child: ListView.builder(
                                itemCount: 3,
                                itemBuilder: (context, verticalIndex) {
                                  final int index =
                                      horizontalIndex * 3 + verticalIndex;
                                  if (index >= cycles.length) {
                                    return const SizedBox.shrink();
                                  }

                                  final Cycle cycle = cycles[index];
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
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(kPadding),
                          child: MyElevatedButton(
                            label: 'Add Cycle',
                            backgroundColor: kQuaternaryColor,
                            onPressed: () {
                              // TODO(Janez): Implement add cycle functionality
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );
}
