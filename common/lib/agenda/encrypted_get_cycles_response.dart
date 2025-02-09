import 'package:common/abstractions/models.dart';
import 'package:common/agenda/encrypted_cycle.dart';
import 'package:common/exceptions/bad_map_shape_exception.dart';
import 'package:common/exceptions/throws.dart';
import 'package:meta/meta.dart';

@immutable
sealed class EncryptedGetCyclesResponse extends Response {
  const EncryptedGetCyclesResponse();
}

@immutable
final class EncryptedGetCyclesResponseSuccess
    extends EncryptedGetCyclesResponse {
  const EncryptedGetCyclesResponseSuccess({
    required this.cycles,
  });

  @Throws([BadMapShapeException])
  factory EncryptedGetCyclesResponseSuccess.validatedFromMap(
    Map<String, dynamic> map,
  ) =>
      switch (map) {
        {
          'cycles': final List<dynamic> cycles,
        } =>
          EncryptedGetCyclesResponseSuccess(
            cycles: cycles
                .map((cycle) => EncryptedCycle.validatedFromMap(cycle))
                .toList(),
          ),
        _ => throw const BadMapShapeException(
            'Invalid map format for EncryptedGetCyclesResponseSuccess',
          ),
      };

  final List<EncryptedCycle> cycles;

  @override
  List<Object?> get props => [cycles];

  @override
  Map<String, dynamic> toMap() => {
        'cycles': cycles.map((cycle) => cycle.toMap()).toList(),
      };
}

@immutable
final class EncryptedGetCyclesResponseError extends EncryptedGetCyclesResponse {
  const EncryptedGetCyclesResponseError({
    required this.message,
  });

  @Throws([BadMapShapeException])
  factory EncryptedGetCyclesResponseError.validatedFromMap(
    Map<String, dynamic> map,
  ) =>
      switch (map) {
        {
          'message': final String message,
        } =>
          EncryptedGetCyclesResponseError(
            message: message,
          ),
        _ => throw const BadMapShapeException(
            'Invalid map format for EncryptedGetCyclesResponseError',
          ),
      };

  final String message;

  @override
  List<Object?> get props => [message];

  @override
  Map<String, dynamic> toMap() => {
        'message': message,
      };
}
