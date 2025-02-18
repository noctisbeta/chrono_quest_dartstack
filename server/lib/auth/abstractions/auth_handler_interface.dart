import 'package:dart_frog/dart_frog.dart';

abstract interface class IAuthHandler {
  Future<Response> refreshToken(RequestContext context);
  Future<Response> storeEncryptedSalt(RequestContext context);
  Future<Response> login(RequestContext context);
  Future<Response> register(RequestContext context);
  Future<Response> getEncryptedSalt(RequestContext context);
}
