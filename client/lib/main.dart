import 'package:chrono_quest/authentication/controllers/auth_bloc.dart';
import 'package:chrono_quest/authentication/repositories/auth_repository.dart';
import 'package:chrono_quest/dio_wrapper/dio_wrapper.dart';
import 'package:chrono_quest/router/my_router.dart';
import 'package:chrono_quest/url_strategy/url_strategy_import.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  dummyFunctionForUrlPathStrategy();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => DioWrapper.unauthorized(),
        ),
        RepositoryProvider(
          create: (context) => AuthRepository(
            dio: context.read<DioWrapper>(),
          ),
        ),
      ],
      child: BlocProvider(
        create: (context) => AuthBloc(
          authRepository: context.read<AuthRepository>(),
        ),
        child: const MyRouter(),
      ),
    ),
  );
}
