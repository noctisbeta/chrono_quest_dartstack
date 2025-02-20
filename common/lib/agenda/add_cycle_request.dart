import 'package:common/abstractions/models.dart';
import 'package:common/exceptions/bad_map_shape_exception.dart';
import 'package:meta/meta.dart';

@immutable
final class AddCycleRequest extends RequestDTO {
  const AddCycleRequest({
    required this.startTime,
    required this.endTime,
    required this.note,
    required this.title,
    required this.period,
  });

  factory AddCycleRequest.validatedFromMap(Map<String, dynamic> map) =>
      switch (map) {
        {
          'start_time': final String startTime,
          'end_time': final String endTime,
          'note': final String note,
          'title': final String title,
          'period': final int period,
        } =>
          AddCycleRequest(
            startTime: DateTime.parse(startTime),
            endTime: DateTime.parse(endTime),
            note: note,
            title: title,
            period: period,
          ),
        _ =>
          throw const BadMapShapeException(
            'Invalid map format for AddCycleRequest.',
          ),
      };

  final DateTime startTime;
  final DateTime endTime;
  final String note;
  final String title;
  final int period;

  @override
  Map<String, dynamic> toMap() => {
    'start_time': startTime.toIso8601String(),
    'end_time': endTime.toIso8601String(),
    'note': note,
    'title': title,
    'period': period,
  };

  @override
  List<Object?> get props => [startTime, endTime, note, title, period];
}
