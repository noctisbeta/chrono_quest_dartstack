import 'package:chrono_quest/agenda/controllers/agenda_bloc.dart';
import 'package:chrono_quest/authentication/controllers/auth_bloc.dart';
import 'package:chrono_quest/authentication/repositories/auth_repository.dart';
import 'package:chrono_quest/dio_wrapper/dio_wrapper.dart';
import 'package:chrono_quest/router/go_router.dart';
import 'package:chrono_quest/url_strategy/url_strategy_import.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  dummyFunctionForUrlPathStrategy();

  

  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MultiRepositoryProvider(
        providers: [
          RepositoryProvider(
            create: (context) => DioWrapper(),
          ),
          RepositoryProvider(
            create: (context) => AuthRepository(
              dio: context.read<DioWrapper>(),
            ),
          ),
          RepositoryProvider(
            create: (context) => MyRouter(
              authRepository: context.read<AuthRepository>(),
            ),
          ),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => AuthBloc(
                authRepository: context.read<AuthRepository>(),
              ),
            ),
            BlocProvider(
              create: (context) => AgendaBloc(
                authRepository: context.read<AuthRepository>(),
              ),
            ),
          ],
          child: Builder(
            builder: (context) => MaterialApp.router(
              routerConfig: context.read<MyRouter>().router,
              title: 'Chrono Quest',
            ),
          ),
        ),
      );
}
