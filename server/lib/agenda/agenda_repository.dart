import 'package:common/exceptions/propagates.dart';
import 'package:common/exceptions/throws.dart';
import 'package:common/tasks/add_task_request.dart';
import 'package:common/tasks/add_task_response.dart';
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
  Future<AddTaskResponseSuccess> addTask(
    AddTaskRequest addTaskRequest,
    int userId,
  ) async {
    @Throws([DatabaseException])
    final TaskDB taskDB = await _agendaDataSource.addTask(
      addTaskRequest,
      userId,
    );

    final addTaskResponse = AddTaskResponseSuccess(
      dateTime: taskDB.dateTime,
      description: taskDB.description,
      id: taskDB.id,
      title: taskDB.title,
      taskType: taskDB.taskType,
    );

    return addTaskResponse;
  }
}
