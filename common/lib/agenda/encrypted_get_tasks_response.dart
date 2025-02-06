import 'package:common/abstractions/models.dart';
import 'package:common/agenda/encrypted_task.dart';
import 'package:common/exceptions/bad_map_shape_exception.dart';
import 'package:common/exceptions/throws.dart';
import 'package:meta/meta.dart';

@immutable
sealed class EncryptedGetTasksResponse extends Response {
  const EncryptedGetTasksResponse();
}

@immutable
final class EncryptedGetTasksResponseSuccess extends EncryptedGetTasksResponse {
  const EncryptedGetTasksResponseSuccess({
    required this.tasks,
  });

  @Throws([BadMapShapeException])
  factory EncryptedGetTasksResponseSuccess.validatedFromMap(
    Map<String, dynamic> map,
  ) =>
      switch (map) {
        {
          'tasks': final List<dynamic> tasks,
        } =>
          EncryptedGetTasksResponseSuccess(
            tasks: tasks
                .map((task) => EncryptedTask.validatedFromMap(task))
                .toList(),
          ),
        _ => throw const BadMapShapeException(
            'Invalid map format for EncryptedGetTasksResponseSuccess',
          ),
      };

  final List<EncryptedTask> tasks;

  @override
  List<Object?> get props => [tasks];

  @override
  Map<String, dynamic> toMap() => {
        'tasks': tasks.map((task) => task.toMap()).toList(),
      };
}

@immutable
final class EncryptedGetTasksResponseError extends EncryptedGetTasksResponse {
  const EncryptedGetTasksResponseError({
    required this.message,
  });

  @Throws([BadMapShapeException])
  factory EncryptedGetTasksResponseError.validatedFromMap(
    Map<String, dynamic> map,
  ) =>
      switch (map) {
        {
          'message': final String message,
        } =>
          EncryptedGetTasksResponseError(
            message: message,
          ),
        _ => throw const BadMapShapeException(
            'Invalid map format for EncryptedGetTasksResponseError',
          ),
      };

  final String message;

  @override
  List<Object?> get props => [message];

  @override
  Map<String, dynamic> toMap() => {
        'message': message,
      };
}
