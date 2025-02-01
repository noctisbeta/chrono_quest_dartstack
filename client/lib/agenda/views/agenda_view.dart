import 'package:chrono_quest/agenda/components/activity_tile.dart';
import 'package:chrono_quest/agenda/components/agenda_timeline.dart';
import 'package:chrono_quest/agenda/components/chrono_bar.dart';
import 'package:chrono_quest/agenda/controllers/agenda_bloc.dart';
import 'package:chrono_quest/agenda/controllers/timeline_cubit.dart';
import 'package:chrono_quest/agenda/models/agenda_state.dart';
import 'package:chrono_quest/common/constants/colors.dart';
import 'package:chrono_quest/common/constants/numbers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AgendaView extends StatefulWidget {
  const AgendaView({super.key});

  @override
  State<AgendaView> createState() => _AgendaViewState();
}

class _AgendaViewState extends State<AgendaView> with TickerProviderStateMixin {
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showOverlay(context);
    });
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _showOverlay(BuildContext context) {
    _overlayEntry = _createOverlayEntry(
      context,
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry(BuildContext context) => OverlayEntry(
        builder: (_) => BlocProvider.value(
          value: BlocProvider.of<TimelineCubit>(context),
          child: const Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: ChronoBar(),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => BlocConsumer<AgendaBloc, AgendaState>(
        listener: (context, state) {},
        builder: (context, state) => Scaffold(
          backgroundColor: kPrimaryColor,
          body: SafeArea(
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
                      const SizedBox(height: kPadding * 3),
                      // const ChronoBar(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
