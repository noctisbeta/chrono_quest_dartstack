import 'dart:io';

import 'package:common/agenda/add_cycle_request.dart';
import 'package:common/agenda/add_cycle_response.dart';
import 'package:common/agenda/encrypted_add_cycle_request.dart';
import 'package:common/agenda/encrypted_add_cycle_response.dart';
import 'package:common/agenda/encrypted_get_cycles_response.dart';
import 'package:common/agenda/get_cycles_request.dart';
import 'package:common/agenda/get_cycles_response.dart';
import 'package:common/agenda/get_reference_date_request.dart';
import 'package:common/agenda/get_reference_date_response.dart';
import 'package:common/agenda/set_reference_date_request.dart';
import 'package:common/agenda/set_reference_date_response.dart';
import 'package:common/exceptions/request_exception.dart';
import 'package:common/exceptions/throws.dart';
import 'package:meta/meta.dart';
import 'package:server/agenda/agenda_repository.dart';
import 'package:server/postgres/exceptions/database_exception.dart';
import 'package:server/util/json_response.dart';
import 'package:server/util/request_extension.dart';
import 'package:shelf/shelf.dart';

@immutable
final class AgendaHandler {
  const AgendaHandler({required AgendaRepository agendaRepository})
    : _agendaRepository = agendaRepository;

  final AgendaRepository _agendaRepository;

  Future<Response> getReferenceDate(Request request) async {
    try {
      final int userId = request.getUserId();

      const getReferenceDateRequest = GetReferenceDateRequest();

      @Throws([DatabaseException])
      final GetReferenceDateResponse getReferenceDateResponse =
          await _agendaRepository.getReferenceDate(
            getReferenceDateRequest,
            userId,
          );

      switch (getReferenceDateResponse) {
        case GetReferenceDateResponseSuccess():
          return JsonResponse(body: getReferenceDateResponse.toMap());
        case GetReferenceDateResponseError():
          return JsonResponse(
            body: getReferenceDateResponse.toMap(),
            statusCode: HttpStatus.unauthorized,
          );
      }
    } on DatabaseException catch (e) {
      switch (e) {
        case DBEuniqueViolation():
        case DBEunknown():
        case DBEbadCertificate():
        case DBEbadSchema():
        case DBEemptyResult():
          return Response(HttpStatus.notFound, body: 'User does not exist! $e');
      }
    }
  }

  Future<Response> setReferenceDate(Request request) async {
    try {
      final bool isValidContentType = request.validateContentType(
        ContentType.json.mimeType,
      );

      if (!isValidContentType) {
        return Response(
          HttpStatus.badRequest,
          body: 'Invalid request! Content-Type must be ${ContentType.json}',
        );
      }

      @Throws([FormatException])
      final Map<String, dynamic> json = await request.json();

      @Throws([BadRequestBodyException])
      final setReferenceDateRequest = SetReferenceDateRequest.validatedFromMap(
        json,
      );

      final int userId = request.getUserId();

      @Throws([DatabaseException])
      final SetReferenceDateResponse setReferenceDateResponse =
          await _agendaRepository.setReferenceDate(
            setReferenceDateRequest,
            userId,
          );

      switch (setReferenceDateResponse) {
        case SetReferenceDateResponseSuccess():
          return JsonResponse(body: setReferenceDateResponse.toMap());
        case SetReferenceDateResponseError():
          return JsonResponse(
            statusCode: HttpStatus.unauthorized,
            body: setReferenceDateResponse.toMap(),
          );
      }
    } on BadRequestContentTypeException catch (e) {
      return Response(HttpStatus.badRequest, body: 'Invalid request! $e');
    } on FormatException catch (e) {
      return Response(HttpStatus.badRequest, body: 'Invalid request! $e');
    } on BadRequestBodyException catch (e) {
      return Response(HttpStatus.badRequest, body: 'Invalid request! $e');
    } on DatabaseException catch (e) {
      switch (e) {
        case DBEuniqueViolation():
        case DBEunknown():
        case DBEbadCertificate():
        case DBEbadSchema():
        case DBEemptyResult():
          return Response(HttpStatus.notFound, body: 'User does not exist! $e');
      }
    }
  }

