import 'package:chrono_quest/agenda/models/agenda_event.dart';
import 'package:chrono_quest/agenda/models/agenda_state.dart';
import 'package:chrono_quest/agenda/repositories/agenda_repository.dart';
import 'package:common/agenda/add_task_error.dart';
import 'package:common/agenda/add_task_request.dart';
import 'package:common/agenda/add_task_response.dart';
import 'package:common/agenda/task.dart';
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
      dateTime: event.task.startTime,
      description: event.task.description,
      title: event.task.title,
      taskType: event.task.taskType,
    );

    final AddTaskResponse addTaskResponse = await _agendaRepository.addTask(
      addTaskRequest,
    );

    switch (addTaskResponse) {
      case AddTaskResponseSuccess(:final task):
        emit(
          AgendaStateLoaded(
            tasks: [
              ...state.tasks,
              Task(
                id: task.id,
                startTime: task.startTime,
                endTime: task.endTime,
                description: task.description,
                title: task.title,
                taskType: task.taskType,
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
