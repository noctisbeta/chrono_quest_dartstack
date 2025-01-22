import 'package:dart_frog/dart_frog.dart';
import 'package:server/postgres/providers/postgres_provider.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart' as shelf;

Handler middleware(Handler handler) => handler //
    .use(requestLogger())
    .use(postgresProvider())
    .use(
      fromShelfMiddleware(
        shelf.corsHeaders(
          headers: {
            shelf.ACCESS_CONTROL_ALLOW_ORIGIN: '*',
          },
        ),
      ),
    );
