import 'dart:io';

import 'package:chrono_quest/dio_wrapper/dio_wrapper.dart';
import 'package:common/auth/login_error.dart';
import 'package:common/auth/login_request.dart';
import 'package:common/auth/login_response.dart';
import 'package:common/auth/register_error.dart';
import 'package:common/auth/register_request.dart';
import 'package:common/auth/register_response.dart';
import 'package:common/logger/logger.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart' show immutable;

@immutable
final class AuthRepository {
  const AuthRepository({required this.dio});

  final DioWrapper dio;

  Future<LoginResponse> login(LoginRequest loginRequest) async {
    try {
      final Response response = await dio.post(
        '/auth/login',
        data: loginRequest.toMap(),
      );

      final LoginResponseSuccess loginResponse =
          LoginResponseSuccess.validatedFromMap(response.data);

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
