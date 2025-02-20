import 'package:server/auth/abstractions/auth_repository_interface.dart';
import 'package:server/auth/auth_data_source.dart';
import 'package:server/auth/auth_handler.dart';
import 'package:server/auth/auth_repository.dart';
import 'package:server/auth/hasher.dart';
import 'package:server/postgres/implementations/postgres_service.dart';
import 'package:server/util/context_key.dart';
import 'package:server/util/request_extension.dart';
import 'package:shelf/shelf.dart';

AuthHandler? _authHandler;
Middleware authHandlerProvider() =>
    (Handler innerHandler) => (Request request) async {
      final IAuthRepository authRepository = request.getFromContext(
        ContextKey.authRepository,
      );

      _authHandler ??= AuthHandler(authRepository: authRepository);

      final Request newRequest = request.addToContext(
        ContextKey.authHandler,
        _authHandler,
      );

      return await innerHandler(newRequest);
    };

IAuthRepository? _authRepository;
Hasher? _hasher;
Middleware authRepositoryProvider() =>
    (Handler innerHandler) => (Request request) async {
      final AuthDataSource authDataSource = request.getFromContext(
        ContextKey.authDataSource,
      );

      _hasher ??= const Hasher();

      _authRepository ??= AuthRepository(
        authDataSource: authDataSource,
        hasher: _hasher!,
      );

      final Request newRequest = request.addToContext(
        ContextKey.authRepository,
        _authRepository,
      );

      return await innerHandler(newRequest);
    };

AuthDataSource? _authService;
Middleware authDataSourceProvider() =>
    (Handler innerHandler) => (Request request) async {
      final PostgresService postgresService = request.getFromContext(
        ContextKey.postgresService,
      );

      _authService ??= AuthDataSource(postgresService: postgresService);

      final Request newRequest = request.addToContext(
        ContextKey.authDataSource,
        _authService,
      );

      return await innerHandler(newRequest);
    };
