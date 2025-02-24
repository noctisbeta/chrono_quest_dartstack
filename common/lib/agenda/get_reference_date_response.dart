import 'package:common/abstractions/models.dart';
import 'package:common/agenda/reference_date_error.dart';
import 'package:common/exceptions/bad_map_shape_exception.dart';
import 'package:common/exceptions/response_exception.dart';
import 'package:meta/meta.dart';

@immutable
sealed class GetReferenceDateResponse extends ResponseDTO {
  const GetReferenceDateResponse();
}

@immutable
final class GetReferenceDateResponseSuccess extends GetReferenceDateResponse {
  const GetReferenceDateResponseSuccess({required this.referenceDate});

  factory GetReferenceDateResponseSuccess.validatedFromMap(
    Map<String, dynamic> map,
  ) => switch (map) {
    {'referenceDate': final String dateString} =>
      GetReferenceDateResponseSuccess(
        referenceDate: DateTime.parse(dateString),
      ),
    _ =>
      throw const BadMapShapeException(
        'Invalid map format for GetReferenceDateResponseSuccess.',
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
  GetReferenceDateResponseSuccess copyWith({DateTime? referenceDate}) =>
      GetReferenceDateResponseSuccess(
        referenceDate: referenceDate ?? this.referenceDate,
      );
}

@immutable
final class GetReferenceDateResponseError extends GetReferenceDateResponse {
  const GetReferenceDateResponseError({
    required this.message,
    required this.error,
  });

  factory GetReferenceDateResponseError.validatedFromMap(
    Map<String, dynamic> map,
  ) => switch (map) {
    {'message': final String message, 'error': final String error} =>
      GetReferenceDateResponseError(
        message: message,
        error: ReferenceDateError.fromString(error),
      ),
    _ =>
      throw const BadResponseBodyException(
        'Invalid map format for GetReferenceDateResponseError',
      ),
  };

  final String message;
  final ReferenceDateError error;

  @override
  Map<String, dynamic> toMap() => {
    'message': message,
    'error': error.toString(),
  };

  @override
  List<Object?> get props => [message, error];

  @override
  GetReferenceDateResponseError copyWith({
    String? message,
    ReferenceDateError? error,
  }) => GetReferenceDateResponseError(
    message: message ?? this.message,
    error: error ?? this.error,
  );
}
