// GoRouter configuration
import 'package:chrono_quest/agenda/controllers/agenda_cubit.dart';
import 'package:chrono_quest/agenda/controllers/timeline_cubit.dart';
import 'package:chrono_quest/agenda/repositories/agenda_repository.dart';
import 'package:chrono_quest/agenda/views/agenda_view.dart';
import 'package:chrono_quest/authentication/repositories/auth_repository.dart';
import 'package:chrono_quest/authentication/views/authentication_view.dart';
import 'package:chrono_quest/dio_wrapper/dio_wrapper.dart';
import 'package:chrono_quest/encryption/encryption_repository.dart';
import 'package:chrono_quest/encryption/encryption_view.dart';
import 'package:chrono_quest/router/router_path.dart';
import 'package:common/logger/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

class MyRouter {
  MyRouter({
    required AuthRepository authRepository,
  }) : _authRepository = authRepository;

  final AuthRepository _authRepository;

  late final GoRouter _router = GoRouter(
    initialLocation: RouterPath.auth.path,
    routes: [
      _authRoute,
      _encryptionRoute,
      _agendaRoute,
    ],
    redirect: _redirect,
  );

  GoRouter get router => _router;

  Future<String?>? _redirect(
    BuildContext context,
    GoRouterState state,
  ) async {
    final bool isAuthenticated = await _authRepository.isAuthenticated();

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

  static final _encryptionRoute = GoRoute(
    path: RouterPath.encryption.path,
    name: RouterPath.encryption.name,
    builder: (context, state) => MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => DioWrapper.authorized(),
        ),
        RepositoryProvider(
          create: (context) => const FlutterSecureStorage(),
        ),
        RepositoryProvider(
          create: (context) => EncryptionRepository(
            storage: context.read<FlutterSecureStorage>(),
            authorizedDio: context.read<DioWrapper>(),
          ),
        ),
      ],
      child: Builder(
        builder: (context) => const EncryptionView(),
      ),
    ),
  );

  static final _authRoute = GoRoute(
    path: RouterPath.auth.path,
    name: RouterPath.auth.name,
    builder: (context, state) => const AuthenticationView(),
  );

  static final _agendaRoute = GoRoute(
    path: RouterPath.agenda.path,
    builder: (context, state) => MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => DioWrapper.authorized(),
        ),
        RepositoryProvider(
          create: (context) => const FlutterSecureStorage(),
        ),
        RepositoryProvider(
          create: (context) => EncryptionRepository(
            storage: context.read<FlutterSecureStorage>(),
            authorizedDio: context.read<DioWrapper>(),
          ),
        ),
        RepositoryProvider(
          create: (context) => AgendaRepository(
            authorizedDio: context.read<DioWrapper>(),
            encryptionRepository: context.read<EncryptionRepository>(),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AgendaCubit(
              agendaRepository: context.read<AgendaRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => TimelineCubit(
              agendaBloc: context.read<AgendaCubit>(),
            ),
          ),
        ],
        child: const AgendaView(),
      ),
    ),
  );
}
