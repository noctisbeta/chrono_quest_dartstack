import 'package:common/abstractions/models.dart';
import 'package:common/agenda/add_task_error.dart';
import 'package:common/agenda/task.dart';
import 'package:common/exceptions/bad_map_shape_exception.dart';
import 'package:common/exceptions/response_exception.dart';
import 'package:meta/meta.dart';

@immutable
sealed class AddTaskResponse extends Request {
  const AddTaskResponse();
}

@immutable
final class AddTaskResponseSuccess extends AddTaskResponse {
  const AddTaskResponseSuccess({
    required this.task,
  });

  factory AddTaskResponseSuccess.validatedFromMap(Map<String, dynamic> map) =>
      switch (map) {
        {
          'task': final Map<String, dynamic> taskMap,
        } =>
          AddTaskResponseSuccess(
            task: Task.validatedFromMap(taskMap),
          ),
        _ => throw const BadMapShapeException(
            'Invalid map format for AddTaskResponseSuccess.',
          ),
      };

  final Task task;

  @override
  Map<String, dynamic> toMap() => {
        'task': task.toMap(),
      };

  @override
  List<Object?> get props => [task];
}

@immutable
final class AddTaskResponseError extends AddTaskResponse {
  const AddTaskResponseError({
    required this.message,
    required this.error,
  });

  factory AddTaskResponseError.validatedFromMap(Map<String, dynamic> map) =>
      switch (map) {
        {
          'message': final String message,
          'error': final String error,
        } =>
          AddTaskResponseError(
            message: message,
            error: AddTaskError.fromString(error),
          ),
        _ => throw const BadResponseBodyException(
            'Invalid map format for AddTaskResponseError',
          )
      };

  final String message;

  final AddTaskError error;

  @override
  Map<String, dynamic> toMap() => {
        'message': message,
        'error': error.toString(),
      };

  @override
  List<Object?> get props => [message, error];
}
