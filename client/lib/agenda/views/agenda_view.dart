import 'package:chrono_quest/agenda/components/activity_tile.dart';
import 'package:chrono_quest/agenda/components/agenda_timeline.dart';
import 'package:chrono_quest/agenda/components/chrono_bar.dart';
import 'package:chrono_quest/agenda/controllers/agenda_bloc.dart';
import 'package:chrono_quest/agenda/controllers/scroll_cubit.dart';
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
  Offset horizontalOffset = Offset.zero;

  DragUpdateDetails horizontalDetails = DragUpdateDetails(
    primaryDelta: 0,
    globalPosition: Offset.zero,
    localPosition: Offset.zero,
  );

  double horizontalDelta = 0;

  late AnimationController _animationController;

  late Animation<double> _animation;

  bool chronoBarState = false;

  BorderRadius? chronoBarBorderRadius =
      BorderRadius.circular(kBorderRadius * 6);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _animationController
      ..removeListener(_animationListener)
      ..dispose();
    super.dispose();
  }

  void _animationListener() {
    setState(() {
      horizontalDelta = _animation.value;
    });
  }

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => ScrollCubit(
          vsync: this,
        ),
        child: SafeArea(
          child: BlocConsumer<AgendaBloc, AgendaState>(
            listener: (context, state) {},
            builder: (context, state) => Scaffold(
              backgroundColor: kPrimaryColor,
              body: Container(
                margin: const EdgeInsets.all(kPadding),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.4,
                      padding: const EdgeInsets.all(kPadding),
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
                            ActivityTile(
                              title: 'Activity 3',
                              subtitle: 'Details about activity 3',
                              icon: Icons.access_alarm,
                              onTap: () {},
                            ),
                          ],
                        ),
                        const SizedBox(height: kPadding * 3),
                        const ChronoBar(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}
