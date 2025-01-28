import 'package:dart_frog/dart_frog.dart';
import 'package:server/auth/auth_providers.dart';

Handler middleware(Handler handler) => handler
    .use(authHandlerProvider())
    .use(authRepositoryProvider())
    .use(authDataSourceProvider());
