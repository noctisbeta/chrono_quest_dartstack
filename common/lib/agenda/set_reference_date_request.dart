import 'package:common/abstractions/models.dart';
import 'package:common/exceptions/bad_map_shape_exception.dart';
import 'package:meta/meta.dart';

@immutable
final class SetReferenceDateRequest extends Request {
  const SetReferenceDateRequest({required this.referenceDate});

  factory SetReferenceDateRequest.validatedFromMap(Map<String, dynamic> map) =>
      switch (map) {
        {'reference_date': final String referenceDate} =>
          SetReferenceDateRequest(referenceDate: DateTime.parse(referenceDate)),
        _ =>
          throw const BadMapShapeException(
            'Invalid map format for SetReferenceDateRequest.',
          ),
      };

  final DateTime referenceDate;

  @override
  Map<String, dynamic> toMap() => {
    'reference_date': referenceDate.toIso8601String(),
  };

  @override
  List<Object?> get props => [referenceDate];
}
