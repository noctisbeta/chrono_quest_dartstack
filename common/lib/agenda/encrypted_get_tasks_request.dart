import 'package:common/abstractions/models.dart';
import 'package:common/exceptions/bad_map_shape_exception.dart';
import 'package:common/exceptions/throws.dart';
import 'package:meta/meta.dart';

@immutable
final class EncryptedGetTasksRequest extends Request {
  const EncryptedGetTasksRequest({
    required this.dateTime,
  });

  @Throws([BadMapShapeException])
  factory EncryptedGetTasksRequest.validatedFromMap(Map<String, dynamic> map) =>
      switch (map) {
        {
          'date_time': final String dateTime,
        } =>
          EncryptedGetTasksRequest(
            dateTime: dateTime,
          ),
        _ => throw const BadMapShapeException(
            'Invalid map format for EncryptedGetTasksRequest.',
          ),
      };

  final String dateTime;

  @override
  List<Object?> get props => [dateTime];

  @override
  Map<String, dynamic> toMap() => {
        'date_time': dateTime,
      };
}
