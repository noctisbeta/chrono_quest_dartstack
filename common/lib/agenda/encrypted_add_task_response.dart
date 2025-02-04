import 'package:common/abstractions/models.dart';
import 'package:common/exceptions/bad_map_shape_exception.dart';
import 'package:meta/meta.dart';

@immutable
final class EncryptedAddTaskResponse extends Response {
  const EncryptedAddTaskResponse({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.note,
    required this.title,
    required this.taskType,
  });

  factory EncryptedAddTaskResponse.validatedFromMap(Map<String, dynamic> map) =>
      switch (map) {
        {
          'id': final int id,
          'startTime': final String startTime,
          'endTime': final String endTime,
          'note': final String note,
          'title': final String title,
          'taskType': final String taskType,
        } =>
          EncryptedAddTaskResponse(
            id: id,
            startTime: startTime,
            endTime: endTime,
            note: note,
            title: title,
            taskType: taskType,
          ),
        _ => throw const BadMapShapeException(
            'Invalid map format for EncryptedAddTaskRequest.',
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
