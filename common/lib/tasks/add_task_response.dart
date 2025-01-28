import 'package:common/abstractions/models.dart';
import 'package:common/exceptions/bad_map_shape_exception.dart';
import 'package:common/tasks/task_type.dart';
import 'package:meta/meta.dart';

@immutable
final class AddTaskResponse extends Request {
  const AddTaskResponse({
    required this.id,
    required this.dateTime,
    required this.description,
    required this.title,
    required this.taskType,
  });

  factory AddTaskResponse.validatedFromMap(Map<String, dynamic> map) =>
      switch (map) {
        {
          'id': final int id,
          'dateTime': final String dateTime,
          'description': final String description,
          'title': final String title,
          'taskType': final String taskType,
        } =>
          AddTaskResponse(
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
