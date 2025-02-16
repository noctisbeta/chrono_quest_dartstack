import 'package:dart_frog/dart_frog.dart';
import 'package:server/health/services/health_service.dart';
import 'package:server/postgres/implementations/postgres_service.dart';

HealthService? _healthService;

Middleware healthServiceProvider() => provider<Future<HealthService>>(
  (ctx) async =>
      _healthService ??= HealthService(
        database: await ctx.read<Future<PostgresService>>(),
      ),
);
