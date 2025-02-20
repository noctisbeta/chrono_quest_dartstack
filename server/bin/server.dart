import 'dart:io';

import 'package:common/logger/logger.dart';
import 'package:dotenv/dotenv.dart';
import 'package:server/auth/security_middleware.dart';
import 'package:server/config/server_config.dart';
import 'package:server/postgres/implementations/migration_service.dart';
import 'package:server/postgres/implementations/postgres_service.dart';
import 'package:server/routes/routes.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

Future<void> _initDatabase() async {
  final PostgresService database = await PostgresService.create();
  final migrationService = MigrationService(postgresService: database);

  await migrationService.up();
}

Future<void> main() async {
  final dotenv = DotEnv()..load();
  final String environment = dotenv['DART_ENV'] ?? 'development';
  final ServerConfig config = _getConfig(environment);

  LOG.i('Starting server in ${config.environment} environment');

  // Initialize database and run migrations
  await _initDatabase();

  // Create router
  final Router router = await createRouter();

  // Create handler pipeline
  final Handler handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(securityMiddleware())
      .addHandler(router.call);

  // Start server with HTTPS
  try {
    HttpServer server;
    if (config.useHttps) {
      final security =
          SecurityContext()
            ..useCertificateChain(config.certPath)
            ..usePrivateKey(config.keyPath);

      server = await serve(
        handler,
        InternetAddress.anyIPv4,
        config.port,
        securityContext: security,
      );
    } else {
      server = await serve(handler, InternetAddress.anyIPv4, config.port);
    }

    LOG.i(
      'Server running on ${config.useHttps ? "https" : "http"}://${server.address.host}:${server.port}',
    );
  } catch (e, stack) {
    LOG.e('Failed to start server', error: e, stackTrace: stack);
    rethrow;
  }
}

ServerConfig _getConfig(String environment) {
  switch (environment) {
    case 'production':
      return ServerConfig.production();
    case 'staging':
      return ServerConfig.staging();
    default:
      return ServerConfig.development();
  }
}
