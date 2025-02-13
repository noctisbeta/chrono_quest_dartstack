import 'package:common/abstractions/models.dart';
import 'package:common/exceptions/bad_map_shape_exception.dart';
import 'package:common/exceptions/throws.dart';
import 'package:meta/meta.dart';

@immutable
final class EncryptedGetCyclesRequest extends Request {
  const EncryptedGetCyclesRequest({required this.dateTime});

  @Throws([BadMapShapeException])
  factory EncryptedGetCyclesRequest.validatedFromMap(
    Map<String, dynamic> map,
  ) => switch (map) {
    {'date_time': final String dateTime} => EncryptedGetCyclesRequest(
      dateTime: dateTime,
    ),
    _ =>
      throw const BadMapShapeException(
        'Invalid map format for EncryptedGetCyclesRequest.',
      ),
  };

  final String dateTime;

  @override
  List<Object?> get props => [dateTime];

  @override
  Map<String, dynamic> toMap() => {'date_time': dateTime};
}
