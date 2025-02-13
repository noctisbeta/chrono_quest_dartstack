import 'package:common/abstractions/models.dart';
import 'package:common/exceptions/throws.dart';
import 'package:meta/meta.dart';
import 'package:server/postgres/exceptions/database_exception.dart';

@immutable
final class CycleDB extends DataModel {
  const CycleDB({
    required this.id,
    required this.userId,
    required this.startTime,
    required this.endTime,
    required this.note,
    required this.title,
    required this.period,
    required this.createdAt,
    required this.updatedAt,
  });

  @Throws([DBEbadSchema])
  factory CycleDB.validatedFromMap(Map<String, dynamic> map) => switch (map) {
    {
      'id': final int id,
      'user_id': final int userId,
      'start_time': final DateTime startTime,
      'end_time': final DateTime endTime,
      'note': final String note,
      'title': final String title,
      'period': final int period,
      'created_at': final DateTime createdAt,
      'updated_at': final DateTime updatedAt,
    } =>
      CycleDB(
        id: id,
        userId: userId,
        startTime: startTime,
        endTime: endTime,
        note: note,
        title: title,
        period: period,
        createdAt: createdAt,
        updatedAt: updatedAt,
      ),
    _ => throw const DBEbadSchema('Invalid shape for CycleDB.'),
  };

  final int id;
  final int userId;
  final DateTime startTime;
  final DateTime endTime;
  final String note;
  final String title;
  final int period;
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
    'period': period.toString(),
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
    period,
    createdAt,
    updatedAt,
  ];
}
