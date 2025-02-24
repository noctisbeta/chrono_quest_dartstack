import 'package:common/abstractions/models.dart';
import 'package:common/exceptions/bad_map_shape_exception.dart';
import 'package:common/exceptions/throws.dart';
import 'package:meta/meta.dart';

@immutable
final class GetCyclesRequest extends RequestDTO {
  const GetCyclesRequest({required this.dateTime});

  @Throws([BadMapShapeException])
  factory GetCyclesRequest.validatedFromMap(Map<String, dynamic> map) =>
      switch (map) {
        {'date_time': final String dateTime} => GetCyclesRequest(
          dateTime: DateTime.parse(dateTime),
        ),
        _ =>
          throw const BadMapShapeException(
            'Invalid map format for GetCyclesRequest.',
          ),
      };

  final DateTime dateTime;

  @override
  List<Object?> get props => [dateTime];

  @override
  Map<String, dynamic> toMap() => {'date_time': dateTime.toIso8601String()};

  @override
  GetCyclesRequest copyWith({DateTime? dateTime}) =>
      GetCyclesRequest(dateTime: dateTime ?? this.dateTime);
}
