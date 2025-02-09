import 'package:chrono_quest/agenda/controllers/agenda_bloc.dart';
import 'package:chrono_quest/agenda/models/agenda_state.dart';
import 'package:chrono_quest/agenda/views/agenda_view.dart';
import 'package:chrono_quest/agenda/views/cycles_overview.dart';
import 'package:chrono_quest/authentication/components/my_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AgendaViewWrapper extends StatelessWidget {
  const AgendaViewWrapper({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<AgendaBloc, AgendaState>(
        builder: (context, state) => Scaffold(
          body: switch (state) {
            AgendaStateLoading() => const Center(
                child: MyLoadingIndicator(),
              ),
            AgendaStateCyclesLoaded() => const AgendaView(),
            AgendaStateNoCyclesLoaded() => const CyclesOverview(),
            AgendaStateError() => const Center(
                child: Text('Error loading cycles'),
              ),
          },
        ),
      );
}
