import 'dart:io';

import 'package:common/auth/tokens/jwtoken.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:server/auth/jwtoken_helper.dart';

Middleware jwtMiddlewareProvider() =>
    (Handler handler) => (context) async {
      final String? authorizationHeader =
          context.request.headers['authorization'];

      if (authorizationHeader == null ||
          !authorizationHeader.startsWith('Bearer ')) {
        return Response(
          statusCode: HttpStatus.unauthorized,
          body: 'Unauthorized',
        );
      }

      final JWToken token = JWTokenHelper.getFromAuthorizationHeader(
        authorizationHeader,
      );

      if (token.isExpired()) {
        return Response(
          statusCode: HttpStatus.unauthorized,
          body: 'Token expired',
        );
      }

      try {
        final bool isVerified = JWTokenHelper.verifyToken(token);

        if (!isVerified) {
          return Response(
            statusCode: HttpStatus.unauthorized,
            body: 'Invalid token',
          );
        }

        final int userId = token.getUserId();

        context = context.provide<int>(() => userId);

        return await handler(context);
      } on Exception catch (e) {
        return Response(
          statusCode: HttpStatus.unauthorized,
          body: 'Invalid token: $e',
        );
      }
    };
