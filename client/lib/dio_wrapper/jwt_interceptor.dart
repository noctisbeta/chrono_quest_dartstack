import 'package:common/auth/tokens/jwtoken.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class JwtInterceptor extends Interceptor {
  JwtInterceptor({
    required this.dio,
    required this.storage,
  });

  final Dio dio;
  final FlutterSecureStorage storage;

  Future<String> _refreshToken() async {
    final String? refreshToken = await storage.read(key: 'refresh_token');

    if (refreshToken == null) {}
    final String? accessTokenExpiresAtString =
        await storage.read(key: 'access_token_expires_at');

    final Response response = await dio.post(
      '/auth/refresh',
      data: {
        'refresh_token': refreshToken,
      },
    );
    final String newToken =
        (response.data as Map<String, dynamic>)['access_token'];
    await storage.write(key: 'jwt_token', value: newToken);
    return newToken;
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final String? jwTokenString = await storage.read(key: 'jwt_token');

    if (jwTokenString == null) {
      return handler.next(options);
    }

    final JWToken token = JWToken.fromJwtString(jwTokenString);

    if (token.isExpired()) {
      try {
        final String newToken = await _refreshToken();
        options.headers['Authorization'] = 'Bearer $newToken';
      } on Dio catch (e) {
        return handler.reject(
          DioException(
            requestOptions: options,
            error: 'Token refresh failed $e',
          ),
        );
      }
    } else {
      options.headers['Authorization'] = 'Bearer $jwTokenString';
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      try {
        final String newToken = await _refreshToken();
        final RequestOptions requestOptions = err.requestOptions;
        requestOptions.headers['Authorization'] = 'Bearer $newToken';
        final Response response = await dio.request(
          requestOptions.path,
          options: Options(
            method: requestOptions.method,
            headers: requestOptions.headers,
          ),
          data: requestOptions.data,
          queryParameters: requestOptions.queryParameters,
        );
        return handler.resolve(response);
      } on DioException catch (e) {
        return handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            error: 'Token refresh failed $e',
          ),
        );
      }
    }
    return handler.next(err);
  }

  Future<void> _addTokenIfNeeded(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.headers.containsKey('Authorization')) {
      return handler.next(options);
    }

    final String? tokenString = await storage.read(key: 'jwt_token');

    if (tokenString == null) {
      return handler.next(options);
    }

    final JWToken token = JWToken.fromJwtString(tokenString);

    options.headers['Authorization'] = 'Bearer $token';

    handler.next(options);
  }
}
