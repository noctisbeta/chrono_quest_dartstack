// GoRouter configuration
import 'package:chrono_quest/agenda/views/add_cycle_view.dart';
import 'package:chrono_quest/agenda/views/agenda_view.dart';
import 'package:chrono_quest/agenda/views/agenda_view_wrapper.dart';
import 'package:chrono_quest/agenda/views/agenda_wrapper.dart';
import 'package:chrono_quest/agenda/views/cycles_overview.dart';
import 'package:chrono_quest/authentication/controllers/auth_bloc.dart';
import 'package:chrono_quest/authentication/models/auth_state.dart';
import 'package:chrono_quest/authentication/views/authentication_view.dart';
import 'package:chrono_quest/encryption/encryption_view.dart';
import 'package:chrono_quest/router/router_path.dart';
import 'package:common/logger/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class MyRouter extends StatefulWidget {
  const MyRouter({super.key});

  @override
  State<MyRouter> createState() => _MyRouterState();
}

class _MyRouterState extends State<MyRouter> {
  static final _encryptionRoute = GoRoute(
    path: RouterPath.encryption.path,
    name: RouterPath.encryption.name,
    builder: (context, state) => Builder(
      builder: (context) => const EncryptionView(),
    ),
  );

  static final _authRoute = GoRoute(
    path: RouterPath.auth.path,
    name: RouterPath.auth.name,
    builder: (context, state) => const AuthenticationView(),
  );

  static final _agendaRoute = GoRoute(
    path: RouterPath.agenda.path,
    name: RouterPath.agenda.name,
    builder: (context, state) => const AgendaWrapper(
      child: AgendaViewWrapper(),
    ),
    routes: [
      GoRoute(
        path: RouterPath.cycles.path,
        name: RouterPath.cycles.name,
        builder: (context, state) => const AgendaWrapper(
          child: CyclesOverview(),
        ),
      ),
      GoRoute(
        path: RouterPath.addCycle.path,
        name: RouterPath.addCycle.name,
        builder: (context, state) => const AgendaWrapper(
          child: AddCycleView(),
        ),
      ),
      GoRoute(
        path: RouterPath.overview.path,
        name: RouterPath.overview.name,
        builder: (context, state) => const AgendaWrapper(
          child: AgendaView(),
        ),
      ),
    ],
  );

  late final GoRouter _router = GoRouter(
    initialLocation: RouterPath.auth.path,
    routes: [
      _authRoute,
      _encryptionRoute,
      _agendaRoute,
    ],
    redirect: _redirect,
  );

  Future<String?>? _redirect(
    BuildContext context,
    GoRouterState state,
  ) async {
    final AuthState authState = context.read<AuthBloc>().state;
    final bool isAuthenticated = authState is AuthStateAuthenticated;

    final bool isOnAuth = state.uri.toString() == RouterPath.auth.path;

    switch ((isAuthenticated, isOnAuth)) {
      case (true, true):
        LOG.d('User is logged in, redirecting to /agenda');
        return RouterPath.agenda.path;
      case (false, false):
        return RouterPath.auth.path;
      case (true, false):
        return null;
      case (false, true):
        return null;
    }
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        routerConfig: _router,
        title: 'Chrono Quest',
      );
}
