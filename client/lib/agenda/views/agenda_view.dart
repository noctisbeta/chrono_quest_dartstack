import 'dart:async';
import 'dart:math';

import 'package:chrono_quest/agenda/components/activity_tile.dart';
import 'package:chrono_quest/agenda/components/agenda_timeline.dart';
import 'package:chrono_quest/agenda/components/chrono_bar.dart';
import 'package:chrono_quest/agenda/components/my_app_bar.dart';
import 'package:chrono_quest/agenda/controllers/agenda_bloc.dart';
import 'package:chrono_quest/agenda/controllers/timeline_cubit.dart';
import 'package:chrono_quest/agenda/models/agenda_state.dart';
import 'package:chrono_quest/agenda/models/timeline_state.dart';
import 'package:chrono_quest/authentication/components/my_elevated_button.dart';
import 'package:chrono_quest/authentication/components/my_outlined_text.dart';
import 'package:chrono_quest/common/constants/colors.dart';
import 'package:chrono_quest/common/constants/numbers.dart';
import 'package:chrono_quest/common/util/blurred_widget.dart';
import 'package:chrono_quest/common/util/unfocus_on_tap.dart';
import 'package:chrono_quest/router/router_path.dart';
import 'package:common/agenda/cycle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class AgendaView extends StatefulWidget {
  const AgendaView({super.key});

  @override
  State<AgendaView> createState() => _AgendaViewState();
}

class _AgendaViewState extends State<AgendaView> with TickerProviderStateMixin {
  OverlayEntry? overlayEntry;

  void _showOverlay() {
    _createOverlayEntry();
    Overlay.of(context).insert(overlayEntry!);
  }

  void _createOverlayEntry() {
    overlayEntry = OverlayEntry(
      builder: (overlayContext) {
        final double bottomInset =
            MediaQuery.of(overlayContext).viewInsets.bottom;

        return BlocProvider<TimelineCubit>.value(
          value: BlocProvider.of<TimelineCubit>(context),
          child: Positioned(
            bottom: bottomInset > 0 ? max(bottomInset, 100) : 100,
            left: 0 + kPadding + 1,
            right: 0 + kPadding + 1,
            child: const ChronoBar(),
          ),
        );
      },
    );
  }

  void removeOverlay() {
    overlayEntry?.remove();
    overlayEntry = null;
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showOverlay();
    });
  }

  @override
  void dispose() {
    removeOverlay();
    super.dispose();
  }

  void unfocusOnTap(BuildContext context) {
    final FocusScopeNode currentFocus = FocusScope.of(context);

    if (!currentFocus.hasPrimaryFocus && currentFocus.hasFocus) {
      currentFocus.unfocus();
    }

    unawaited(SystemChannels.textInput.invokeMethod('TextInput.hide'));
  }

  DateTime selectedDate = DateTime.now();

  void _updateSelectedDate(
    DateTime newDate,
    List<Cycle> cycles,
    DateTime referenceDate,
  ) {
    // Normalize dates to midnight
    final normalizedNewDate =
        DateTime(newDate.year, newDate.month, newDate.day);
    final normalizedRefDate =
        DateTime(referenceDate.year, referenceDate.month, referenceDate.day);

    final int maxPeriod =
        cycles.isEmpty ? 0 : cycles.map((c) => c.period).reduce(max);

    final int period =
        normalizedNewDate.difference(normalizedRefDate).inDays % maxPeriod + 1;

    context.read<TimelineCubit>().setPeriod(period);

    setState(() {
      selectedDate = normalizedNewDate;
    });
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<AgendaBloc, AgendaState>(
        builder: (context, state) {
          if (state is! AgendaStateCyclesLoaded) {
            return const Text('Error loading agenda');
          }

          final DateTime? referenceDate = state.referenceDate;

          if (referenceDate == null) {
            return const Text('Error loading agenda no reference date');
          }

          final List<Cycle> cycles = state.cycles;

          final int maxPeriod =
              cycles.isEmpty ? 0 : cycles.map((c) => c.period).reduce(max);

          final int period = DateTime(
                    selectedDate.year,
                    selectedDate.month,
                    selectedDate.day,
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

          context.read<TimelineCubit>().setPeriod(period);

          final List<Cycle> filteredCycles =
              cycles.where((cycle) => period % cycle.period == 0).toList();

          final String formattedDate =
              DateFormat('d MMMM y').format(selectedDate);
          return Scaffold(
            backgroundColor: kPrimaryColor,
            appBar: MyAppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  context.goNamed(RouterPath.agendaCycles.name);
                },
              ),
            ),
            body: SafeArea(
              child: UnfocusOnTap(
                child: SingleChildScrollView(
                  child: Container(
                    margin: const EdgeInsets.all(kPadding),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: MyOutlinedText(
                            text: 'Selected Date: '
                                '$formattedDate (Period $period)',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            strokeWidth: 1,
                            foreground: Colors.white,
                            background: Colors.black,
                          ),
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height * 0.4,
                          decoration: BoxDecoration(
                            border: Border.all(),
                          ),
                          child: const AgendaTimeline(),
                        ),
                        const SizedBox(height: 20),
                        BlocBuilder<TimelineCubit, TimelineState>(
                          builder: (context, timelineState) => BlurredWidget(
                            isBlurring: timelineState.timeBlockConfirmed,
                            child: Column(
                              children: [
                                const Text(
                                  'Upcoming Activities',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: filteredCycles.length,
                                  itemBuilder: (context, index) {
                                    final Cycle cycle = filteredCycles[index];
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: ActivityTile(
                                        title: cycle.title,
                                        subtitle: cycle.note,
                                        icon: Icons.access_alarm,
                                        onTap: () {},
                                      ),
                                    );
                                  },
                                ),
                                MyElevatedButton(
                                  label: 'Change Date',
                                  backgroundColor: kQuaternaryColor,
                                  trailing: const Icon(
                                    Icons.calendar_today,
                                    size: 20,
                                    color: kWhite,
                                  ),
                                  onPressed: () async {
                                    final DateTime? picked =
                                        await showDatePicker(
                                      context: context,
                                      initialDate: selectedDate,
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2100),
                                    );

                                    if (picked != null) {
                                      _updateSelectedDate(
                                        picked,
                                        cycles,
                                        referenceDate,
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
}
