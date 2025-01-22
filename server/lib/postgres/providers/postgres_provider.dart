import 'package:dart_frog/dart_frog.dart';
import 'package:server/postgres/implementations/postgres_service.dart';

PostgresService? _database;

Middleware postgresProvider() => provider<Future<PostgresService>>(
      (_) async => _database ??= await PostgresService.create(),
    );
