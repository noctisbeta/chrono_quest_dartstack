import 'package:common/abstractions/models.dart';
import 'package:common/exceptions/bad_map_shape_exception.dart';
import 'package:common/exceptions/throws.dart';
import 'package:meta/meta.dart';

@immutable
final class GetTasksRequest extends Request {
  const GetTasksRequest({
    required this.dateTime,
  });

  @Throws([BadMapShapeException])
  factory GetTasksRequest.validatedFromMap(Map<String, dynamic> map) =>
      switch (map) {
        {
          'dateTime': final String dateTime,
        } =>
          GetTasksRequest(
            dateTime: DateTime.parse(dateTime),
          ),
        _ => throw const BadMapShapeException(
            'Invalid map format for GetTasksRequest.',
          ),
      };

  final DateTime dateTime;

  @override
  List<Object?> get props => [dateTime];

  @override
  Map<String, dynamic> toMap() => {
        'dateTime': dateTime.toIso8601String(),
      };
}
