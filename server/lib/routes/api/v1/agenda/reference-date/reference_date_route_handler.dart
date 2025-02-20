import 'dart:io';

import 'package:server/agenda/agenda_handler.dart';
import 'package:server/util/context_key.dart';
import 'package:server/util/http_method.dart';
import 'package:server/util/request_extension.dart';
import 'package:shelf/shelf.dart';

Future<Response> referenceDateRouteHandler(Request request) async {
  final AgendaHandler agendaHandler = request.getFromContext(
    ContextKey.agendaHandler,
  );

  final method = HttpMethod.fromString(request.method);

  return switch (method) {
    HttpMethod.post => await agendaHandler.setReferenceDate(request),
    HttpMethod.get => await agendaHandler.getReferenceDate(request),
    _ => Response(HttpStatus.methodNotAllowed),
  };
}
