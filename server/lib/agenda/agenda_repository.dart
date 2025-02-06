import 'package:common/agenda/add_task_request.dart';
import 'package:common/agenda/add_task_response.dart';
import 'package:common/agenda/encrypted_add_task_request.dart';
import 'package:common/agenda/encrypted_add_task_response.dart';
import 'package:common/agenda/encrypted_get_tasks_response.dart';
import 'package:common/agenda/encrypted_task.dart';
import 'package:common/agenda/get_tasks_request.dart';
import 'package:common/agenda/get_tasks_response.dart';
import 'package:common/agenda/task.dart';
import 'package:common/exceptions/propagates.dart';
import 'package:common/exceptions/throws.dart';
import 'package:meta/meta.dart';
import 'package:server/agenda/agenda_data_source.dart';
import 'package:server/agenda/encrypted_task_db.dart';
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
              note: e.note,
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
      note: taskDB.note,
      id: taskDB.id,
      title: taskDB.title,
      taskType: taskDB.taskType,
    );

    final addTaskResponse = AddTaskResponseSuccess(
      task: task,
    );

    return addTaskResponse;
  }

  @Propagates([DatabaseException])
  Future<EncryptedAddTaskResponse> addEncryptedTask(
    EncryptedAddTaskRequest addTaskRequest,
    int userId,
  ) async {
    @Throws([DatabaseException])
    final EncryptedTaskDB taskDB = await _agendaDataSource.addEncryptedTask(
      addTaskRequest,
      userId,
    );

    final addTaskResponse = EncryptedAddTaskResponseSuccess(
      id: taskDB.id,
      startTime: taskDB.startTime,
      endTime: taskDB.endTime,
      note: taskDB.note,
      title: taskDB.title,
      taskType: taskDB.taskType,
    );

    return addTaskResponse;
  }

  @Propagates([DatabaseException])
  Future<EncryptedGetTasksResponse> getEncryptedTasks(int userId) async {
    @Throws([DatabaseException])
    final List<EncryptedTaskDB> tasksDB =
        await _agendaDataSource.getEncryptedTasks(userId);

    final List<EncryptedTask> tasks = tasksDB
        .map(
          (taskDB) => EncryptedTask(
            id: taskDB.id,
            startTime: taskDB.startTime,
            endTime: taskDB.endTime,
            note: taskDB.note,
            title: taskDB.title,
            taskType: taskDB.taskType,
            createdAt: taskDB.createdAt,
            updatedAt: taskDB.updatedAt,
          ),
        )
        .toList();

    return EncryptedGetTasksResponseSuccess(tasks: tasks);
  }
}
