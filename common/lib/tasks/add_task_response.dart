import 'package:common/abstractions/models.dart';
import 'package:common/exceptions/bad_map_shape_exception.dart';
import 'package:common/exceptions/response_exception.dart';
import 'package:common/tasks/add_task_error.dart';
import 'package:common/tasks/task_type.dart';
import 'package:meta/meta.dart';

@immutable
sealed class AddTaskResponse extends Request {
  const AddTaskResponse();
}

@immutable
final class AddTaskResponseSuccess extends AddTaskResponse {
  const AddTaskResponseSuccess({
    required this.id,
    required this.dateTime,
    required this.description,
    required this.title,
    required this.taskType,
  });

  factory AddTaskResponseSuccess.validatedFromMap(Map<String, dynamic> map) =>
      switch (map) {
        {
          'id': final int id,
          'dateTime': final String dateTime,
          'description': final String description,
          'title': final String title,
          'taskType': final String taskType,
        } =>
          AddTaskResponseSuccess(
            id: id,
            dateTime: DateTime.parse(dateTime),
            description: description,
            title: title,
            taskType: TaskType.fromString(taskType),
          ),
        _ => throw const BadMapShapeException(
            'Invalid map format for AddTaskRequest.',
          ),
      };

  final int id;
  final DateTime dateTime;
  final String description;
  final String title;
  final TaskType taskType;

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'dateTime': dateTime.toIso8601String(),
        'description': description,
        'title': title,
        'taskType': taskType.toString(),
      };

  @override
  List<Object?> get props => [id, dateTime, description, title, taskType];
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
