import 'dart:io';

import 'package:common/auth/tokens/jwtoken.dart';
import 'package:common/exceptions/request_exception.dart';
import 'package:common/exceptions/throws.dart';
import 'package:common/tasks/add_task_request.dart';
import 'package:common/tasks/add_task_response.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:meta/meta.dart';
import 'package:server/agenda/agenda_repository.dart';
import 'package:server/auth/jwtoken_helper.dart';
import 'package:server/postgres/exceptions/database_exception.dart';
import 'package:server/util/request_extension.dart';

@immutable
final class AgendaHandler {
  const AgendaHandler({
    required AgendaRepository agendaRepository,
  }) : _agendaRepository = agendaRepository;

  final AgendaRepository _agendaRepository;

  Future<Response> addTask(RequestContext context) async {
    try {
      @Throws([BadRequestContentTypeException])
      final Request request = context.request
        ..assertContentType(ContentType.json.mimeType);

      final String authorizationHeader =
          context.request.headers['authorization']!;

      final JWToken token =
          JWTokenHelper.getFromAuthorizationHeader(authorizationHeader);

      final int userId = token.getUserId();

      @Throws([FormatException])
      final Map<String, dynamic> json = await request.json();

      @Throws([BadRequestBodyException])
      final addTaskRequest = AddTaskRequest.validatedFromMap(json);

      @Throws([DatabaseException])
      final AddTaskResponseSuccess addTaskResponse =
          await _agendaRepository.addTask(addTaskRequest, userId);

      return Response.json(
        statusCode: HttpStatus.created,
        body: addTaskResponse.toMap(),
      );
    } on BadRequestContentTypeException catch (e) {
      return Response(
        statusCode: HttpStatus.badRequest,
        body: 'Invalid request! $e',
      );
    } on FormatException catch (e) {
      return Response(
        statusCode: HttpStatus.badRequest,
        body: 'Invalid request! $e',
      );
    } on BadRequestBodyException catch (e) {
      return Response(
        statusCode: HttpStatus.badRequest,
        body: 'Invalid request! $e',
      );
    } on DatabaseException catch (e) {
      switch (e) {
        case DBEuniqueViolation():
        case DBEunknown():
        case DBEbadCertificate():
        case DBEbadSchema():
        case DBEemptyResult():
          return Response(
            statusCode: HttpStatus.notFound,
            body: 'User does not exist! $e',
          );
      }
    }
  }
}
