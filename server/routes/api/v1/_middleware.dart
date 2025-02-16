import 'package:dart_frog/dart_frog.dart';
import 'package:server/health/providers/health_service_provider.dart';
import 'package:server/postgres/providers/postgres_provider.dart';

Handler middleware(Handler handler) => handler
    .use(requestLogger())
    .use(healthServiceProvider())
    .use(postgresProvider());
