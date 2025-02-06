import 'package:common/abstractions/models.dart';
import 'package:common/agenda/duration_type.dart';
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
    required this.repeatAmount,
    required this.repeatDurationType,
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
          'repeat_amount': final int repeatAmount,
          'repeat_duration_type': final String repeatDurationType,
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
            repeatAmount: repeatAmount,
            repeatDurationType: DurationType.values.byName(repeatDurationType),
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
  final int repeatAmount;
  final DurationType repeatDurationType;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'start_time': startTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
        'note': note,
        'title': title,
        'repeat_amount': repeatAmount.toString(),
        'repeat_duration_type': repeatDurationType.name,
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
        repeatAmount,
        repeatDurationType,
        createdAt,
        updatedAt,
      ];
}
