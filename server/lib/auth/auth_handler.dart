import 'dart:io';

import 'package:common/auth/login/login_request.dart';
import 'package:common/auth/login/login_response.dart';
import 'package:common/auth/register/register_error.dart';
import 'package:common/auth/register/register_request.dart';
import 'package:common/auth/register/register_response.dart';
import 'package:common/auth/tokens/refresh_token_request.dart';
import 'package:common/auth/tokens/refresh_token_response.dart';
import 'package:common/exceptions/request_exception.dart';
import 'package:common/exceptions/throws.dart';
import 'package:server/auth/abstractions/auth_handler_interface.dart';
import 'package:server/auth/abstractions/auth_repository_interface.dart';
import 'package:server/postgres/exceptions/database_exception.dart';
import 'package:server/util/json_response.dart';
import 'package:server/util/request_extension.dart';
import 'package:shelf/shelf.dart';

final class AuthHandler implements IAuthHandler {
  AuthHandler({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  final IAuthRepository _authRepository;

  @override
  Future<Response> refreshToken(Request request) async {
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

      final refreshTokenRequest = RefreshTokenRequest.validatedFromMap(json);

      final RefreshTokenResponse refreshTokenResponse = await _authRepository
          .refreshToken(refreshTokenRequest);

      switch (refreshTokenResponse) {
        case RefreshTokenResponseSuccess():
          return JsonResponse(body: refreshTokenResponse.toMap());
        case RefreshTokenResponseError():
          return JsonResponse(
            statusCode: HttpStatus.unauthorized,
            body: refreshTokenResponse.toMap(),
          );
      }
    } on Exception catch (e) {
      return Response(
        HttpStatus.internalServerError,
        body: 'Failed to refresh token: $e',
      );
    }
  }

  @override
  Future<Response> storeEncryptedSalt(Request request) async {
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

      final String? encryptedSalt = json['encrypted_salt'] as String?;
      if (encryptedSalt == null) {
        return Response(
          HttpStatus.badRequest,
          body: 'Missing encrypted_salt in request body',
        );
      }

      final int userId = request.getUserId();

      await _authRepository.storeEncryptedSalt(encryptedSalt, userId);

      return Response(
        HttpStatus.created,
        body: 'Encrypted salt stored successfully!',
      );
    } on BadRequestContentTypeException catch (e) {
      return Response(HttpStatus.badRequest, body: 'Invalid content type: $e');
    } on FormatException catch (e) {
      return Response(
        HttpStatus.badRequest,
        body: 'Invalid request format: $e',
      );
    } on DatabaseException catch (e) {
      return Response(
        HttpStatus.internalServerError,
        body: 'Database error: $e',
      );
    } on Exception catch (e) {
      return Response(
        HttpStatus.internalServerError,
        body: 'Failed to store encrypted salt: $e',
      );
    }
  }

  @override
  Future<Response> login(Request request) async {
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
      final loginRequest = LoginRequest.validatedFromMap(json);

      @Throws([DatabaseException])
      final LoginResponse loginResponse = await _authRepository.login(
        loginRequest,
      );

      switch (loginResponse) {
        case LoginResponseSuccess():
          return JsonResponse(body: loginResponse.toMap());
        case LoginResponseError():
          return JsonResponse(
            statusCode: HttpStatus.unauthorized,
            body: loginResponse.toMap(),
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

  @override
  Future<Response> register(Request request) async {
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
      final registerRequest = RegisterRequest.validatedFromMap(json);

      @Throws([DatabaseException])
      final RegisterResponse registerResponse = await _authRepository.register(
        registerRequest,
      );

      switch (registerResponse) {
        case RegisterResponseSuccess():
          return JsonResponse(
            statusCode: HttpStatus.created,
            body: registerResponse.toMap(),
          );
        case RegisterResponseError(:final error):
          switch (error) {
            case RegisterError.usernameAlreadyExists:
              return JsonResponse(
                statusCode: HttpStatus.conflict,
                body: registerResponse.toMap(),
              );
            case RegisterError.unknownRegisterError:
              return JsonResponse(
                statusCode: HttpStatus.internalServerError,
                body: registerResponse.toMap(),
              );
          }
      }
    } on DatabaseException catch (e) {
      switch (e) {
        case DBEuniqueViolation():
        case DBEunknown():
        case DBEbadCertificate():
        case DBEbadSchema():
        case DBEemptyResult():
      }

      return Response(
        HttpStatus.internalServerError,
        body: 'An error occurred! $e',
      );
    }
  }

  @override
  Future<Response> getEncryptedSalt(Request request) async {
    try {
      final int userId = request.getUserId();

      final String encryptedSalt = await _authRepository.getEncryptedSalt(
        userId,
      );

      return JsonResponse(body: {'encrypted_salt': encryptedSalt});
    } on DBEemptyResult {
      return JsonResponse(
        statusCode: HttpStatus.notFound,
        body: {'message': 'No encryption setup found for this user'},
      );
    } on Exception catch (e) {
      return Response(
        HttpStatus.internalServerError,
        body: 'Failed to get encrypted salt: $e',
      );
    }
  }
}
