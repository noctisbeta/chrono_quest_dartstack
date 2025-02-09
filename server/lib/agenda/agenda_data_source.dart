import 'package:common/agenda/add_cycle_request.dart';
import 'package:common/agenda/encrypted_add_cycle_request.dart';
import 'package:common/agenda/get_cycles_request.dart';
import 'package:common/exceptions/propagates.dart';
import 'package:common/exceptions/throws.dart';
import 'package:common/logger/logger.dart';
import 'package:meta/meta.dart';
import 'package:postgres/postgres.dart';
import 'package:server/agenda/cycle_db.dart';
import 'package:server/agenda/encrypted_cycle_db.dart';
import 'package:server/postgres/exceptions/database_exception.dart';
import 'package:server/postgres/implementations/postgres_service.dart';

@immutable
final class AgendaDataSource {
  const AgendaDataSource({
    required PostgresService postgresService,
  }) : _db = postgresService;

  final PostgresService _db;

  @Throws([DBEemptyResult, DBEbadSchema])
  @Propagates([DatabaseException])
  Future<List<CycleDB>> getCycles(
    GetCyclesRequest getCyclesRequest,
    int userId,
  ) async {
    final DateTime endTime = getCyclesRequest.dateTime;

    @Throws([DatabaseException])
    final Result res = await _db.execute(
      Sql.named('''
        SELECT * FROM cycles WHERE user_id = @user_id AND DATE(end_time) = DATE(@end_time);
      '''),
      parameters: {
        'user_id': userId,
        'end_time': endTime,
      },
    );

    final List<Map<String, dynamic>> resCols =
        res.map((row) => row.toColumnMap()).toList();

    @Throws([DBEbadSchema])
    final List<CycleDB> cycles = resCols.map(CycleDB.validatedFromMap).toList();

    return cycles;
  }

  @Throws([DBEemptyResult, DBEbadSchema])
  @Propagates([DatabaseException])
  Future<CycleDB> addCycle(AddCycleRequest addCycleRequest, int userId) async {
    try {
      @Throws([DatabaseException])
      final Result res = await _db.execute(
        Sql.named('''
          INSERT INTO cycles (
            user_id, 
            start_time, 
            end_time, 
            note, 
            title, 
            period
          )
          VALUES (
            @user_id, 
            @start_time, 
            @end_time, 
            @note, 
            @title, 
            @period
          ) 
          RETURNING *;
        '''),
        parameters: {
          'user_id': userId,
          'start_time': addCycleRequest.startTime,
          'end_time': addCycleRequest.endTime,
          'note': addCycleRequest.note,
          'title': addCycleRequest.title,
          'period': addCycleRequest.period,
        },
      );

      if (res.isEmpty) {
        throw const DBEemptyResult('No user found with that id.');
      }

      final Map<String, dynamic> resCol = res.first.toColumnMap();

      @Throws([DBEbadSchema])
      final cycleDB = CycleDB.validatedFromMap(resCol);

      return cycleDB;
    } catch (e, stackTrace) {
      LOG
        ..e('Error in addCycle:', error: e, stackTrace: stackTrace)
        ..d(
          'Request data:',
          error: {
            'userId': userId,
            'startTime': addCycleRequest.startTime,
            'endTime': addCycleRequest.endTime,
            'note': addCycleRequest.note,
            'title': addCycleRequest.title,
            'period': addCycleRequest.period,
          },
        );
      rethrow;
    }
  }

  @Throws([DBEemptyResult, DBEbadSchema])
  @Propagates([DatabaseException])
  Future<EncryptedCycleDB> addEncryptedCycle(
    EncryptedAddCycleRequest addCycleRequest,
    int userId,
  ) async {
    @Throws([DatabaseException])
    final Result res = await _db.execute(
      Sql.named('''
        INSERT INTO encrypted_cycles (
          user_id,
          start_time,
          end_time,
          note,
          title,
          period
        )
        VALUES (
          @user_id,
          @start_time,
          @end_time,  
          @note,
          @title,
          @period
        )
        RETURNING *;
      '''),
      parameters: {
        'user_id': userId,
        'start_time': addCycleRequest.startTime,
        'end_time': addCycleRequest.endTime,
        'note': addCycleRequest.note,
        'title': addCycleRequest.title,
        'period': addCycleRequest.period,
      },
    );

    if (res.isEmpty) {
      throw const DBEemptyResult('No user found with that id.');
    }

    final Map<String, dynamic> resCol = res.first.toColumnMap();

    @Throws([DBEbadSchema])
    final cycleDB = EncryptedCycleDB.validatedFromMap(resCol);

    return cycleDB;
  }

  @Throws([DBEemptyResult, DBEbadSchema])
  @Propagates([DatabaseException])
  Future<List<EncryptedCycleDB>> getEncryptedCycles(int userId) async {
    @Throws([DatabaseException])
    final Result res = await _db.execute(
      Sql.named('''
        SELECT * FROM encrypted_cycles
        WHERE user_id = @user_id
        ORDER BY created_at DESC;
      '''),
      parameters: {'user_id': userId},
    );

    if (res.isEmpty) {
      return [];
    }

    final List<EncryptedCycleDB> cycles = res.map((row) {
      final Map<String, dynamic> resCol = row.toColumnMap();
      @Throws([DBEbadSchema])
      final EncryptedCycleDB cycleDB =
          EncryptedCycleDB.validatedFromMap(resCol);

      return cycleDB;
    }).toList();

    return cycles;
  }
}
