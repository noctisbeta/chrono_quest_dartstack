import 'package:server/agenda/agenda_data_source.dart';
import 'package:server/agenda/agenda_handler.dart';
import 'package:server/agenda/agenda_repository.dart';
import 'package:server/postgres/implementations/postgres_service.dart';
import 'package:server/util/context_key.dart';
import 'package:server/util/request_extension.dart';
import 'package:shelf/shelf.dart';

AgendaHandler? _agendaHandler;

Middleware agendaHandlerProvider() =>
    (Handler innerHandler) => (Request request) async {
      final AgendaRepository agendaRepository = request.getFromContext(
        ContextKey.agendaRepository,
      );

      _agendaHandler ??= AgendaHandler(agendaRepository: agendaRepository);

      final Request newRequest = request.addToContext(
        ContextKey.agendaHandler,
        _agendaHandler,
      );

      return await innerHandler(newRequest);
    };

AgendaRepository? _agendaRepository;

Middleware agendaRepositoryProvider() =>
    (Handler innerHandler) => (Request request) async {
      final AgendaDataSource agendaDataSource = request.getFromContext(
        ContextKey.agendaDataSource,
      );

      _agendaRepository ??= AgendaRepository(
        agendaDataSource: agendaDataSource,
      );

      final Request newRequest = request.addToContext(
        ContextKey.agendaRepository,
        _agendaRepository,
      );

      return await innerHandler(newRequest);
    };

AgendaDataSource? _agendaDataSource;
Middleware agendaDataSourceProvider() =>
    (Handler innerHandler) => (Request request) async {
      final PostgresService postgresService = request.getFromContext(
        ContextKey.postgresService,
      );

      _agendaDataSource ??= AgendaDataSource(postgresService: postgresService);

      final Request newRequest = request.addToContext(
        ContextKey.agendaDataSource,
        _agendaDataSource,
      );

      return await innerHandler(newRequest);
    };
