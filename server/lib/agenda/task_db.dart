import 'package:common/abstractions/models.dart';
import 'package:common/agenda/task_type.dart';
import 'package:common/exceptions/throws.dart';
import 'package:meta/meta.dart';
import 'package:server/postgres/exceptions/database_exception.dart';

@immutable
final class TaskDB extends DataModel {
  const TaskDB({
    required this.id,
    required this.userId,
    required this.startTime,
    required this.endTime,
    required this.note,
    required this.title,
    required this.taskType,
    required this.createdAt,
    required this.updatedAt,
  });

  @Throws([DBEbadSchema])
  factory TaskDB.validatedFromMap(Map<String, dynamic> map) => switch (map) {
        {
          'id': final int id,
          'user_id': final int userId,
          'start_time': final DateTime startTime,
          'end_time': final DateTime endTime,
          'note': final String note,
          'title': final String title,
          'task_type': final String taskType,
          'created_at': final DateTime createdAt,
          'updated_at': final DateTime updatedAt,
        } =>
          TaskDB(
            id: id,
            userId: userId,
            startTime: startTime,
            endTime: endTime,
            note: note,
            title: title,
            taskType: TaskType.fromString(taskType),
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
        _ => throw const DBEbadSchema('Invalid shape for TaskDB.'),
      };

  final int id;
  final int userId;
  final DateTime startTime;
  final DateTime endTime;
  final String note;
  final String title;
  final TaskType taskType;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'note': note,
        'title': title,
        'taskType': taskType.toString(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [
        id,
        userId,
        startTime,
        endTime,
        note,
        title,
        taskType,
        createdAt,
        updatedAt,
      ];
}
