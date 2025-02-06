import 'package:common/abstractions/models.dart';
import 'package:common/agenda/task_repetition.dart';
import 'package:common/exceptions/bad_map_shape_exception.dart';
import 'package:meta/meta.dart';

@immutable
final class Task extends DataModel {
  const Task({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.note,
    required this.title,
    required this.taskRepetition,
  });

  factory Task.validatedFromMap(Map<String, dynamic> map) => switch (map) {
        {
          'id': final int id,
          'startTime': final String startTime,
          'endTime': final String endTime,
          'note': final String note,
          'title': final String title,
          'taskRepetition': final Map<String, dynamic> taskRepetition,
        } =>
          Task(
            id: id,
            startTime: DateTime.parse(startTime),
            endTime: DateTime.parse(endTime),
            note: note,
            title: title,
            taskRepetition: TaskRepetition.validatedFromMap(taskRepetition),
          ),
        _ => throw const BadMapShapeException('Invalid map format for Task'),
      };

  final int id;
  final DateTime startTime;
  final DateTime endTime;
  final String note;
  final String title;
  final TaskRepetition taskRepetition;

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'note': note,
        'title': title,
        'taskRepetition': taskRepetition.toMap(),
      };

  @override
  List<Object?> get props => [
        id,
        startTime,
        endTime,
        note,
        title,
        taskRepetition,
      ];
}
