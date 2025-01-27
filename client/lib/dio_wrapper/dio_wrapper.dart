import 'package:dio/dio.dart';
import 'package:flutter/material.dart' show immutable;

@immutable
final class DioWrapper {
  DioWrapper()
      : _dio = Dio(
          BaseOptions(
            // baseUrl: 'http://localhost:8080/api/v1',
            baseUrl: 'http://192.168.0.26:8080/api/v1',
          ),
        );

  final Dio _dio;

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
