import 'package:dart_frog/dart_frog.dart';
import 'package:server/postgres/implementations/migration_service.dart';
import 'package:server/postgres/implementations/postgres_service.dart';

MigrationService? _migrationService;

Middleware migrationProvider() => provider<Future<MigrationService>>(
  (ctx) async =>
      _migrationService ??= MigrationService(
        db: await ctx.read<Future<PostgresService>>(),
      ),
);
