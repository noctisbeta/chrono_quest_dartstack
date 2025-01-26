import 'dart:io';

import 'package:common/auth/login_request.dart';
import 'package:common/auth/login_response.dart';
import 'package:common/auth/register_request.dart';
import 'package:common/auth/register_response.dart';
import 'package:common/exceptions/request_exception.dart';
import 'package:common/exceptions/throws.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:server/auth/auth_exception.dart';
import 'package:server/auth/auth_repository.dart';
import 'package:server/postgres/exceptions/database_exception.dart';
import 'package:server/util/request_extension.dart';

final class AuthHandler {
  AuthHandler({
    required AuthRepository authRepository,
  }) : _authRepository = authRepository;

  final AuthRepository _authRepository;

  Future<Response> login(RequestContext context) async {
    try {
      @Throws([BadRequestContentTypeException])
      final Request request = context.request
        ..assertContentType(ContentType.json.mimeType);

      @Throws([FormatException])
      final Map<String, dynamic> json = await request.json();

      @Throws([BadRequestBodyException])
      final loginRequest = LoginRequest.validatedFromMap(json);

      @Throws([DatabaseException, AuthException])
      final LoginResponse loginResponse =
          await _authRepository.login(loginRequest);

      return Response.json(
        body: loginResponse.toMap(),
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
    } on AuthException catch (e) {
      switch (e) {
        case AEinvalidPassword():
          return Response(
            statusCode: HttpStatus.unauthorized,
            body: 'Invalid password! $e',
          );
      }
    }
  }

  Future<Response> register(RequestContext context) async {
    try {
      @Throws([BadRequestContentTypeException])
      final Request request = context.request
        ..assertContentType(ContentType.json.mimeType);

      @Throws([FormatException])
      final Map<String, dynamic> json = await request.json();

      @Throws([BadRequestBodyException])
      final registerRequest = RegisterRequest.validatedFromMap(json);

      @Throws([DatabaseException])
      final RegisterResponse registerResponse =
          await _authRepository.register(registerRequest);

      return Response.json(
        body: registerResponse.toMap(),
        statusCode: HttpStatus.created,
      );
    } on DatabaseException catch (e) {
      switch (e) {
        case DBEuniqueViolation():
        case DBEunknown():
        case DBEbadCertificate():
        case DBEbadSchema():
        case DBEemptyResult():
      }

      return Response(
        statusCode: HttpStatus.internalServerError,
        body: 'An error occurred! $e',
      );
    }
  }
}