  Future<Response> getCycles(Request request) async {
    try {
      final Map<String, String> queryParams =
          request.requestedUri.queryParameters;

      final String? dateTimeString = queryParams['date_time'];

      if (dateTimeString == null) {
        throw const BadRequestBodyException(
          'Missing required query parameter: date',
        );
      }

      final Map<String, String> map = {'date_time': dateTimeString};

      @Throws([BadRequestBodyException])
      final getCyclesRequest = GetCyclesRequest.validatedFromMap(map);

      final int userId = request.getUserId();

      @Throws([DatabaseException])
      final GetCyclesResponse getCyclesResponse = await _agendaRepository
          .getCycles(getCyclesRequest, userId);

      switch (getCyclesResponse) {
        case GetCyclesResponseSuccess():
          return JsonResponse(body: getCyclesResponse.toMap());
        case GetCyclesResponseError():
          return JsonResponse(
            statusCode: HttpStatus.unauthorized,
            body: getCyclesResponse.toMap(),
          );
      }
    } on BadRequestContentTypeException catch (e) {
      return Response(HttpStatus.badRequest, body: 'Invalid request! $e');
    } on FormatException catch (e) {
      return Response(HttpStatus.badRequest, body: 'Invalid request! $e');
    } on BadRequestBodyException catch (e) {
      return Response(HttpStatus.badRequest, body: 'Invalid request! $e');
    } on DatabaseException catch (e) {
      switch (e) {
        case DBEuniqueViolation():
        case DBEunknown():
        case DBEbadCertificate():
        case DBEbadSchema():
        case DBEemptyResult():
          return Response(HttpStatus.notFound, body: 'User does not exist! $e');
      }
    }
  }

  Future<Response> addCycle(Request request) async {
    try {
      final bool isValidContentType = request.validateContentType(
        ContentType.json.mimeType,
      );

      if (!isValidContentType) {
        return Response(
          HttpStatus.badRequest,
          body: 'Invalid request! Content-Type must be ${ContentType.json}',
        );
      }

      @Throws([FormatException])
      final Map<String, dynamic> json = await request.json();

      @Throws([BadRequestBodyException])
      final addCycleRequest = AddCycleRequest.validatedFromMap(json);

      final int userId = request.getUserId();

      @Throws([DatabaseException])
      final AddCycleResponse addCycleResponse = await _agendaRepository
          .addCycle(addCycleRequest, userId);

      switch (addCycleResponse) {
        case AddCycleResponseSuccess():
          return JsonResponse(
            statusCode: HttpStatus.created,
            body: addCycleResponse.toMap(),
          );
        case AddCycleResponseError():
          return JsonResponse(
            statusCode: HttpStatus.unauthorized,
            body: addCycleResponse.toMap(),
          );
      }
    } on BadRequestContentTypeException catch (e) {
      return Response(HttpStatus.badRequest, body: 'Invalid request! $e');
    } on FormatException catch (e) {
      return Response(HttpStatus.badRequest, body: 'Invalid request! $e');
    } on BadRequestBodyException catch (e) {
      return Response(HttpStatus.badRequest, body: 'Invalid request! $e');
    } on DatabaseException catch (e) {
      switch (e) {
        case DBEuniqueViolation():
        case DBEunknown():
        case DBEbadCertificate():
        case DBEbadSchema():
        case DBEemptyResult():
          return Response(HttpStatus.notFound, body: 'User does not exist! $e');
      }
    }
  }

  Future<Response> addEncryptedCycle(Request request) async {
    try {
      final bool isValidContentType = request.validateContentType(
        ContentType.json.mimeType,
      );

      if (!isValidContentType) {
        return Response(
          HttpStatus.badRequest,
          body: 'Invalid request! Content-Type must be ${ContentType.json}',
        );
      }

      @Throws([FormatException])
      final Map<String, dynamic> json = await request.json();

      @Throws([BadRequestBodyException])
      final addCycleRequest = EncryptedAddCycleRequest.validatedFromMap(json);

      final int userId = request.getUserId();

      @Throws([DatabaseException])
      final EncryptedAddCycleResponse addCycleResponse = await _agendaRepository
          .addEncryptedCycle(addCycleRequest, userId);

      switch (addCycleResponse) {
        case EncryptedAddCycleResponseSuccess():
          return JsonResponse(
            statusCode: HttpStatus.created,
            body: addCycleResponse.toMap(),
          );
        case EncryptedAddCycleResponseError():
          return JsonResponse(
            statusCode: HttpStatus.unauthorized,
            body: addCycleResponse.toMap(),
          );
      }
    } on BadRequestContentTypeException catch (e) {
      return Response(HttpStatus.badRequest, body: 'Invalid request! $e');
    } on FormatException catch (e) {
      return Response(HttpStatus.badRequest, body: 'Invalid request! $e');
    } on BadRequestBodyException catch (e) {
      return Response(HttpStatus.badRequest, body: 'Invalid request! $e');
    } on DatabaseException catch (e) {
      switch (e) {
        case DBEuniqueViolation():
        case DBEunknown():
        case DBEbadCertificate():
        case DBEbadSchema():
        case DBEemptyResult():
          return Response(HttpStatus.notFound, body: 'User does not exist! $e');
      }
    }
  }

  Future<Response> getEncryptedCycles(Request request) async {
    try {
      final int userId = request.getUserId();

      @Throws([DatabaseException])
      final EncryptedGetCyclesResponse getCyclesResponse =
          await _agendaRepository.getEncryptedCycles(userId);

      switch (getCyclesResponse) {
        case EncryptedGetCyclesResponseSuccess():
          return JsonResponse(body: getCyclesResponse.toMap());
        case EncryptedGetCyclesResponseError():
          return JsonResponse(
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
          return Response(HttpStatus.notFound, body: 'User does not exist! $e');
      }
    }
  }
}
