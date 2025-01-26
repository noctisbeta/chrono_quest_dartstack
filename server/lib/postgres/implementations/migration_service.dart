import 'package:common/logger/logger.dart';
import 'package:server/postgres/implementations/postgres_service.dart';
import 'package:server/postgres/models/migration.dart';

final _migrations = [
  const Migration(
    order: 1,
    up: '''
    CREATE TABLE IF NOT EXISTS users (
      id SERIAL PRIMARY KEY NOT NULL,
      username VARCHAR(50) NOT NULL,
      hashed_password VARCHAR(100) NOT NULL,
      salt VARCHAR(100) NOT NULL,
      created_at TIMESTAMP NOT NULL DEFAULT NOW(),
      updated_at TIMESTAMP NOT NULL DEFAULT NOW()
    );
    ''',
    down: '''
    DROP TABLE IF EXISTS users;
    ''',
  ),
]..sort((m, n) => m.order.compareTo(n.order));

final class MigrationService {
  MigrationService({
    required PostgresService db,
  }) : _db = db;

  final PostgresService _db;

  Future<void> up({int? count}) async {
    final int amount = count ?? _migrations.length;

    await _db.runTx((session) {
      final results = <Future>[];

      for (final Migration m in _migrations.take(amount)) {
        results.add(session.execute(m.up));
      }

      return Future.wait(results);
    });

    LOG.i('Migrations applied successfully');
  }

  Future<void> down({int? count}) async {
    final int amount = count ?? _migrations.length;

    await _db.runTx((session) {
      final results = <Future>[];

      for (final Migration m in _migrations.reversed.take(amount)) {
        results.add(session.execute(m.down));
      }

      return Future.wait(results);
    });

    LOG.i('Migrations reverted successfully');
  }
}
