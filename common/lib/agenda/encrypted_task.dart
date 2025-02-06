import 'package:common/abstractions/models.dart';
import 'package:common/exceptions/bad_map_shape_exception.dart';
import 'package:meta/meta.dart';

@immutable
final class EncryptedTask extends DataModel {
  const EncryptedTask({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.note,
    required this.title,
    required this.taskRepetition,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EncryptedTask.validatedFromMap(Map<String, dynamic> map) =>
      switch (map) {
        {
          'id': final int id,
          'start_time': final String startTime,
          'end_time': final String endTime,
          'note': final String note,
          'title': final String title,
          'task_repetition': final String taskRepetition,
          'created_at': final String createdAt,
          'updated_at': final String updatedAt,
        } =>
          EncryptedTask(
            id: id,
            startTime: startTime,
            endTime: endTime,
            note: note,
            title: title,
            taskRepetition: taskRepetition,
            createdAt: DateTime.parse(createdAt),
            updatedAt: DateTime.parse(updatedAt),
          ),
        _ => throw const BadMapShapeException(
            'Invalid map format for EncryptedTask',
          ),
      };

  final int id;
  final String startTime;
  final String endTime;
  final String note;
  final String title;
  final String taskRepetition;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'start_time': startTime,
        'end_time': endTime,
        'note': note,
        'title': title,
        'task_repetition': taskRepetition,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [
        id,
        startTime,
        endTime,
        note,
        title,
        taskRepetition,
        createdAt,
        updatedAt,
      ];
}
