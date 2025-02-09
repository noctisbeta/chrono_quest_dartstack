import 'dart:io';

import 'package:common/agenda/add_cycle_request.dart';
import 'package:common/agenda/add_cycle_response.dart';
import 'package:common/agenda/encrypted_add_cycle_request.dart';
import 'package:common/agenda/encrypted_add_cycle_response.dart';
import 'package:common/agenda/encrypted_get_cycles_response.dart';
import 'package:common/agenda/get_cycles_request.dart';
import 'package:common/agenda/get_cycles_response.dart';
import 'package:common/exceptions/request_exception.dart';
import 'package:common/exceptions/throws.dart';
import 'package:common/logger/logger.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:meta/meta.dart';
import 'package:server/agenda/agenda_repository.dart';
import 'package:server/postgres/exceptions/database_exception.dart';
import 'package:server/util/request_extension.dart';

@immutable
final class AgendaHandler {
  const AgendaHandler({
    required AgendaRepository agendaRepository,
  }) : _agendaRepository = agendaRepository;

  final AgendaRepository _agendaRepository;

  Future<Response> getCycles(RequestContext context) async {
    try {
      final Map<String, String> queryParams =
          context.request.uri.queryParameters;

      final String? dateTimeString = queryParams['date_time'];

      if (dateTimeString == null) {
        throw const BadRequestBodyException(
          'Missing required query parameter: date',
        );
      }

      final Map<String, String> map = {'date_time': dateTimeString};

      @Throws([BadRequestBodyException])
      final getCyclesRequest = GetCyclesRequest.validatedFromMap(map);

      final int userId = context.read<int>();

      @Throws([DatabaseException])
      final GetCyclesResponse getCyclesResponse =
          await _agendaRepository.getCycles(getCyclesRequest, userId);

      switch (getCyclesResponse) {
        case GetCyclesResponseSuccess():
          return Response.json(
            body: getCyclesResponse.toMap(),
          );
        case GetCyclesResponseError():
          return Response.json(
            statusCode: HttpStatus.unauthorized,
            body: getCyclesResponse.toMap(),
          );
      }
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

  Future<Response> addCycle(RequestContext context) async {
    try {
      @Throws([BadRequestContentTypeException])
      final Request request = context.request
        ..assertContentType(ContentType.json.mimeType);

      @Throws([FormatException])
      final Map<String, dynamic> json = await request.json();

      @Throws([BadRequestBodyException])
      final addCycleRequest = AddCycleRequest.validatedFromMap(json);

      LOG.d('In handler: $addCycleRequest');

      final int userId = context.read<int>();

      @Throws([DatabaseException])
      final AddCycleResponse addCycleResponse =
          await _agendaRepository.addCycle(addCycleRequest, userId);

      switch (addCycleResponse) {
        case AddCycleResponseSuccess():
          return Response.json(
            statusCode: HttpStatus.created,
            body: addCycleResponse.toMap(),
          );
        case AddCycleResponseError():
          return Response.json(
            statusCode: HttpStatus.unauthorized,
            body: addCycleResponse.toMap(),
          );
      }
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

  Future<Response> addEncryptedCycle(RequestContext context) async {
    try {
      final Request request = context.request
        ..assertContentType(ContentType.json.mimeType);

      @Throws([FormatException])
      final Map<String, dynamic> json = await request.json();

      @Throws([BadRequestBodyException])
      final addCycleRequest = EncryptedAddCycleRequest.validatedFromMap(json);

      final int userId = context.read<int>();

      @Throws([DatabaseException])
      final EncryptedAddCycleResponse addCycleResponse =
          await _agendaRepository.addEncryptedCycle(addCycleRequest, userId);

      switch (addCycleResponse) {
        case EncryptedAddCycleResponseSuccess():
          return Response.json(
            statusCode: HttpStatus.created,
            body: addCycleResponse.toMap(),
          );
        case EncryptedAddCycleResponseError():
          return Response.json(
            statusCode: HttpStatus.unauthorized,
            body: addCycleResponse.toMap(),
          );
      }
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

  Future<Response> getEncryptedCycles(RequestContext context) async {
    try {
      final int userId = context.read<int>();

      @Throws([DatabaseException])
      final EncryptedGetCyclesResponse getCyclesResponse =
          await _agendaRepository.getEncryptedCycles(userId);

      switch (getCyclesResponse) {
        case EncryptedGetCyclesResponseSuccess():
          return Response.json(
            body: getCyclesResponse.toMap(),
          );
        case EncryptedGetCyclesResponseError():
          return Response.json(
            statusCode: HttpStatus.unauthorized,
            body: getCyclesResponse.toMap(),
          );
      }
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
