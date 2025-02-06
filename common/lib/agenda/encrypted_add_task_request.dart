import 'package:common/abstractions/models.dart';
import 'package:common/exceptions/bad_map_shape_exception.dart';
import 'package:meta/meta.dart';

@immutable
final class EncryptedAddTaskRequest extends Request {
  const EncryptedAddTaskRequest({
    required this.startTime,
    required this.endTime,
    required this.note,
    required this.title,
    required this.taskRepetition,
  });

  factory EncryptedAddTaskRequest.validatedFromMap(Map<String, dynamic> map) =>
      switch (map) {
        {
          'start_time': final String startTime,
          'end_time': final String endTime,
          'note': final String note,
          'title': final String title,
          'task_repetition': final String taskRepetition,
        } =>
          EncryptedAddTaskRequest(
            startTime: startTime,
            endTime: endTime,
            note: note,
            title: title,
            taskRepetition: taskRepetition,
          ),
        _ => throw const BadMapShapeException(
            'Invalid map format for EncryptedAddTaskRequest.',
          ),
      };

  final String startTime;
  final String endTime;
  final String note;
  final String title;
  final String taskRepetition;

  @override
  Map<String, dynamic> toMap() => {
        'start_time': startTime,
        'end_time': endTime,
        'note': note,
        'title': title,
        'task_repetition': taskRepetition,
      };

  @override
  List<Object?> get props => [startTime, endTime, note, title, taskRepetition];
}
