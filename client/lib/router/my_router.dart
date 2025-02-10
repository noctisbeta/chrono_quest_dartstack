// GoRouter configuration
import 'package:chrono_quest/agenda/views/add_cycle_view.dart';
import 'package:chrono_quest/agenda/views/agenda_view.dart';
import 'package:chrono_quest/agenda/views/agenda_view_wrapper.dart';
import 'package:chrono_quest/agenda/views/agenda_wrapper.dart';
import 'package:chrono_quest/agenda/views/cycles_overview.dart';
import 'package:chrono_quest/authentication/repositories/auth_repository.dart';
import 'package:chrono_quest/authentication/views/authentication_view.dart';
import 'package:chrono_quest/encryption/encryption_view.dart';
import 'package:chrono_quest/router/router_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class MyRouter extends StatefulWidget {
  const MyRouter({super.key});

  @override
  State<MyRouter> createState() => _MyRouterState();
}

class _MyRouterState extends State<MyRouter> {
  static final _authRoute = GoRoute(
    path: RouterPath.auth.path,
    name: RouterPath.auth.name,
    builder: (context, state) => const AuthenticationView(),
  );

  static final _encryptionRoute = GoRoute(
    path: RouterPath.encryption.path,
    name: RouterPath.encryption.name,
    builder: (context, state) => const EncryptionView(),
  );

  // This becomes a ShellRoute that wraps all agenda-related routes
  static final _agendaRoute = ShellRoute(
    builder: (context, state, child) => AgendaWrapper(child: child),
    routes: [
      GoRoute(
        path: RouterPath.agenda.path,
        name: RouterPath.agenda.name,
        builder: (context, state) => const AgendaViewWrapper(),
        routes: [
          GoRoute(
            path: RouterPath.agendaCycles.subPath,
            name: RouterPath.agendaCycles.name,
            builder: (context, state) => const CyclesOverview(),
          ),
          GoRoute(
            path: RouterPath.agendaAddCycle.subPath,
            name: RouterPath.agendaAddCycle.name,
            builder: (context, state) => const AddCycleView(),
          ),
          GoRoute(
            path: RouterPath.agendaOverview.subPath,
            name: RouterPath.agendaOverview.name,
            builder: (context, state) => const AgendaView(),
          ),
        ],
      ),
    ],
  );

  late final GoRouter _router = GoRouter(
    observers: [RouteObserver<ModalRoute<void>>()],
    debugLogDiagnostics: true,
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
    final bool isAuthenticated =
        await context.read<AuthRepository>().isAuthenticated();

    final bool isOnAuth = state.uri.toString() == RouterPath.auth.path;

    switch ((isAuthenticated, isOnAuth)) {
      case (true, true):
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
        debugShowCheckedModeBanner: false,
      );
}
