import 'package:chrono_quest/agenda/controllers/agenda_bloc.dart';
import 'package:chrono_quest/agenda/models/agenda_event.dart';
import 'package:chrono_quest/agenda/models/agenda_state.dart';
import 'package:chrono_quest/authentication/components/my_loading_indicator.dart';
import 'package:chrono_quest/router/router_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AgendaViewWrapper extends StatefulWidget {
  const AgendaViewWrapper({super.key});

  @override
  State<AgendaViewWrapper> createState() => _AgendaViewWrapperState();
}

class _AgendaViewWrapperState extends State<AgendaViewWrapper> {
  @override
  void initState() {
    super.initState();
    context.read<AgendaBloc>().add(const AgendaEventGetCycles());
  }

  @override
  Widget build(BuildContext context) => BlocListener<AgendaBloc, AgendaState>(
        listener: (context, state) {
          final currentPath = GoRouterState.of(context).uri.toString();
          if (currentPath != RouterPath.agenda.path) {
            return;
          }

          switch (state) {
            case AgendaStateNoCyclesLoaded():
              context.replaceNamed(RouterPath.agendaCycles.name);
            case AgendaStateCyclesLoaded():
              context.replaceNamed(RouterPath.agendaOverview.name);
            case AgendaStateError(:final String message):
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(message)));
            case _:
              break;
          }
        },
        child: const Scaffold(
          body: Center(
            child: MyLoadingIndicator(),
          ),
        ),
      );
}
