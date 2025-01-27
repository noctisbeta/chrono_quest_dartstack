// GoRouter configuration
import 'package:chrono_quest/agenda/views/agenda_view.dart';
import 'package:chrono_quest/authentication/repositories/auth_repository.dart';
import 'package:chrono_quest/authentication/views/authentication_view.dart';
import 'package:common/logger/logger.dart';
import 'package:go_router/go_router.dart';

class MyRouter {
  MyRouter({
    required AuthRepository authRepository,
  }) : _authRepository = authRepository;

  final AuthRepository _authRepository;

  late final GoRouter _router = GoRouter(
    initialLocation: '/auth',
    routes: [
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthenticationView(),
      ),
      GoRoute(
        path: '/agenda',
        builder: (context, state) => const AgendaView(),
      ),
    ],
    redirect: (context, state) async {
      LOG.d('Redirecting to ${state.uri}');
      final bool isLoggedIn = await _authRepository.isAuthenticated();
      final bool isOnAuth = state.uri.toString() == '/auth';

      switch ((isLoggedIn, isOnAuth)) {
        case (true, true):
          LOG.d('User is logged in, redirecting to /agenda');
          return '/agenda';
        case (false, false):
          return '/auth';
        case (true, false):
          return null;
        case (false, true):
          return null;
      }
    },
  );

  GoRouter get router => _router;
}
