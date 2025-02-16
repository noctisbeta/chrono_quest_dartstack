import 'dart:io';

import 'package:chrono_quest/dio_wrapper/jwt_interceptor.dart';
import 'package:common/logger/logger.dart';
import 'package:dio/browser.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

@immutable
final class DioWrapper {
  const DioWrapper._(this._dio);

  factory DioWrapper.unauthorized() {
    final dio = Dio(BaseOptions(baseUrl: 'https://localhost:8080/api/v1'))
      ..interceptors.add(LogInterceptor(requestBody: true, responseBody: true));

    if (kDebugMode) {
      if (kIsWeb) {
        // Web-specific configuration
        (dio.httpClientAdapter as BrowserHttpClientAdapter).withCredentials =
            true;
      } else {
        // Native platform configuration
        (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
          final client =
              HttpClient()..badCertificateCallback = (_, _, _) => true;
          return client;
        };
      }
    }

    return DioWrapper._(dio);
  }

  factory DioWrapper.authorized() {
    final dio = Dio(BaseOptions(baseUrl: 'https://localhost:8080/api/v1'))
      ..interceptors.add(
        JwtInterceptor(
          secureStorage: const FlutterSecureStorage(),
          unauthorizedDio: DioWrapper.unauthorized(),
        ),
      );

    if (kDebugMode) {
      if (kIsWeb) {
        // Web-specific configuration
        (dio.httpClientAdapter as BrowserHttpClientAdapter).withCredentials =
            true;
      } else {
        // Native platform configuration
        (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
          final client =
              HttpClient()..badCertificateCallback = (_, _, _) => true;
          return client;
        };
      }
    }

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

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final Response response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );

      return response;
    } on DioException catch (e) {
      LOG.e('Error getting data: $e');
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
    } on DioException catch (e) {
      LOG.e('Error posting data: $e');
      rethrow;
    }
  }
}
