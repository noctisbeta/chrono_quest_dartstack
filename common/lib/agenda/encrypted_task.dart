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
    required this.taskType,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EncryptedTask.validatedFromMap(Map<String, dynamic> map) =>
      switch (map) {
        {
          'id': final int id,
          'startTime': final String startTime,
          'endTime': final String endTime,
          'note': final String note,
          'title': final String title,
          'taskType': final String taskType,
          'createdAt': final String createdAt,
          'updatedAt': final String updatedAt,
        } =>
          EncryptedTask(
            id: id,
            startTime: startTime,
            endTime: endTime,
            note: note,
            title: title,
            taskType: taskType,
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
  final String taskType;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'startTime': startTime,
        'endTime': endTime,
        'note': note,
        'title': title,
        'taskType': taskType,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [
        id,
        startTime,
        endTime,
        note,
        title,
        taskType,
        createdAt,
        updatedAt,
      ];
}
