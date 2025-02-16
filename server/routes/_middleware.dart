import 'package:dart_frog/dart_frog.dart';
import 'package:server/auth/security_middleware.dart';

Handler middleware(Handler handler) => handler.use(securityMiddleware());
