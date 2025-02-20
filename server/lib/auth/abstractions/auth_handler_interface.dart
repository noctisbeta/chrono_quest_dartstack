import 'package:shelf/shelf.dart';

abstract interface class IAuthHandler {
  Future<Response> refreshToken(Request request);
  Future<Response> storeEncryptedSalt(Request request);
  Future<Response> login(Request request);
  Future<Response> register(Request request);
  Future<Response> getEncryptedSalt(Request request);
}
