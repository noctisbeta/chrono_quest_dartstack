import 'package:common/agenda/add_task_request.dart';
import 'package:common/agenda/get_tasks_request.dart';
import 'package:common/exceptions/propagates.dart';
import 'package:common/exceptions/throws.dart';
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
  Future<List<TaskDB>> getTasks(
    GetTasksRequest getTasksRequest,
    int userId,
  ) async {
    final DateTime dateTime = getTasksRequest.dateTime;

    @Throws([DatabaseException])
    final Result res = await _db.execute(
      Sql.named('''
        SELECT * FROM tasks WHERE user_id = @userId AND DATE(date_time) = DATE(@dateTime);
      '''),
      parameters: {
        'userId': userId,
        'dateTime': dateTime,
      },
    );

    if (res.isEmpty) {
      throw const DBEemptyResult('No user found with that username.');
    }

    final List<Map<String, dynamic>> resCols =
        res.map((row) => row.toColumnMap()).toList();

    @Throws([DBEbadSchema])
    final List<TaskDB> tasks = resCols.map(TaskDB.validatedFromMap).toList();

    return tasks;
  }

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
        'dateTime': addTaskRequest.startTime.toIso8601String(),
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
