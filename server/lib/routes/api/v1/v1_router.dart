import 'package:server/agenda/agenda_providers.dart';
import 'package:server/auth/auth_providers.dart';
import 'package:server/auth/jwt_middleware.dart';
import 'package:server/health/providers/health_service_provider.dart';
import 'package:server/routes/api/v1/agenda/agenda_router.dart';
import 'package:server/routes/api/v1/auth/auth_router.dart';
import 'package:server/routes/api/v1/health/api_v1_health_handler.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

Future<Router> createV1Router() async {
  final Handler healthHandler = const Pipeline()
      .addMiddleware(healthServiceProvider())
      .addHandler(apiV1HealthHandler);

  final Router authRouter = createAuthRouter();
  final Handler authHandler = const Pipeline()
      .addMiddleware(authDataSourceProvider())
      .addMiddleware(authRepositoryProvider())
      .addMiddleware(authHandlerProvider())
      .addHandler(authRouter.call);

  final Router agendaRouter = createAgendaRouter();
  final Handler agendaHandler = const Pipeline()
      .addMiddleware(agendaDataSourceProvider())
      .addMiddleware(agendaRepositoryProvider())
      .addMiddleware(agendaHandlerProvider())
      .addMiddleware(jwtMiddlewareProvider())
      .addHandler(agendaRouter.call);

  final router =
      Router()
        ..mount('/auth', authHandler)
        ..mount('/agenda', agendaHandler)
        ..all('/health', healthHandler);

  return router;
}
