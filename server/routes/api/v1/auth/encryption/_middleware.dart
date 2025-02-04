import 'package:dart_frog/dart_frog.dart';
import 'package:server/auth/jwt_middleware.dart';

Handler middleware(Handler handler) => handler.use(jwtMiddlewareProvider());
