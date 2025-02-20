import 'package:common/abstractions/models.dart';
import 'package:common/agenda/add_cycle_error.dart';
import 'package:common/agenda/cycle.dart';
import 'package:common/exceptions/bad_map_shape_exception.dart';
import 'package:common/exceptions/response_exception.dart';
import 'package:meta/meta.dart';

@immutable
sealed class AddCycleResponse extends RequestDTO {
  const AddCycleResponse();
}

@immutable
final class AddCycleResponseSuccess extends AddCycleResponse {
  const AddCycleResponseSuccess({required this.cycle});

  factory AddCycleResponseSuccess.validatedFromMap(Map<String, dynamic> map) =>
      switch (map) {
        {'cycle': final Map<String, dynamic> cycleMap} =>
          AddCycleResponseSuccess(cycle: Cycle.validatedFromMap(cycleMap)),
        _ =>
          throw const BadMapShapeException(
            'Invalid map format for AddCycleResponseSuccess.',
          ),
      };

  final Cycle cycle;

  @override
  Map<String, dynamic> toMap() => {'cycle': cycle.toMap()};

  @override
  List<Object?> get props => [cycle];
}

@immutable
final class AddCycleResponseError extends AddCycleResponse {
  const AddCycleResponseError({required this.message, required this.error});

  factory AddCycleResponseError.validatedFromMap(Map<String, dynamic> map) =>
      switch (map) {
        {'message': final String message, 'error': final String error} =>
          AddCycleResponseError(
            message: message,
            error: AddCycleError.fromString(error),
          ),
        _ =>
          throw const BadResponseBodyException(
            'Invalid map format for AddCycleResponseError',
          ),
      };

  final String message;

  final AddCycleError error;

  @override
  Map<String, dynamic> toMap() => {
    'message': message,
    'error': error.toString(),
  };

  @override
  List<Object?> get props => [message, error];
}
