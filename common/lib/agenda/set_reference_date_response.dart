import 'package:common/abstractions/models.dart';
import 'package:common/exceptions/bad_map_shape_exception.dart';
import 'package:common/exceptions/response_exception.dart';
import 'package:meta/meta.dart';

@immutable
sealed class SetReferenceDateResponse extends ResponseDTO {
  const SetReferenceDateResponse();
}

@immutable
final class SetReferenceDateResponseSuccess extends SetReferenceDateResponse {
  const SetReferenceDateResponseSuccess({required this.referenceDate});

  factory SetReferenceDateResponseSuccess.validatedFromMap(
    Map<String, dynamic> map,
  ) => switch (map) {
    {'referenceDate': final String dateString} =>
      SetReferenceDateResponseSuccess(
        referenceDate: DateTime.parse(dateString),
      ),
    _ =>
      throw const BadMapShapeException(
        'Invalid map format for SetReferenceDateResponseSuccess.',
      ),
  };

  final DateTime referenceDate;

  @override
  Map<String, dynamic> toMap() => {
    'referenceDate': referenceDate.toIso8601String(),
  };

  @override
  List<Object?> get props => [referenceDate];

  @override
  SetReferenceDateResponseSuccess copyWith({DateTime? referenceDate}) =>
      SetReferenceDateResponseSuccess(
        referenceDate: referenceDate ?? this.referenceDate,
      );
}

@immutable
final class SetReferenceDateResponseError extends SetReferenceDateResponse {
  const SetReferenceDateResponseError({
    required this.message,
    required this.error,
  });

  factory SetReferenceDateResponseError.validatedFromMap(
    Map<String, dynamic> map,
  ) => switch (map) {
    {'message': final String message, 'error': final String error} =>
      SetReferenceDateResponseError(message: message, error: error),
    _ =>
      throw const BadResponseBodyException(
        'Invalid map format for SetReferenceDateResponseError',
      ),
  };

  final String message;
  final String error;

  @override
  Map<String, dynamic> toMap() => {'message': message, 'error': error};

  @override
  List<Object?> get props => [message, error];

  @override
  SetReferenceDateResponseError copyWith({String? message, String? error}) =>
      SetReferenceDateResponseError(
        message: message ?? this.message,
        error: error ?? this.error,
      );
}
