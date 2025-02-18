import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:server/auth/abstractions/auth_handler_interface.dart';
import 'package:test/test.dart';

import '../../../routes/api/v1/auth/login/index.dart' as route;

class _MockAuthHandler extends Mock implements IAuthHandler {}

class _MockRequestContext extends Mock implements RequestContext {}

void main() {
  late _MockRequestContext context;
  late _MockAuthHandler authHandler;
  const loginPath = '/api/v1/auth/login';

  setUp(() {
    context = _MockRequestContext();
    authHandler = _MockAuthHandler();
    when(() => context.read<IAuthHandler>()).thenReturn(authHandler);
  });

  group('Request method filtering', () {
    final Set<HttpMethod> allowedMethods = {HttpMethod.post};

    group('allowed methods', () {
      for (final method in allowedMethods) {
        test('${method.value} method returns 200 OK', () async {
          // Arrange
          when(
            () => context.request,
          ).thenReturn(Request(method.value, Uri.parse(loginPath)));
          when(
            () => authHandler.login(any()),
          ).thenAnswer((_) async => Response.json(body: {'status': 'success'}));

          // Act
          final Response response = await route.onRequest(context);

          // Assert
          expect(response.statusCode, equals(HttpStatus.ok));
        });
      }
    });

    group('disallowed methods', () {
      final Iterable<HttpMethod> disallowedMethods = HttpMethod.values.where(
        (method) => !allowedMethods.contains(method),
      );

      for (final method in disallowedMethods) {
        test('${method.value} method returns 405 Method Not Allowed', () async {
          // Arrange
          when(
            () => context.request,
          ).thenReturn(Request(method.value, Uri.parse(loginPath)));

          // Act
          final Response response = await route.onRequest(context);

          // Assert
          expect(response.statusCode, equals(HttpStatus.methodNotAllowed));
        });
      }
    });
  });
}
