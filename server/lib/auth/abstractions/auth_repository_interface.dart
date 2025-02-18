import 'package:common/auth/login/login_request.dart';
import 'package:common/auth/login/login_response.dart';
import 'package:common/auth/register/register_request.dart';
import 'package:common/auth/register/register_response.dart';
import 'package:common/auth/tokens/refresh_token_request.dart';
import 'package:common/auth/tokens/refresh_token_response.dart';

abstract interface class IAuthRepository {
  Future<RefreshTokenResponse> refreshToken(
    RefreshTokenRequest refreshTokenRequest,
  );

  Future<void> storeEncryptedSalt(String encryptedSalt, int userId);

  Future<String> getEncryptedSalt(int userId);

  Future<LoginResponse> login(LoginRequest loginRequest);

  Future<RegisterResponse> register(RegisterRequest registerRequest);
}
