import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:server/agenda/agenda_handler.dart';

Future<Response> onRequest(RequestContext context) async {
  final AgendaHandler agendaHandler =
      await context.read<Future<AgendaHandler>>();

  return switch (context.request.method) {
    HttpMethod.post => await agendaHandler.setReferenceDate(context),
    HttpMethod.get => await agendaHandler.getReferenceDate(context),
    _ => Response(statusCode: HttpStatus.methodNotAllowed),
  };
}
