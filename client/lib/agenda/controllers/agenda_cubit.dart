import 'package:chrono_quest/agenda/repositories/agenda_repository.dart';
import 'package:common/agenda/add_task_error.dart';
import 'package:common/agenda/add_task_request.dart';
import 'package:common/agenda/add_task_response.dart';
import 'package:common/agenda/get_tasks_response.dart';
import 'package:common/agenda/task.dart';
import 'package:common/agenda/task_repetition.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AgendaCubit extends Cubit<List<Task>> {
  AgendaCubit({
    required AgendaRepository agendaRepository,
  })  : _agendaRepository = agendaRepository,
        super(
          [],
        );

  final AgendaRepository _agendaRepository;

  Future<void> getTasks() async {
    final GetTasksResponse getTasksResponse =
        await _agendaRepository.getTasks();

    switch (getTasksResponse) {
      case GetTasksResponseSuccess(:final tasks):
        emit(
          tasks,
        );
      case GetTasksResponseError():
        emit(
          [],
        );
    }
  }

  Future<void> addTask(
    String title,
    String note,
    TaskRepetition taskRepetition,
    DateTime startTime,
    DateTime endTime,
  ) async {
    final addTaskRequest = AddTaskRequest(
      startTime: startTime,
      note: note,
      title: title,
      taskRepetition: taskRepetition,
      endTime: endTime,
    );

    final AddTaskResponse addTaskResponse = await _agendaRepository.addTask(
      addTaskRequest,
    );

    switch (addTaskResponse) {
      case AddTaskResponseSuccess():
        await getTasks();
      case AddTaskResponseError():
        switch (addTaskResponse.error) {
          case AddTaskError.unknownError:
            emit(
              [],
            );
        }
    }
  }
}
