import 'dart:math';

import 'package:chrono_quest/agenda/components/agenda_timeline.dart';
import 'package:chrono_quest/agenda/components/chrono_bar.dart';
import 'package:chrono_quest/agenda/components/my_app_bar.dart';
import 'package:chrono_quest/agenda/controllers/agenda_bloc.dart';
import 'package:chrono_quest/agenda/controllers/timeline_cubit.dart';
import 'package:chrono_quest/agenda/models/agenda_state.dart';
import 'package:chrono_quest/common/constants/colors.dart';
import 'package:chrono_quest/common/constants/numbers.dart';
import 'package:chrono_quest/common/util/unfocus_on_tap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddCycleView extends StatefulWidget {
  const AddCycleView({super.key});

  @override
  State<AddCycleView> createState() => _AddCycleViewState();
}

class _AddCycleViewState extends State<AddCycleView>
    with TickerProviderStateMixin {
  OverlayEntry? overlayEntry;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showOverlay();
    });
  }

  void _showOverlay() {
    _createOverlayEntry();
    Overlay.of(context).insert(overlayEntry!);
  }

  void _createOverlayEntry() {
    final AgendaBloc agendaBloc = context.read<AgendaBloc>();
    final TimelineCubit timelineCubit = context.read<TimelineCubit>();

    overlayEntry = OverlayEntry(
      builder: (overlayContext) {
        final double bottomInset =
            MediaQuery.of(overlayContext).viewInsets.bottom;

        return MultiBlocProvider(
          providers: [
            BlocProvider<TimelineCubit>.value(
              value: timelineCubit,
            ),
            BlocProvider<AgendaBloc>.value(
              value: agendaBloc,
            ),
          ],
          child: Positioned(
            bottom: bottomInset > 0 ? max(bottomInset, 100) : 100,
            left: 0 + kPadding + 1,
            right: 0 + kPadding + 1,
            child: const ChronoBar(
              isOnAddCycleView: true,
            ),
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
  void dispose() {
    removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<AgendaBloc, AgendaState>(
        listener: (context, state) {},
        builder: (context, state) => Scaffold(
          backgroundColor: kPrimaryColor,
          appBar: const MyAppBar(),
          body: SafeArea(
            child: UnfocusOnTap(
              child: SingleChildScrollView(
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
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
