import 'package:common/abstractions/models.dart';
import 'package:common/exceptions/throws.dart';
import 'package:meta/meta.dart';
import 'package:server/postgres/exceptions/database_exception.dart';

@immutable
final class EncryptedCycleDB extends DataModel {
  const EncryptedCycleDB({
    required this.id,
    required this.userId,
    required this.startTime,
    required this.endTime,
    required this.note,
    required this.title,
    required this.cycleRepetition,
    required this.createdAt,
    required this.updatedAt,
  });

  @Throws([DBEbadSchema])
  factory EncryptedCycleDB.validatedFromMap(
    Map<String, dynamic> map,
  ) => switch (map) {
    {
      'id': final int id,
      'user_id': final int userId,
      'start_time': final String startTime,
      'end_time': final String endTime,
      'note': final String note,
      'title': final String title,
      'cycle_repetition': final String cycleRepetition,
      'created_at': final DateTime createdAt,
      'updated_at': final DateTime updatedAt,
    } =>
      EncryptedCycleDB(
        id: id,
        userId: userId,
        startTime: startTime,
        endTime: endTime,
        note: note,
        title: title,
        cycleRepetition: cycleRepetition,
        createdAt: createdAt,
        updatedAt: updatedAt,
      ),
    _ => throw const DBEbadSchema('Invalid map format for EncryptedCycleDB.'),
  };

  final int id;
  final int userId;
  final String startTime;
  final String endTime;
  final String note;
  final String title;
  final String cycleRepetition;
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
    'cycle_repetition': cycleRepetition,
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
    cycleRepetition,
    createdAt,
    updatedAt,
  ];

  @override
  EncryptedCycleDB copyWith({
    int? id,
    int? userId,
    String? startTime,
    String? endTime,
    String? note,
    String? title,
    String? cycleRepetition,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => EncryptedCycleDB(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    startTime: startTime ?? this.startTime,
    endTime: endTime ?? this.endTime,
    note: note ?? this.note,
    title: title ?? this.title,
    cycleRepetition: cycleRepetition ?? this.cycleRepetition,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
