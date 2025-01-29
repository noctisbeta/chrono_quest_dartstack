import 'package:common/abstractions/models.dart';
import 'package:common/agenda/task.dart';
import 'package:common/exceptions/bad_map_shape_exception.dart';
import 'package:common/exceptions/throws.dart';
import 'package:meta/meta.dart';

@immutable
sealed class GetTasksResponse extends Response {
  const GetTasksResponse();
}

@immutable
final class GetTasksResponseSuccess extends GetTasksResponse {
  const GetTasksResponseSuccess({
    required this.tasks,
  });

  @Throws([BadMapShapeException])
  factory GetTasksResponseSuccess.validatedFromMap(Map<String, dynamic> map) =>
      switch (map) {
        {
          'tasks': final List<Map<String, dynamic>> tasks,
        } =>
          GetTasksResponseSuccess(
            tasks: tasks.map(Task.validatedFromMap).toList(),
          ),
        _ => throw const BadMapShapeException(
            'Invalid map format for GetTasksResponseSuccess',
          ),
      };

  final List<Task> tasks;

  @override
  List<Object?> get props => [tasks];

  @override
  Map<String, dynamic> toMap() => {
        'tasks': tasks.map((task) => task.toMap()).toList(),
      };
}

@immutable
final class GetTasksResponseError extends GetTasksResponse {
  const GetTasksResponseError({
    required this.message,
  });

  @Throws([BadMapShapeException])
  factory GetTasksResponseError.validatedFromMap(
    Map<String, dynamic> map,
  ) =>
      switch (map) {
        {
          'message': final String message,
        } =>
          GetTasksResponseError(
            message: message,
          ),
        _ => throw const BadMapShapeException(
            'Invalid map format for GetTasksResponseError',
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
