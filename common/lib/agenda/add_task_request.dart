import 'package:common/abstractions/models.dart';
import 'package:common/agenda/task_repetition.dart';
import 'package:common/exceptions/bad_map_shape_exception.dart';
import 'package:meta/meta.dart';

@immutable
final class AddTaskRequest extends Request {
  const AddTaskRequest({
    required this.startTime,
    required this.endTime,
    required this.note,
    required this.title,
    required this.taskRepetition,
  });

  factory AddTaskRequest.validatedFromMap(Map<String, dynamic> map) =>
      switch (map) {
        {
          'start_time': final String startTime,
          'end_time': final String endTime,
          'note': final String note,
          'title': final String title,
          'task_repetition': final Map<String, dynamic> taskRepetition,
        } =>
          AddTaskRequest(
            startTime: DateTime.parse(startTime),
            endTime: DateTime.parse(endTime),
            note: note,
            title: title,
            taskRepetition: TaskRepetition.validatedFromMap(taskRepetition),
          ),
        _ => throw const BadMapShapeException(
            'Invalid map format for AddTaskRequest.',
          ),
      };

  final DateTime startTime;
  final DateTime endTime;
  final String note;
  final String title;
  final TaskRepetition taskRepetition;

  @override
  Map<String, dynamic> toMap() => {
        'start_time': startTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
        'note': note,
        'title': title,
        'task_repetition': taskRepetition.toMap(),
      };

  @override
  List<Object?> get props => [startTime, endTime, note, title, taskRepetition];
}
