import 'dart:io';

import 'package:chrono_quest/dio_wrapper/dio_wrapper.dart';
import 'package:common/auth/login_error.dart';
import 'package:common/auth/login_request.dart';
import 'package:common/auth/login_response.dart';
import 'package:common/logger/logger.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart' show immutable;

@immutable
final class AgendaRepository {
  const AgendaRepository({required this.dio});

  final DioWrapper dio;

  Future<LoginResponse> addTask(LoginRequest loginRequest) async {
    try {
      final Response response = await dio.post(
        '/agenda/tasks',
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
          LOG.e('Unknown Error logging in user: $e');
          return const LoginResponseError(
            message: 'Error logging i user',
            error: LoginError.unknownLoginError,
          );
      }
    }
  }
}
