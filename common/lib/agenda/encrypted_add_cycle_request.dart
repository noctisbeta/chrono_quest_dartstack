import 'package:common/abstractions/models.dart';
import 'package:common/exceptions/bad_map_shape_exception.dart';
import 'package:meta/meta.dart';

@immutable
final class EncryptedAddCycleRequest extends RequestDTO {
  const EncryptedAddCycleRequest({
    required this.startTime,
    required this.endTime,
    required this.note,
    required this.title,
    required this.period,
  });

  factory EncryptedAddCycleRequest.validatedFromMap(Map<String, dynamic> map) =>
      switch (map) {
        {
          'start_time': final String startTime,
          'end_time': final String endTime,
          'note': final String note,
          'title': final String title,
          'period': final String period,
        } =>
          EncryptedAddCycleRequest(
            startTime: startTime,
            endTime: endTime,
            note: note,
            title: title,
            period: period,
          ),
        _ =>
          throw const BadMapShapeException(
            'Invalid map format for EncryptedAddCycleRequest.',
          ),
      };

  final String startTime;
  final String endTime;
  final String note;
  final String title;
  final String period;

  @override
  Map<String, dynamic> toMap() => {
    'start_time': startTime,
    'end_time': endTime,
    'note': note,
    'title': title,
    'period': period,
  };

  @override
  List<Object?> get props => [startTime, endTime, note, title, period];

  @override
  EncryptedAddCycleRequest copyWith({
    String? startTime,
    String? endTime,
    String? note,
    String? title,
    String? period,
  }) => EncryptedAddCycleRequest(
    startTime: startTime ?? this.startTime,
    endTime: endTime ?? this.endTime,
    note: note ?? this.note,
    title: title ?? this.title,
    period: period ?? this.period,
  );
}
