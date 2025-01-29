import 'package:common/abstractions/models.dart';
import 'package:common/agenda/task_type.dart';
import 'package:common/exceptions/bad_map_shape_exception.dart';
import 'package:meta/meta.dart';

@immutable
final class AddTaskRequest extends Request {
  const AddTaskRequest({
    required this.dateTime,
    required this.description,
    required this.title,
    required this.taskType,
  });

  factory AddTaskRequest.validatedFromMap(Map<String, dynamic> map) =>
      switch (map) {
        {
          'dateTime': final String dateTime,
          'description': final String description,
          'title': final String title,
          'taskType': final String taskType,
        } =>
          AddTaskRequest(
            dateTime: DateTime.parse(dateTime),
            description: description,
            title: title,
            taskType: TaskType.fromString(taskType),
          ),
        _ => throw const BadMapShapeException(
            'Invalid map format for AddTaskRequest.',
          ),
      };

  final DateTime dateTime;
  final String description;
  final String title;
  final TaskType taskType;

  @override
  Map<String, dynamic> toMap() => {
        'dateTime': dateTime.toIso8601String(),
        'description': description,
        'title': title,
        'taskType': taskType.toString(),
      };

  @override
  List<Object?> get props => [dateTime, description, title, taskType];
}
