import 'package:common/abstractions/models.dart';
import 'package:common/exceptions/throws.dart';
import 'package:meta/meta.dart';
import 'package:server/postgres/exceptions/database_exception.dart';

@immutable
final class EncryptedTaskDB extends DataModel {
  const EncryptedTaskDB({
    required this.id,
    required this.userId,
    required this.startTime,
    required this.endTime,
    required this.note,
    required this.title,
    required this.taskRepetition,
    required this.createdAt,
    required this.updatedAt,
  });

  @Throws([DBEbadSchema])
  factory EncryptedTaskDB.validatedFromMap(Map<String, dynamic> map) =>
      switch (map) {
        {
          'id': final int id,
          'user_id': final int userId,
          'start_time': final String startTime,
          'end_time': final String endTime,
          'note': final String note,
          'title': final String title,
          'task_repetition': final String taskRepetition,
          'created_at': final DateTime createdAt,
          'updated_at': final DateTime updatedAt,
        } =>
          EncryptedTaskDB(
            id: id,
            userId: userId,
            startTime: startTime,
            endTime: endTime,
            note: note,
            title: title,
            taskRepetition: taskRepetition,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
        _ =>
          throw const DBEbadSchema('Invalid map format for EncryptedTaskDB.'),
      };

  final int id;
  final int userId;
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
        'user_id': userId,
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
        userId,
        startTime,
        endTime,
        note,
        title,
        taskRepetition,
        createdAt,
        updatedAt,
      ];
}
