import 'package:common/abstractions/models.dart';
import 'package:common/agenda/add_cycle_error.dart';
import 'package:common/exceptions/bad_map_shape_exception.dart';
import 'package:common/exceptions/response_exception.dart';
import 'package:meta/meta.dart';

@immutable
sealed class EncryptedAddCycleResponse extends RequestDTO {
  const EncryptedAddCycleResponse();
}

@immutable
final class EncryptedAddCycleResponseSuccess extends EncryptedAddCycleResponse {
  const EncryptedAddCycleResponseSuccess({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.note,
    required this.title,
    required this.cycleRepetition,
  });

  factory EncryptedAddCycleResponseSuccess.validatedFromMap(
    Map<String, dynamic> map,
  ) => switch (map) {
    {
      'id': final int id,
      'start_time': final String startTime,
      'end_time': final String endTime,
      'note': final String note,
      'title': final String title,
      'cycle_repetition': final String cycleRepetition,
    } =>
      EncryptedAddCycleResponseSuccess(
        id: id,
        startTime: startTime,
        endTime: endTime,
        note: note,
        title: title,
        cycleRepetition: cycleRepetition,
      ),
    _ =>
      throw const BadMapShapeException(
        'Invalid map format for EncryptedAddCycleResponseSuccess.',
      ),
  };

  final int id;
  final String startTime;
  final String endTime;
  final String note;
  final String title;
  final String cycleRepetition;

  @override
  Map<String, dynamic> toMap() => {
    'id': id,
    'start_time': startTime,
    'end_time': endTime,
    'note': note,
    'title': title,
    'cycle_repetition': cycleRepetition,
  };

  @override
  List<Object?> get props => [
    id,
    startTime,
    endTime,
    note,
    title,
    cycleRepetition,
  ];

  @override
  EncryptedAddCycleResponseSuccess copyWith({
    int? id,
    String? startTime,
    String? endTime,
    String? note,
    String? title,
    String? cycleRepetition,
  }) => EncryptedAddCycleResponseSuccess(
    id: id ?? this.id,
    startTime: startTime ?? this.startTime,
    endTime: endTime ?? this.endTime,
    note: note ?? this.note,
    title: title ?? this.title,
    cycleRepetition: cycleRepetition ?? this.cycleRepetition,
  );
}

@immutable
final class EncryptedAddCycleResponseError extends EncryptedAddCycleResponse {
  const EncryptedAddCycleResponseError({
    required this.message,
    required this.error,
  });

  factory EncryptedAddCycleResponseError.validatedFromMap(
    Map<String, dynamic> map,
  ) => switch (map) {
    {'message': final String message, 'error': final String error} =>
      EncryptedAddCycleResponseError(
        message: message,
        error: AddCycleError.fromString(error),
      ),
    _ =>
      throw const BadResponseBodyException(
        'Invalid map format for EncryptedAddCycleResponseError',
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

  @override
  EncryptedAddCycleResponseError copyWith({
    String? message,
    AddCycleError? error,
  }) => EncryptedAddCycleResponseError(
    message: message ?? this.message,
    error: error ?? this.error,
  );
}
