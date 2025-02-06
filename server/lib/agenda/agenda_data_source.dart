import 'package:common/agenda/add_task_request.dart';
import 'package:common/agenda/encrypted_add_task_request.dart';
import 'package:common/agenda/get_tasks_request.dart';
import 'package:common/exceptions/propagates.dart';
import 'package:common/exceptions/throws.dart';
import 'package:common/logger/logger.dart';
import 'package:meta/meta.dart';
import 'package:postgres/postgres.dart';
import 'package:server/agenda/encrypted_task_db.dart';
import 'package:server/agenda/task_db.dart';
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
  Future<List<TaskDB>> getTasks(
    GetTasksRequest getTasksRequest,
    int userId,
  ) async {
    final DateTime endTime = getTasksRequest.dateTime;

    @Throws([DatabaseException])
    final Result res = await _db.execute(
      Sql.named('''
        SELECT * FROM tasks WHERE user_id = @user_id AND DATE(end_time) = DATE(@end_time);
      '''),
      parameters: {
        'user_id': userId,
        'end_time': endTime,
      },
    );

    final List<Map<String, dynamic>> resCols =
        res.map((row) => row.toColumnMap()).toList();

    @Throws([DBEbadSchema])
    final List<TaskDB> tasks = resCols.map(TaskDB.validatedFromMap).toList();

    return tasks;
  }

  @Throws([DBEemptyResult, DBEbadSchema])
  @Propagates([DatabaseException])
  Future<TaskDB> addTask(AddTaskRequest addTaskRequest, int userId) async {
    try {
      @Throws([DatabaseException])
      final Result res = await _db.execute(
        Sql.named('''
          INSERT INTO tasks (
            user_id, 
            start_time, 
            end_time, 
            note, 
            title, 
            repeat_amount,
            repeat_duration_type
          )
          VALUES (
            @user_id, 
            @start_time, 
            @end_time, 
            @note, 
            @title, 
            @repeat_amount,
            @repeat_duration_type
          ) 
          RETURNING *;
        '''),
        parameters: {
          'user_id': userId,
          'start_time': addTaskRequest.startTime,
          'end_time': addTaskRequest.endTime,
          'note': addTaskRequest.note,
          'title': addTaskRequest.title,
          'repeat_amount': addTaskRequest.taskRepetition.amount,
          'repeat_duration_type':
              addTaskRequest.taskRepetition.durationType.name,
        },
      );

      if (res.isEmpty) {
        throw const DBEemptyResult('No user found with that id.');
      }

      final Map<String, dynamic> resCol = res.first.toColumnMap();

      @Throws([DBEbadSchema])
      final taskDB = TaskDB.validatedFromMap(resCol);

      return taskDB;
    } catch (e, stackTrace) {
      LOG
        ..e('Error in addTask:', error: e, stackTrace: stackTrace)
        ..d(
          'Request data:',
          error: {
            'userId': userId,
            'startTime': addTaskRequest.startTime,
            'endTime': addTaskRequest.endTime,
            'note': addTaskRequest.note,
            'title': addTaskRequest.title,
            'repeatAmount': addTaskRequest.taskRepetition.amount,
            'repeatDurationType':
                addTaskRequest.taskRepetition.durationType.name,
          },
        );
      rethrow;
    }
  }

  @Throws([DBEemptyResult, DBEbadSchema])
  @Propagates([DatabaseException])
  Future<EncryptedTaskDB> addEncryptedTask(
    EncryptedAddTaskRequest addTaskRequest,
    int userId,
  ) async {
    @Throws([DatabaseException])
    final Result res = await _db.execute(
      Sql.named('''
        INSERT INTO encrypted_tasks (
          user_id,
          start_time,
          end_time,
          note,
          title,
          repeat_amount,
          repeat_duration_type
        )
        VALUES (
          @user_id,
          @start_time,
          @end_time,
          @note,
          @title,
          @repeat_amount,
          @repeat_duration_type
        )
        RETURNING *;
      '''),
      parameters: {
        'user_id': userId,
        'start_time': addTaskRequest.startTime,
        'end_time': addTaskRequest.endTime,
        'note': addTaskRequest.note,
        'title': addTaskRequest.title,
        'repeat_amount': addTaskRequest.taskRepetition,
        'repeat_duration_type': addTaskRequest.taskRepetition,
      },
    );

    if (res.isEmpty) {
      throw const DBEemptyResult('No user found with that id.');
    }

    final Map<String, dynamic> resCol = res.first.toColumnMap();

    @Throws([DBEbadSchema])
    final taskDB = EncryptedTaskDB.validatedFromMap(resCol);

    return taskDB;
  }

  @Throws([DBEemptyResult, DBEbadSchema])
  @Propagates([DatabaseException])
  Future<List<EncryptedTaskDB>> getEncryptedTasks(int userId) async {
    @Throws([DatabaseException])
    final Result res = await _db.execute(
      Sql.named('''
        SELECT * FROM encrypted_tasks
        WHERE user_id = @user_id
        ORDER BY created_at DESC;
      '''),
      parameters: {'user_id': userId},
    );

    if (res.isEmpty) {
      return [];
    }

    final List<EncryptedTaskDB> tasks = res.map((row) {
      final Map<String, dynamic> resCol = row.toColumnMap();
      @Throws([DBEbadSchema])
      final EncryptedTaskDB taskDB = EncryptedTaskDB.validatedFromMap(resCol);

      return taskDB;
    }).toList();

    return tasks;
  }
}
