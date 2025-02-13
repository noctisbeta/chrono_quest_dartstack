import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:server/postgres/implementations/migration_service.dart';
import 'package:server/postgres/implementations/postgres_service.dart';

Future<void> init(InternetAddress ip, int port) async {
  final PostgresService database = await PostgresService.create();
  final migrationService = MigrationService(db: database);

  await migrationService.up();
}

Future<HttpServer> run(Handler handler, InternetAddress ip, int port) =>
    serve(handler, ip, port);
