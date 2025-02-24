import 'package:common/abstractions/models.dart';
import 'package:common/exceptions/bad_map_shape_exception.dart';
import 'package:meta/meta.dart';

@immutable
final class Cycle extends DataModel {
  const Cycle({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.note,
    required this.title,
    required this.period,
  });

  factory Cycle.validatedFromMap(Map<String, dynamic> map) => switch (map) {
    {
      'id': final int id,
      'startTime': final String startTime,
      'endTime': final String endTime,
      'note': final String note,
      'title': final String title,
      'period': final int period,
    } =>
      Cycle(
        id: id,
        startTime: DateTime.parse(startTime),
        endTime: DateTime.parse(endTime),
        note: note,
        title: title,
        period: period,
      ),
    _ => throw const BadMapShapeException('Invalid map format for Cycle'),
  };

  final int id;
  final DateTime startTime;
  final DateTime endTime;
  final String note;
  final String title;
  final int period;

  @override
  Map<String, dynamic> toMap() => {
    'id': id,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime.toIso8601String(),
    'note': note,
    'title': title,
    'period': period,
  };

  @override
  List<Object?> get props => [id, startTime, endTime, note, title, period];

  @override
  Cycle copyWith({
    int? id,
    DateTime? startTime,
    DateTime? endTime,
    String? note,
    String? title,
    int? period,
  }) => Cycle(
    id: id ?? this.id,
    startTime: startTime ?? this.startTime,
    endTime: endTime ?? this.endTime,
    note: note ?? this.note,
    title: title ?? this.title,
    period: period ?? this.period,
  );
}
