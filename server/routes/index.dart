import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  return Response.json(
    body: {
      'name': 'ChronoQuest API',
      'version': '1.0.0',
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    },
  );
}
