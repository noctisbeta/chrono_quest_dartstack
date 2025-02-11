import 'dart:math';

import 'package:chrono_quest/agenda/components/cycles_painter.dart';
import 'package:chrono_quest/agenda/controllers/agenda_bloc.dart';
import 'package:chrono_quest/agenda/models/agenda_event.dart';
import 'package:chrono_quest/agenda/models/agenda_state.dart';
import 'package:chrono_quest/authentication/components/my_elevated_button.dart';
import 'package:chrono_quest/authentication/components/my_outlined_text.dart';
import 'package:chrono_quest/common/constants/colors.dart';
import 'package:chrono_quest/router/router_path.dart';
import 'package:common/agenda/cycle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

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

                final DateTime? referenceDate = switch (state) {
                  AgendaStateNoCyclesLoaded(:final referenceDate) =>
                    referenceDate,
                  AgendaStateCyclesLoaded(:final referenceDate) =>
                    referenceDate,
                  _ => null,
                };

                if (referenceDate == null) {
                  return _buildNoReferenceDateView(context);
                }

                return switch (cycles.isEmpty) {
                  true => _buildCyclesEmptyView(context),
                  false => _buildCyclesNotEmptyView(cycles, context),
                };
              },
            ),
          ),
        ),
      );

  Widget _buildNoReferenceDateView(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const MyOutlinedText(
              text: 'Welcome to Chrono Quest',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              strokeWidth: 2,
              foreground: Colors.white,
              background: Colors.black,
            ),
            const SizedBox(height: 16),
            const MyOutlinedText(
              text: "Let's set up your first cycle",
              fontSize: 16,
              fontWeight: FontWeight.normal,
              strokeWidth: 1,
              foreground: Colors.white,
              background: Colors.black,
            ),
            const SizedBox(height: 32),
            MyElevatedButton(
              label: 'Set Reference Date',
              backgroundColor: kQuaternaryColor,
              trailing: const Icon(
                Icons.calendar_today,
                size: 20,
                color: kWhite,
              ),
              onPressed: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );

                if (picked != null) {
                  if (!context.mounted) {
                    return;
                  }

                  context.read<AgendaBloc>().add(
                        AgendaEventSetReferenceDate(date: picked),
                      );
                }
              },
            ),
          ],
        ),
      );

  Center _buildCyclesEmptyView(BuildContext context) => Center(
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

  Column _buildCyclesNotEmptyView(List<Cycle> cycles, BuildContext context) =>
      Column(
        children: [
          Expanded(
            child: CustomPaint(
              painter: CyclesPainter(
                cycles: cycles,
              ),
              size: const Size.square(500),
            ),
          ),
          BlocBuilder<AgendaBloc, AgendaState>(
            builder: (context, state) {
              final DateTime? referenceDate = switch (state) {
                AgendaStateCyclesLoaded(:final referenceDate) => referenceDate,
                AgendaStateNoCyclesLoaded(:final referenceDate) =>
                  referenceDate,
                _ => DateTime.now(),
              };

              final String formattedDate = DateFormat('d MMMM y').format(
                referenceDate ?? DateTime.now(),
              );
              return Padding(
                padding: const EdgeInsets.all(8),
                child: MyOutlinedText(
                  text: 'Reference Date: $formattedDate',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  strokeWidth: 1,
                  foreground: Colors.white,
                  background: Colors.black,
                ),
              );
            },
          ),
          BlocBuilder<AgendaBloc, AgendaState>(
            builder: (context, state) {
              final DateTime? referenceDate = switch (state) {
                AgendaStateCyclesLoaded(:final referenceDate) => referenceDate,
                AgendaStateNoCyclesLoaded(:final referenceDate) =>
                  referenceDate,
                _ => DateTime.now(),
              };

              final String formattedCurrentDate =
                  DateFormat('d MMMM y').format(DateTime.now());

              final int maxPeriod =
                  cycles.isEmpty ? 0 : cycles.map((c) => c.period).reduce(max);

              final int dayDifference = referenceDate == null
                  ? 0
                  : DateTime(
                            DateTime.now().year,
                            DateTime.now().month,
                            DateTime.now().day,
                          )
                              .difference(
                                DateTime(
                                  referenceDate.year,
                                  referenceDate.month,
                                  referenceDate.day,
                                ),
                              )
                              .inDays %
                          maxPeriod +
                      1;

              return Padding(
                padding: const EdgeInsets.all(8),
                child: MyOutlinedText(
                  text: 'Current Date: $formattedCurrentDate\nCurrent'
                      ' Period in Cycle: $dayDifference',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  strokeWidth: 1,
                  foreground: Colors.white,
                  background: Colors.black,
                ),
              );
            },
          ),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount:
                        cycles.map((c) => c.period).toSet().toList().length,
                    itemBuilder: (context, horizontalIndex) {
                      final List<Cycle> sortedCycles = cycles
                        ..sort(
                          (a, b) => a.period.compareTo(b.period),
                        );

                      final int period = sortedCycles
                          .map((c) => c.period)
                          .toSet()
                          .toList()[horizontalIndex];

                      final List<Cycle> cyclesWithPeriod =
                          cycles.where((c) => c.period == period).toList();

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
                                itemBuilder: (context, verticalIndex) {
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
}
