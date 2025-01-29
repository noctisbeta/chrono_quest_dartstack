// GoRouter configuration
import 'package:chrono_quest/agenda/views/agenda_view.dart';
import 'package:chrono_quest/authentication/controllers/auth_bloc.dart';
import 'package:chrono_quest/authentication/repositories/auth_repository.dart';
import 'package:chrono_quest/authentication/views/authentication_view.dart';
import 'package:chrono_quest/dio_wrapper/dio_wrapper.dart';
import 'package:chrono_quest/router/router_path.dart';
import 'package:common/logger/logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class MyRouter {
  MyRouter({
    required AuthRepository authRepository,
  }) : _authRepository = authRepository;

  final AuthRepository _authRepository;

  late final GoRouter _router = GoRouter(
    initialLocation: RouterPath.auth.path,
    routes: [
      ...authRoutes,
      GoRoute(
        path: RouterPath.agenda.path,
        builder: (context, state) => const AgendaView(),
      ),
    ],
    redirect: (context, state) async {
      LOG.d('Redirecting to ${state.uri}');
      final bool isLoggedIn = await _authRepository.isAuthenticated();
      final bool isOnAuth = state.uri.toString() == RouterPath.auth.path;

      switch ((isLoggedIn, isOnAuth)) {
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
    },
  );

  GoRouter get router => _router;

  static final authRoutes = [
    GoRoute(
      path: RouterPath.auth.path,
      builder: (context, state) => MultiRepositoryProvider(
        providers: [
          RepositoryProvider(
            create: (context) => DioWrapper.unauthorized(),
          ),
          RepositoryProvider(
            create: (context) => AuthRepository(
              dio: context.read<DioWrapper>(),
            ),
          ),
        ],
        child: BlocProvider(
          create: (context) => AuthBloc(
            authRepository: context.read<AuthRepository>(),
          ),
          child: const AuthenticationView(),
        ),
      ),
    ),
  ];
}
