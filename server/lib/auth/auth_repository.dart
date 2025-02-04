import 'dart:convert';
import 'dart:math';

import 'package:common/auth/login/login_error.dart';
import 'package:common/auth/login/login_request.dart';
import 'package:common/auth/login/login_response.dart';
import 'package:common/auth/register/register_error.dart';
import 'package:common/auth/register/register_request.dart';
import 'package:common/auth/register/register_response.dart';
import 'package:common/auth/tokens/jwtoken.dart';
import 'package:common/auth/tokens/refresh_error.dart';
import 'package:common/auth/tokens/refresh_token.dart';
import 'package:common/auth/tokens/refresh_token_request.dart';
import 'package:common/auth/tokens/refresh_token_response.dart';
import 'package:common/auth/tokens/refresh_token_wrapper.dart';
import 'package:common/auth/user.dart';
import 'package:common/exceptions/propagates.dart';
import 'package:common/exceptions/throws.dart';
import 'package:common/logger/logger.dart';
import 'package:server/auth/auth_data_source.dart';
import 'package:server/auth/hasher.dart';
import 'package:server/auth/jwtoken_helper.dart';
import 'package:server/auth/refresh_token_db.dart';
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

  RefreshToken _generateRefreshToken() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return RefreshToken.fromRefreshTokenString(base64Url.encode(bytes));
  }

  Future<RefreshTokenResponse> refreshToken(
    RefreshTokenRequest refreshTokenRequest,
  ) async {
    final RefreshTokenDB refreshTokenDB = await _authDataSource.getRefreshToken(
      refreshTokenRequest.refreshToken,
    );

    if (refreshTokenDB.expiresAt.isBefore(DateTime.now())) {
      await _authDataSource.deleteRefreshToken(
        refreshTokenRequest.refreshToken,
      );

      return const RefreshTokenResponseError(
        message: 'Refresh token expired',
        error: RefreshError.expired,
      );
    }

    final int userId = refreshTokenDB.userId;

    await _authDataSource.deleteRefreshToken(
      refreshTokenRequest.refreshToken,
    );

    final RefreshToken newRefreshToken = _generateRefreshToken();

    final RefreshTokenDB refreshTokenDb =
        await _authDataSource.storeRefreshToken(
      userId,
      newRefreshToken,
    );

    final JWToken newAccessToken = JWTokenHelper.createWith(
      userID: userId,
    );

    return RefreshTokenResponseSuccess(
      jwToken: newAccessToken,
      refreshToken: RefreshToken.fromRefreshTokenString(refreshTokenDb.token),
      refreshTokenExpiresAt: refreshTokenDb.expiresAt,
    );
  }

  Future<void> storeEncryptedSalt(String encryptedSalt, int userId) async {
    await _authDataSource.storeEncryptedSalt(encryptedSalt, userId);
  }

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

    final JWToken token = JWTokenHelper.createWith(
      userID: userDB.id,
    );

    final RefreshToken refreshToken = _generateRefreshToken();

    @Throws([DatabaseException])
    final RefreshTokenDB refreshTokenDB =
        await _authDataSource.storeRefreshToken(
      userDB.id,
      refreshToken,
    );

    final user = User(
      id: userDB.id,
      username: userDB.username,
    );

    final refreshTokenWrapper = RefreshTokenWrapper(
      refreshToken: refreshToken,
      refreshTokenExpiresAt: refreshTokenDB.expiresAt,
    );

    final response = LoginResponseSuccess(
      user: user,
      token: token,
      refreshTokenWrapper: refreshTokenWrapper,
    );

    return response;
  }

  @Propagates([DatabaseException])
  Future<RegisterResponse> register(
    RegisterRequest registerRequest,
  ) async {
    final bool isUsernameUnique = await _isUniqueUsername(
      registerRequest.username,
    );

    if (!isUsernameUnique) {
      return const RegisterResponseError(
        message: 'Username already exists!',
        error: RegisterError.usernameAlreadyExists,
      );
    }

    final ({String hashedPassword, String salt}) hashResult =
        await _hasher.hashPassword(registerRequest.password);

    @Throws([DatabaseException])
    final UserDB userDB = await _authDataSource.register(
      registerRequest.username,
      hashResult.hashedPassword,
      hashResult.salt,
    );

    final JWToken jwToken = JWTokenHelper.createWith(
      userID: userDB.id,
    );

    final RefreshToken refreshToken = _generateRefreshToken();

    @Throws([DatabaseException])
    final RefreshTokenDB refreshTokenDB =
        await _authDataSource.storeRefreshToken(
      userDB.id,
      refreshToken,
    );

    final user = User(
      id: userDB.id,
      username: userDB.username,
    );

    final refreshTokenWrapper = RefreshTokenWrapper(
      refreshToken: refreshToken,
      refreshTokenExpiresAt: refreshTokenDB.expiresAt,
    );

    final response = RegisterResponseSuccess(
      user: user,
      token: jwToken,
      refreshTokenWrapper: refreshTokenWrapper,
    );

    return response;
  }

  Future<bool> _isUniqueUsername(String username) async =>
      _authDataSource.isUniqueUsername(username);
}
