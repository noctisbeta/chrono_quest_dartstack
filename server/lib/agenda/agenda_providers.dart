import 'package:dart_frog/dart_frog.dart';
import 'package:server/agenda/agenda_data_source.dart';
import 'package:server/agenda/agenda_handler.dart';
import 'package:server/agenda/agenda_repository.dart';
import 'package:server/postgres/implementations/postgres_service.dart';

AgendaHandler? _agendaHandler;
Middleware agendaHandlerProvider() => provider<Future<AgendaHandler>>(
      (ctx) async => _agendaHandler ??= AgendaHandler(
        agendaRepository: await ctx.read<Future<AgendaRepository>>(),
      ),
    );

AgendaRepository? _agendaRepository;
Middleware agendaRepositoryProvider() => provider<Future<AgendaRepository>>(
      (ctx) async => _agendaRepository ??= AgendaRepository(
        agendaDataSource: await ctx.read<Future<AgendaDataSource>>(),
      ),
    );

AgendaDataSource? _agendaService;
Middleware agendaDataSourceProvider() => provider<Future<AgendaDataSource>>(
      (ctx) async => _agendaService ??= AgendaDataSource(
        postgresService: await ctx.read<Future<PostgresService>>(),
      ),
    );
