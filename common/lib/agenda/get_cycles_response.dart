import 'package:common/abstractions/models.dart';
import 'package:common/agenda/cycle.dart';
import 'package:common/exceptions/bad_map_shape_exception.dart';
import 'package:common/exceptions/throws.dart';
import 'package:meta/meta.dart';

@immutable
sealed class GetCyclesResponse extends Response {
  const GetCyclesResponse();
}

@immutable
final class GetCyclesResponseSuccess extends GetCyclesResponse {
  const GetCyclesResponseSuccess({required this.cycles});

  @Throws([BadMapShapeException])
  factory GetCyclesResponseSuccess.validatedFromMap(Map<String, dynamic> map) =>
      switch (map) {
        {'cycles': final List<dynamic> cycles} => GetCyclesResponseSuccess(
          cycles: cycles.map((cycle) => Cycle.validatedFromMap(cycle)).toList(),
        ),
        _ =>
          throw const BadMapShapeException(
            'Invalid map format for GetCyclesResponseSuccess',
          ),
      };

  final List<Cycle> cycles;

  @override
  List<Object?> get props => [cycles];

  @override
  Map<String, dynamic> toMap() => {
    'cycles': cycles.map((cycle) => cycle.toMap()).toList(),
  };
}

@immutable
final class GetCyclesResponseError extends GetCyclesResponse {
  const GetCyclesResponseError({required this.message});

  @Throws([BadMapShapeException])
  factory GetCyclesResponseError.validatedFromMap(Map<String, dynamic> map) =>
      switch (map) {
        {'message': final String message} => GetCyclesResponseError(
          message: message,
        ),
        _ =>
          throw const BadMapShapeException(
            'Invalid map format for GetCyclesResponseError',
          ),
      };

  final String message;

  @override
  List<Object?> get props => [message];

  @override
  Map<String, dynamic> toMap() => {'message': message};
}
