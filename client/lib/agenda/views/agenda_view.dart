import 'dart:async';
import 'dart:math';

import 'package:chrono_quest/agenda/components/activity_tile.dart';
import 'package:chrono_quest/agenda/components/agenda_timeline.dart';
import 'package:chrono_quest/agenda/components/chrono_bar.dart';
import 'package:chrono_quest/agenda/controllers/agenda_bloc.dart';
import 'package:chrono_quest/agenda/controllers/chrono_bar_overlay_cubit.dart';
import 'package:chrono_quest/agenda/models/agenda_state.dart';
import 'package:chrono_quest/agenda/models/chrono_bar_overlay_state.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showOverlay();
    });
  }

  void _showOverlay() {
    final OverlayEntry overlayEntry = _createOverlayEntry();
    context.read<ChronoBarOverlayCubit>().showOverlay(context, overlayEntry);
  }

  OverlayEntry _createOverlayEntry() => OverlayEntry(
        builder: (context) =>
            BlocBuilder<ChronoBarOverlayCubit, ChronoBarOverlayState>(
          builder: (context, state) {
            final double bottomInset = MediaQuery.of(context).viewInsets.bottom;

            return Positioned(
              bottom: bottomInset > 0
                  ? max(bottomInset, ChronoBarOverlayState.initialBottom)
                  : ChronoBarOverlayState.initialBottom,
              left: 0 + kPadding + 1,
              right: 0 + kPadding + 1,
              child: const ChronoBar(),
            );
          },
        ),
      );

  @override
  void dispose() {
    context.read<ChronoBarOverlayCubit>().removeOverlay();
    super.dispose();
  }

  void unfocusOnTap(BuildContext context) {
    final FocusScopeNode currentFocus = FocusScope.of(context);

    if (!currentFocus.hasPrimaryFocus && currentFocus.hasFocus) {
      currentFocus.unfocus();
    }

    unawaited(SystemChannels.textInput.invokeMethod('TextInput.hide'));
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<AgendaBloc, AgendaState>(
        listener: (context, state) {},
        builder: (context, state) => Scaffold(
          backgroundColor: kPrimaryColor,
          body: SafeArea(
            child: SingleChildScrollView(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => unfocusOnTap(context),
                child: Container(
                  margin: const EdgeInsets.all(kPadding),
                  child: Column(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.4,
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
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
