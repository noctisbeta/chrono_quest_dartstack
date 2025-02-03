import 'package:common/agenda/add_task_request.dart';
import 'package:common/agenda/add_task_response.dart';
import 'package:common/agenda/get_tasks_request.dart';
import 'package:common/agenda/get_tasks_response.dart';
import 'package:common/agenda/task.dart';
import 'package:common/exceptions/propagates.dart';
import 'package:common/exceptions/throws.dart';
import 'package:meta/meta.dart';
import 'package:server/agenda/agenda_data_source.dart';
import 'package:server/agenda/task_db.dart';
import 'package:server/postgres/exceptions/database_exception.dart';

@immutable
final class AgendaRepository {
  const AgendaRepository({
    required AgendaDataSource agendaDataSource,
  }) : _agendaDataSource = agendaDataSource;

  final AgendaDataSource _agendaDataSource;

  @Propagates([DatabaseException])
  Future<GetTasksResponse> getTasks(
    GetTasksRequest getTasksRequest,
    int userId,
  ) async {
    @Throws([DatabaseException])
    final List<TaskDB> taskDB = await _agendaDataSource.getTasks(
      getTasksRequest,
      userId,
    );

    final getTasksResponse = GetTasksResponseSuccess(
      tasks: taskDB
          .map(
            (e) => Task(
              endTime: e.endTime,
              startTime: e.startTime,
              description: e.description,
              id: e.id,
              title: e.title,
              taskType: e.taskType,
            ),
          )
          .toList(),
    );

    return getTasksResponse;
  }

  @Propagates([DatabaseException])
  Future<AddTaskResponse> addTask(
    AddTaskRequest addTaskRequest,
    int userId,
  ) async {
    @Throws([DatabaseException])
    final TaskDB taskDB = await _agendaDataSource.addTask(
      addTaskRequest,
      userId,
    );

    final Task task = Task(
      endTime: taskDB.endTime,
      startTime: taskDB.startTime,
      description: taskDB.description,
      id: taskDB.id,
      title: taskDB.title,
      taskType: taskDB.taskType,
    );

    final addTaskResponse = AddTaskResponseSuccess(
      task: task,
    );

    return addTaskResponse;
  }
}
