import 'dart:io';

import 'package:common/logger/logger.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:server/postgres/implementations/migration_service.dart';
import 'package:server/postgres/implementations/postgres_service.dart';

Future<void> init(InternetAddress ip, int port) async {
  final PostgresService database = await PostgresService.create();
  final migrationService = MigrationService(db: database);

  await migrationService.up();
}

Future<HttpServer> run(Handler handler, InternetAddress ip, int port) async {
  try {
    final security =
        SecurityContext()
          ..useCertificateChain('certificates/cert.pem')
          ..usePrivateKey('certificates/key.pem');

    return await serve(handler, ip, port, securityContext: security);
  } catch (e, stack) {
    LOG.e('Failed to start server', error: e, stackTrace: stack);
    rethrow;
  }
}
