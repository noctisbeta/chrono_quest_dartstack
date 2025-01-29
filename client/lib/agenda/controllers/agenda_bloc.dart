import 'package:chrono_quest/agenda/models/agenda_event.dart';
import 'package:chrono_quest/agenda/models/agenda_state.dart';
import 'package:chrono_quest/agenda/repositories/agenda_repository.dart';
import 'package:common/tasks/add_task_error.dart';
import 'package:common/tasks/add_task_request.dart';
import 'package:common/tasks/add_task_response.dart';
import 'package:common/tasks/task.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AgendaBloc extends Bloc<AgendaEvent, AgendaState> {
  AgendaBloc({
    required AgendaRepository agendaRepository,
  })  : _agendaRepository = agendaRepository,
        super(
          const AgendaStateInitial(),
        ) {
    on<AgendaEvent>(
      (event, emit) async => switch (event) {
        AgendaEventAddTask() => addTask(event, emit),
      },
    );
  }

  final AgendaRepository _agendaRepository;

  

  Future<void> addTask(
    AgendaEventAddTask event,
    Emitter<AgendaState> emit,
  ) async {
    emit(
      AgendaStateAddTaskLoading(
        tasks: state.tasks,
      ),
    );

    final AddTaskRequest addTaskRequest = AddTaskRequest(
      dateTime: event.task.dateTime,
      description: event.task.description,
      title: event.task.title,
      taskType: event.task.taskType,
    );

    final AddTaskResponse addTaskResponse = await _agendaRepository.addTask(
      addTaskRequest,
    );

    switch (addTaskResponse) {
      case AddTaskResponseSuccess():
        emit(
          AgendaStateLoaded(
            tasks: [
              ...state.tasks,
              Task(
                id: addTaskResponse.id,
                dateTime: addTaskResponse.dateTime,
                description: addTaskResponse.description,
                title: addTaskResponse.title,
                taskType: addTaskResponse.taskType,
              ),
            ],
          ),
        );
      case AddTaskResponseError():
        switch (addTaskResponse.error) {
          case AddTaskError.unknownError:
            emit(
              AgendaStateAddTaskError(
                tasks: state.tasks,
                message: 'Error adding task',
              ),
            );
        }
    }
  }
}
