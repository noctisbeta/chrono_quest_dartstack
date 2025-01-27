import 'dart:io';

import 'package:chrono_quest/dio_wrapper/dio_wrapper.dart';
import 'package:common/auth/jwtoken.dart';
import 'package:common/auth/login_error.dart';
import 'package:common/auth/login_request.dart';
import 'package:common/auth/login_response.dart';
import 'package:common/auth/register_error.dart';
import 'package:common/auth/register_request.dart';
import 'package:common/auth/register_response.dart';
import 'package:common/logger/logger.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart' show immutable;
import 'package:shared_preferences/shared_preferences.dart';

@immutable
final class AuthRepository {
  const AuthRepository({required this.dio});

  final DioWrapper dio;

  Future<void> _saveJWToken(JWToken token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool success = await prefs.setString('jwt_token', token.value);
    if (!success) {
      throw Exception('Failed to save JWT token');
    }
  }

  Future<JWToken?> _getJWToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final String? tokenString = prefs.getString('jwt_token');

    if (tokenString == null) {
      return null;
    }

    return JWToken.fromJwtString(tokenString);
  }

  Future<bool> isLoggedIn() async {
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
          LOG.e('Unknown Error registering user: $e');
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
