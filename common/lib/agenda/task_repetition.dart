import 'package:common/abstractions/models.dart';
import 'package:common/agenda/duration_type.dart';
import 'package:common/exceptions/bad_map_shape_exception.dart';
import 'package:common/exceptions/throws.dart';
import 'package:meta/meta.dart';

@immutable
final class TaskRepetition extends DataModel {
  const TaskRepetition({
    required this.amount,
    required this.durationType,
  });

  @Throws([BadMapShapeException])
  factory TaskRepetition.validatedFromMap(Map<String, dynamic> map) =>
      switch (map) {
        {
          'amount': final int amount,
          'durationType': final String durationType,
        } =>
          TaskRepetition(
            amount: amount,
            durationType: DurationType.fromString(durationType),
          ),
        _ => throw const BadMapShapeException(
            'Invalid map format for TaskRepetition',
          ),
      };

  final int amount;

  final DurationType durationType;

  @override
  List<Object?> get props => [amount, durationType];

  @override
  Map<String, dynamic> toMap() => {
        'amount': amount,
        'durationType': durationType.name,
      };
}
