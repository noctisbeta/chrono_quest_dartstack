import 'package:chrono_quest/dio_wrapper/dio_wrapper.dart';
import 'package:common/auth/login_request.dart';
import 'package:common/auth/register_request.dart';
import 'package:common/auth/register_response.dart';
import 'package:common/logger/logger.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart' show immutable;

@immutable
final class AuthRepository {
  const AuthRepository({required this.dio});

  final DioWrapper dio;

  Future<void> login(String username, String password) async {
    final LoginRequest loginRequest = LoginRequest(
      username: username,
      password: password,
    );

    try {
      final Response response = await dio.post(
        '/auth/login',
        data: loginRequest.toMap(),
      );

      LOG.i('User logged in: $response');
    } on DioException catch (e) {
      LOG.e('Error logging in user: $e');
    }
  }

  Future<RegisterResponse?> register(RegisterRequest registerRequest) async {
    try {
      final Response response = await dio.post(
        '/auth/register',
        data: registerRequest.toMap(),
      );

      LOG.i('User registered: $response');

      final RegisterResponse registerResponse =
          RegisterResponse.validatedFromMap(response.data);

      return registerResponse;
    } on DioException catch (e) {
      LOG.e('Error registering user: $e');
      return null;
    }
  }
}
