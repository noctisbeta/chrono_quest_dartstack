import 'package:chrono_quest/agenda/controllers/agenda_bloc.dart';
import 'package:chrono_quest/agenda/controllers/timeline_cubit.dart';
import 'package:chrono_quest/agenda/repositories/agenda_repository.dart';
import 'package:chrono_quest/dio_wrapper/dio_wrapper.dart';
import 'package:chrono_quest/encryption/encryption_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AgendaWrapper extends StatelessWidget {
  const AgendaWrapper({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) => MultiRepositoryProvider(
        providers: [
          RepositoryProvider(
            create: (context) => DioWrapper.authorized(),
          ),
          RepositoryProvider(
            create: (context) => EncryptionRepository(
              storage: const FlutterSecureStorage(),
              authorizedDio: context.read<DioWrapper>(),
            ),
          ),
          RepositoryProvider(
            create: (context) => AgendaRepository(
              authorizedDio: context.read<DioWrapper>(),
              encryptionRepository: context.read<EncryptionRepository>(),
            ),
          ),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => AgendaBloc(
                agendaRepository: context.read<AgendaRepository>(),
              ),
            ),
            BlocProvider(
              create: (context) => TimelineCubit(),
            ),
          ],
          child: child,
        ),
      );
}
