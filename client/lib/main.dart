import 'package:chrono_quest/authentication/repositories/auth_repository.dart';
import 'package:chrono_quest/dio_wrapper/dio_wrapper.dart';
import 'package:chrono_quest/router/my_router.dart';
import 'package:chrono_quest/url_strategy/url_strategy_import.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  dummyFunctionForUrlPathStrategy();

  runApp(
    const MyApp(),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) => MultiRepositoryProvider(
        providers: [
          RepositoryProvider(
            create: (context) => DioWrapper.unauthorized(),
          ),
          RepositoryProvider(
            create: (context) => AuthRepository(
              dio: context.read<DioWrapper>(),
            ),
          ),
          RepositoryProvider(
            create: (context) =>
                MyRouter(authRepository: context.read<AuthRepository>()),
          ),
        ],
        child: Builder(
          builder: (context) => MaterialApp.router(
            routerConfig: context.read<MyRouter>().router,
            title: 'Chrono Quest',
          ),
        ),
      );
}
