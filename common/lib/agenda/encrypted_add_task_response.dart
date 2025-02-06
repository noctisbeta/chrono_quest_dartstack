import 'package:common/abstractions/models.dart';
import 'package:common/agenda/add_task_error.dart';
import 'package:common/exceptions/bad_map_shape_exception.dart';
import 'package:common/exceptions/response_exception.dart';
import 'package:meta/meta.dart';

@immutable
sealed class EncryptedAddTaskResponse extends Request {
  const EncryptedAddTaskResponse();
}

@immutable
final class EncryptedAddTaskResponseSuccess extends EncryptedAddTaskResponse {
  const EncryptedAddTaskResponseSuccess({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.note,
    required this.title,
    required this.taskType,
  });

  factory EncryptedAddTaskResponseSuccess.validatedFromMap(
    Map<String, dynamic> map,
  ) =>
      switch (map) {
        {
          'id': final int id,
          'startTime': final String startTime,
          'endTime': final String endTime,
          'note': final String note,
          'title': final String title,
          'taskType': final String taskType,
        } =>
          EncryptedAddTaskResponseSuccess(
            id: id,
            startTime: startTime,
            endTime: endTime,
            note: note,
            title: title,
            taskType: taskType,
          ),
        _ => throw const BadMapShapeException(
            'Invalid map format for EncryptedAddTaskResponseSuccess.',
          ),
      };

  final int id;
  final String startTime;
  final String endTime;
  final String note;
  final String title;
  final String taskType;

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'startTime': startTime,
        'endTime': endTime,
        'note': note,
        'title': title,
        'taskType': taskType,
      };

  @override
  List<Object?> get props => [id, startTime, endTime, note, title, taskType];
}

@immutable
final class EncryptedAddTaskResponseError extends EncryptedAddTaskResponse {
  const EncryptedAddTaskResponseError({
    required this.message,
    required this.error,
  });

  factory EncryptedAddTaskResponseError.validatedFromMap(
    Map<String, dynamic> map,
  ) =>
      switch (map) {
        {
          'message': final String message,
          'error': final String error,
        } =>
          EncryptedAddTaskResponseError(
            message: message,
            error: AddTaskError.fromString(error),
          ),
        _ => throw const BadResponseBodyException(
            'Invalid map format for EncryptedAddTaskResponseError',
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
