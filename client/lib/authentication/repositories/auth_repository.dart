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
import 'package:common/auth/tokens/refresh_token_request.dart';
import 'package:common/auth/tokens/refresh_token_response.dart';
import 'package:common/logger/logger.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart' show immutable;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

@immutable
final class AuthRepository {
  const AuthRepository({required DioWrapper dio}) : _dio = dio;

  final DioWrapper _dio;

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

  Future<JWToken?> _refreshJWToken() async {
    const storage = FlutterSecureStorage();

    final String? refreshTokenString = await storage.read(key: 'refresh_token');

    if (refreshTokenString == null) {
      throw Exception('Refresh token not found in secure storage');
    }

    try {
      final RefreshToken refreshToken =
          RefreshToken.fromRefreshTokenString(refreshTokenString);

      final RefreshTokenRequest refreshTokenRequest = RefreshTokenRequest(
        refreshToken: refreshToken,
      );

      final Response response = await _dio.post(
        '/auth/refresh',
        data: refreshTokenRequest.toMap(),
      );

      final RefreshTokenResponseSuccess refreshTokenResponseSuccess =
          RefreshTokenResponseSuccess.validatedFromMap(response.data);

      final RefreshToken newRefreshToken =
          refreshTokenResponseSuccess.refreshToken;
      final DateTime newRefreshTokenExpiresAt =
          refreshTokenResponseSuccess.refreshTokenExpiresAt;
      final JWToken newJwToken = refreshTokenResponseSuccess.jwToken;

      await storage.write(
        key: 'refresh_token',
        value: newRefreshToken.value,
      );

      await storage.write(
        key: 'refresh_token_expires_at',
        value: newRefreshTokenExpiresAt.toIso8601String(),
      );

      await _saveJWToken(newJwToken);

      return newJwToken;
    } on DioException catch (e) {
      LOG.e('Error refreshing token: $e');
      return null;
    }
  }

  Future<bool> isAuthenticated() async {
    final JWToken? token = await _getJWToken();

    if (token == null) {
      return false;
    }

    final bool isValid = token.isValid();

    switch (isValid) {
      case false:
        final JWToken? newJwToken = await _refreshJWToken();
        return newJwToken != null;
      case true:
        return true;
    }
  }

  Future<void> logout() async {
    const storage = FlutterSecureStorage();

    await storage.delete(key: 'jwt_token');
    await storage.delete(key: 'refresh_token');
    await storage.delete(key: 'refresh_token_expires_at');
  }

  Future<LoginResponse> login(LoginRequest loginRequest) async {
    try {
      final Response response = await _dio.post(
        '/auth/login',
        data: loginRequest.toMap(),
      );

      final LoginResponseSuccess loginResponse =
          LoginResponseSuccess.validatedFromMap(response.data);

      await _saveJWToken(loginResponse.user.token);

      await _saveRefreshToken(
        loginResponse.user.refreshTokenWrapper.refreshToken,
        loginResponse.user.refreshTokenWrapper.refreshTokenExpiresAt,
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
      final Response response = await _dio.post(
        '/auth/register',
        data: registerRequest.toMap(),
      );

      final RegisterResponseSuccess registerResponse =
          RegisterResponseSuccess.validatedFromMap(response.data);

      await _saveJWToken(registerResponse.user.token);
      await _saveRefreshToken(
        registerResponse.user.refreshTokenWrapper.refreshToken,
        registerResponse.user.refreshTokenWrapper.refreshTokenExpiresAt,
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
