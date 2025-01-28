import 'package:common/exceptions/propagates.dart';
import 'package:common/exceptions/throws.dart';
import 'package:common/tasks/add_task_request.dart';
import 'package:meta/meta.dart';
import 'package:postgres/postgres.dart';
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
  Future<TaskDB> addTask(AddTaskRequest addTaskRequest, int userId) async {
    @Throws([DatabaseException])
    final Result res = await _db.execute(
      Sql.named('''
        INSERT INTO tasks (user_id, date_time, description, title, task_type)
        VALUES (@userId, @dateTime, @description, @title, @taskType) RETURNING *;
      '''),
      parameters: {
        'userId': userId,
        'dateTime': addTaskRequest.dateTime.toIso8601String(),
        'description': addTaskRequest.description,
        'title': addTaskRequest.title,
        'taskType': addTaskRequest.taskType.toString(),
      },
    );

    if (res.isEmpty) {
      throw const DBEemptyResult('No user found with that username.');
    }

    final Map<String, dynamic> resCol = res.first.toColumnMap();

    @Throws([DBEbadSchema])
    final taskDB = TaskDB.validatedFromMap(resCol);

    return taskDB;
  }
}
