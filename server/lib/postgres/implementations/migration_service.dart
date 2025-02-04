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
  const Migration(
    order: 2,
    up: '''
    CREATE TABLE IF NOT EXISTS refresh_tokens (
      id SERIAL PRIMARY KEY,
      user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      token VARCHAR(255) NOT NULL UNIQUE,
      created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
      expires_at TIMESTAMP NOT NULL,
      ip_address VARCHAR(45),
      user_agent TEXT
    );
    ''',
    down: '''
    DROP TABLE IF EXISTS refresh_tokens;
    ''',
  ),
  const Migration(
    order: 3,
    up: '''
    CREATE TABLE IF NOT EXISTS tasks (
      id SERIAL PRIMARY KEY NOT NULL,
      user_id INT NOT NULL,
      start_time TIMESTAMP NOT NULL,
      end_time TIMESTAMP NOT NULL,
      note TEXT NOT NULL,
      title VARCHAR(100) NOT NULL,
      task_type VARCHAR(50) NOT NULL,
      created_at TIMESTAMP NOT NULL DEFAULT NOW(),
      updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
      FOREIGN KEY (user_id) REFERENCES users (id)
    );
    ''',
    down: '''
    DROP TABLE IF EXISTS tasks;
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
