import 'package:dart_frog/dart_frog.dart';
import 'package:server/auth/auth_data_source.dart';
import 'package:server/auth/auth_handler.dart';
import 'package:server/auth/auth_repository.dart';
import 'package:server/auth/hasher.dart';
import 'package:server/postgres/implementations/postgres_service.dart';

AuthHandler? _authHandler;
Middleware authHandlerProvider() => provider<Future<AuthHandler>>(
      (ctx) async => _authHandler ??= AuthHandler(
        authRepository: await ctx.read<Future<AuthRepository>>(),
      ),
    );

AuthRepository? _authRepository;
Hasher? _hasher;
Middleware authRepositoryProvider() => provider<Future<AuthRepository>>(
      (ctx) async => _authRepository ??= AuthRepository(
        authDataSource: await ctx.read<Future<AuthDataSource>>(),
        hasher: _hasher ??= Hasher(),
      ),
    );

AuthDataSource? _authService;
Middleware authServiceProvider() => provider<Future<AuthDataSource>>(
      (ctx) async => _authService ??= AuthDataSource(
        postgresService: await ctx.read<Future<PostgresService>>(),
      ),
    );
