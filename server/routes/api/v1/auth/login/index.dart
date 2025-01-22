import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:server/auth/auth_handler.dart';

Future<Response> onRequest(RequestContext context) async {
  final AuthHandler authHandler = await context.read<Future<AuthHandler>>();

  return switch (context.request.method) {
    HttpMethod.post => await authHandler.login(context),
    _ => Response(statusCode: HttpStatus.methodNotAllowed),
  };
}
