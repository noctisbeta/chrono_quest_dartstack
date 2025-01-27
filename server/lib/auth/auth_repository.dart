import 'package:common/auth/jwtoken.dart';
import 'package:common/auth/login_error.dart';
import 'package:common/auth/login_request.dart';
import 'package:common/auth/login_response.dart';
import 'package:common/auth/register_request.dart';
import 'package:common/auth/register_response.dart';
import 'package:common/auth/user.dart';
import 'package:common/exceptions/propagates.dart';
import 'package:common/exceptions/throws.dart';
import 'package:common/logger/logger.dart';
import 'package:server/auth/auth_data_source.dart';
import 'package:server/auth/hasher.dart';
import 'package:server/auth/user_db.dart';
import 'package:server/postgres/exceptions/database_exception.dart';

final class AuthRepository {
  AuthRepository({
    required AuthDataSource authDataSource,
    required Hasher hasher,
  })  : _authDataSource = authDataSource,
        _hasher = hasher;

  final AuthDataSource _authDataSource;

  final Hasher _hasher;

  @Propagates([DatabaseException])
  Future<LoginResponse> login(LoginRequest loginRequest) async {
    @Throws([DatabaseException])
    final UserDB userDB = await _authDataSource.login(loginRequest.username);

    LOG.d('UserDB: $userDB');
    final bool isValid = await _hasher.verifyPassword(
      loginRequest.password,
      userDB.hashedPassword,
      userDB.salt,
    );

    if (!isValid) {
      LOG.d('Invalid password!');
      return const LoginResponseError(
        message: 'Invalid password!',
        error: LoginError.wrongPassword,
      );
    }

    final token = JWToken.createWith(
      userID: userDB.id,
    );

    final user = User(
      id: userDB.id,
      username: userDB.username,
    );

    final response = LoginResponseSuccess(
      user: user,
      token: token,
    );

    return response;
  }

  @Propagates([DatabaseException])
  Future<RegisterResponseSuccess> register(
    RegisterRequest registerRequest,
  ) async {
    final ({String hashedPassword, String salt}) hashResult =
        await _hasher.hashPassword(registerRequest.password);

    @Throws([DatabaseException])
    final UserDB userDB = await _authDataSource.register(
      registerRequest.username,
      hashResult.hashedPassword,
      hashResult.salt,
    );

    final token = JWToken.createWith(
      userID: userDB.id,
    );

    final user = User(
      id: userDB.id,
      username: userDB.username,
    );

    final response = RegisterResponseSuccess(
      user: user,
      token: token,
    );

    return response;
  }

  Future<bool> isUnique(String username) async =>
      _authDataSource.isUniqueUsername(username);
}
