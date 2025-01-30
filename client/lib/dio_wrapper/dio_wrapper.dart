import 'package:chrono_quest/dio_wrapper/jwt_interceptor.dart';
import 'package:common/logger/logger.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart' show immutable;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

@immutable
final class DioWrapper {
  const DioWrapper._(this._dio);

  factory DioWrapper.unauthorized() {
    final dio = Dio(
      BaseOptions(
        // baseUrl: 'http://localhost:8080/api/v1',
        baseUrl: 'http://192.168.0.26:8080/api/v1',
      ),
    )..interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
        ),
      );

    return DioWrapper._(dio);
  }

  factory DioWrapper.authorized() {
    final dio = Dio(
      BaseOptions(
        // baseUrl: 'http://localhost:8080/api/v1',
        baseUrl: 'http://192.168.0.26:8080/api/v1',
      ),
    )..interceptors.add(
        JwtInterceptor(
          secureStorage: const FlutterSecureStorage(),
          unauthorizedDio: DioWrapper.unauthorized(),
        ),
      );

    return DioWrapper._(dio);
  }

  final Dio _dio;

  Future<Response> request(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final Response response = await _dio.request(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return response;
    } on DioException catch (e) {
      LOG.e('Error making request: $e');
      rethrow;
    }
  }

  Future<Response> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final Response response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return response;
    } on DioException catch (_) {
      // LOG.e('Error posting data: $e');
      // throw Exception('Failed to post data: $e');
      rethrow;
    }
  }
}
