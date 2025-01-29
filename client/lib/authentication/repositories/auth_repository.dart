import 'dart:io';

import 'package:chrono_quest/dio_wrapper/dio_wrapper.dart';
import 'package:common/auth/login/login_error.dart';
import 'package:common/auth/login/login_request.dart';
import 'package:common/auth/login/login_response.dart';
import 'package:common/auth/register/register_error.dart';
import 'package:common/auth/register/register_request.dart';
import 'package:common/auth/register/register_response.dart';
import 'package:common/auth/tokens/jwtoken.dart';
import 'package:common/auth/tokens/refresh_token.dart';
import 'package:common/logger/logger.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart' show immutable;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

@immutable
final class AuthRepository {
  const AuthRepository({required this.dio});

  final DioWrapper dio;

  Future<void> _saveJWToken(JWToken token) async {
    const storage = FlutterSecureStorage();
    await storage.write(
      key: 'jwt_token',
      value: token.value,
    );
  }

  Future<JWToken?> _getJWToken() async {
    const storage = FlutterSecureStorage();

    final String? tokenString = await storage.read(key: 'jwt_token');

    if (tokenString == null) {
      return null;
    }

    return JWToken.fromJwtString(tokenString);
  }

  Future<void> _saveRefreshToken(
    RefreshToken refreshToken,
    DateTime refreshTokenExpiresAt,
  ) async {
    const storage = FlutterSecureStorage();

    await storage.write(
      key: 'refresh_token',
      value: refreshToken.value,
    );

    await storage.write(
      key: 'refresh_token_expires_at',
      value: refreshTokenExpiresAt.toIso8601String(),
    );
  }

  Future<bool> isAuthenticated() async {
    final JWToken? token = await _getJWToken();

    LOG.d('Token: $token');

    if (token == null) {
      return false;
    }

    final bool isValid = token.isValid();

    LOG.d('Token is valid: $isValid');

    return isValid;
  }

  Future<LoginResponse> login(LoginRequest loginRequest) async {
    try {
      final Response response = await dio.post(
        '/auth/login',
        data: loginRequest.toMap(),
      );

      final LoginResponseSuccess loginResponse =
          LoginResponseSuccess.validatedFromMap(response.data);

      await _saveJWToken(loginResponse.token);

      await _saveRefreshToken(
        loginResponse.refreshTokenWrapper.refreshToken,
        loginResponse.refreshTokenWrapper.refreshTokenExpiresAt,
      );

      return loginResponse;
    } on DioException catch (e) {
      LOG.e('Error logging in user: $e');
      switch (e.response?.statusCode) {
        case HttpStatus.unauthorized:
          return LoginResponseError.validatedFromMap(
            e.response?.data,
          );

        case HttpStatus.notFound:
          return const LoginResponseError(
            message: 'User not found',
            error: LoginError.userNotFound,
          );

        default:
          LOG.e('Unknown Error logging in user: $e');
          return const LoginResponseError(
            message: 'Error logging i user',
            error: LoginError.unknownLoginError,
          );
      }
    }
  }

  Future<RegisterResponse> register(
    RegisterRequest registerRequest,
  ) async {
    try {
      final Response response = await dio.post(
        '/auth/register',
        data: registerRequest.toMap(),
      );

      final RegisterResponseSuccess registerResponse =
          RegisterResponseSuccess.validatedFromMap(response.data);

      await _saveJWToken(registerResponse.token);
      await _saveRefreshToken(
        registerResponse.refreshTokenWrapper.refreshToken,
        registerResponse.refreshTokenWrapper.refreshTokenExpiresAt,
      );

      return registerResponse;
    } on DioException catch (e) {
      switch (e.response?.statusCode) {
        case HttpStatus.conflict:
          return RegisterResponseError.validatedFromMap(
            e.response?.data,
          );

        default:
          LOG.e('Unknown Error registering user: $e');
          return const RegisterResponseError(
            message: 'Error registering user',
            error: RegisterError.unknownRegisterError,
          );
      }
    }
  }
}
