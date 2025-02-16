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
  }) : _authDataSource = authDataSource,
       _hasher = hasher;

  final AuthDataSource _authDataSource;

  final Hasher _hasher;

  Future<RefreshTokenResponse> refreshToken(
    RefreshTokenRequest refreshTokenRequest,
  ) async {
    final RefreshTokenDB refreshTokenDB = await _authDataSource.getRefreshToken(
      refreshTokenRequest.refreshToken,
    );

    final DateTime nowUtc = DateTime.now().toUtc();

    if (refreshTokenDB.expiresAt.toUtc().isBefore(nowUtc)) {
      await _authDataSource.deleteRefreshToken(
        refreshTokenRequest.refreshToken,
      );

      return const RefreshTokenResponseError(
        message: 'Refresh token expired',
        error: RefreshError.expired,
      );
    }

    final int userId = refreshTokenDB.userId;

    await _authDataSource.deleteRefreshToken(refreshTokenRequest.refreshToken);

    final RefreshTokenDB refreshTokenDb = await _authDataSource
        .storeRefreshToken(userId);

    final JWToken newAccessToken = JWTokenHelper.createWith(userID: userId);

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

    final bool isValid = await _hasher.verifyPassword(
      loginRequest.password,
      userDB.hashedPassword,
      userDB.salt,
    );

    if (!isValid) {
      return const LoginResponseError(
        message: 'Invalid password!',
        error: LoginError.wrongPassword,
      );
    }

    final JWToken token = JWTokenHelper.createWith(userID: userDB.id);

    @Throws([DatabaseException])
    final RefreshTokenDB refreshTokenDB = await _authDataSource
        .storeRefreshToken(userDB.id);

    final refreshToken = RefreshToken.fromRefreshTokenString(
      refreshTokenDB.token,
    );

    final DateTime expiresAt = refreshTokenDB.expiresAt;

    final user = User(
      username: userDB.username,
      token: token,
      refreshTokenWrapper: RefreshTokenWrapper(
        refreshToken: refreshToken,
        refreshTokenExpiresAt: expiresAt,
      ),
    );

    final response = LoginResponseSuccess(user: user);

    return response;
  }

  @Propagates([DatabaseException])
  Future<RegisterResponse> register(RegisterRequest registerRequest) async {
    final bool isUsernameUnique = await _isUniqueUsername(
      registerRequest.username,
    );

    if (!isUsernameUnique) {
      return const RegisterResponseError(
        message: 'Username already exists!',
        error: RegisterError.usernameAlreadyExists,
      );
    }

    final ({String hashedPassword, String salt}) hashResult = await _hasher
        .hashPassword(registerRequest.password);

    @Throws([DatabaseException])
    final UserDB userDB = await _authDataSource.register(
      registerRequest.username,
      hashResult.hashedPassword,
      hashResult.salt,
    );

    final JWToken jwToken = JWTokenHelper.createWith(userID: userDB.id);

    @Throws([DatabaseException])
    final RefreshTokenDB refreshTokenDB = await _authDataSource
        .storeRefreshToken(userDB.id);

    final refreshToken = RefreshToken.fromRefreshTokenString(
      refreshTokenDB.token,
    );

    final DateTime expiresAt = refreshTokenDB.expiresAt;

    final user = User(
      username: userDB.username,
      token: jwToken,
      refreshTokenWrapper: RefreshTokenWrapper(
        refreshToken: refreshToken,
        refreshTokenExpiresAt: expiresAt,
      ),
    );

    final response = RegisterResponseSuccess(user: user);

    return response;
  }

  Future<bool> _isUniqueUsername(String username) =>
      _authDataSource.isUniqueUsername(username);

  Future<String> getEncryptedSalt(int userId) =>
      _authDataSource.getEncryptedSalt(userId);
}
