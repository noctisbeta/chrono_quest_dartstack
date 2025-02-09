import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:chrono_quest/agenda/components/activity_tile.dart';
import 'package:chrono_quest/agenda/components/agenda_timeline.dart';
import 'package:chrono_quest/agenda/components/chrono_bar.dart';
import 'package:chrono_quest/agenda/controllers/agenda_cubit.dart';
import 'package:chrono_quest/agenda/controllers/timeline_cubit.dart';
import 'package:chrono_quest/agenda/models/timeline_state.dart';
import 'package:chrono_quest/authentication/controllers/auth_bloc.dart';
import 'package:chrono_quest/authentication/models/auth_event.dart';
import 'package:chrono_quest/common/constants/colors.dart';
import 'package:chrono_quest/common/constants/numbers.dart';
import 'package:common/agenda/cycle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
      unawaited(context.read<AgendaCubit>().getCycles());
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

  @override
  Widget build(BuildContext context) => BlocBuilder<AgendaCubit, List<Cycle>>(
        builder: (context, state) => Scaffold(
          backgroundColor: kPrimaryColor,
          appBar: AppBar(
            backgroundColor: kPrimaryColor,
            title: const Text('ChronoQuest'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  context.read<AuthBloc>().add(const AuthEventLogout());
                },
              ),
            ],
          ),
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
                                itemCount: state.length,
                                itemBuilder: (context, index) {
                                  final Cycle cycle = state[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: ActivityTile(
                                      title: cycle.title,
                                      subtitle: cycle.note,
                                      icon: Icons.access_alarm,
                                      onTap: () {},
                                    ),
                                  );
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
        ),
      );
}

class BlurredWidget extends StatelessWidget {
  const BlurredWidget({
    required this.child,
    required this.isBlurring,
    super.key,
  });
  final Widget child;

  final bool isBlurring;

  @override
  Widget build(BuildContext context) => isBlurring
      ? ClipRRect(
          // borderRadius: BorderRadius.circular(10),
          child: Stack(
            children: [
              child,
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0),
                          spreadRadius: 5,
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
      : child;
}
