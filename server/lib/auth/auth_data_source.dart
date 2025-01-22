import 'package:common/exceptions/propagates.dart';
import 'package:common/exceptions/throws.dart';
import 'package:postgres/postgres.dart';
import 'package:server/auth/user_db.dart';
import 'package:server/postgres/exceptions/database_exception.dart';
import 'package:server/postgres/implementations/postgres_service.dart';

final class AuthDataSource {
  AuthDataSource({
    required PostgresService postgresService,
  }) : _db = postgresService;

  final PostgresService _db;

  @Throws([DBEemptyResult, DBEbadSchema])
  @Propagates([DatabaseException])
  Future<UserDB> login(String username) async {
    @Throws([DatabaseException])
    final Result res = await _db.execute(
      Sql.named('SELECT * FROM users WHERE username = @username;'),
      parameters: {'username': username},
    );

    if (res.isEmpty) {
      throw const DBEemptyResult('No user found with that username.');
    }

    final Map<String, dynamic> resCol = res.first.toColumnMap();

    @Throws([DBEbadSchema])
    final userDB = UserDB.validatedFromMap(resCol);

    return userDB;
  }

  @Throws([DBEemptyResult, DBEbadSchema])
  @Propagates([DatabaseException])
  Future<UserDB> register(
    String username,
    String hashedPassword,
    String salt,
  ) async {
    @Throws([DatabaseException])
    final Result res = await _db.execute(
      Sql.named('''
        INSERT INTO users (username, hashed_password, salt)
        VALUES (@username, @hashedPassword, @salt) RETURNING *;
      '''),
      parameters: {
        'username': username,
        'hashedPassword': hashedPassword,
        'salt': salt,
      },
    );

    if (res.isEmpty) {
      throw const DBEemptyResult('Failed to insert user into database.');
    }

    final Map<String, dynamic> resCol = res.first.toColumnMap();

    @Throws([DBEbadSchema])
    final userDB = UserDB.validatedFromMap(resCol);

    return userDB;
  }

  @Propagates([DatabaseException])
  Future<bool> isUniqueUsername(String username) async {
    @Throws([DatabaseException])
    final Result res = await _db.execute(
      Sql.named('SELECT 1 FROM users WHERE username = @username;'),
      parameters: {'username': username},
    );

    return res.isEmpty;
  }
}
