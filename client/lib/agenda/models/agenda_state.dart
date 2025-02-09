import 'package:common/agenda/cycle.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show immutable;

@immutable
sealed class AgendaState extends Equatable {
  const AgendaState({
    required this.cycles,
  });

  final List<Cycle> cycles;

  @override
  List<Object?> get props => [cycles];
}

@immutable
final class AgendaStateInitial extends AgendaState {
  const AgendaStateInitial()
      : super(
          cycles: const [],
        );
}

@immutable
final class AgendaStateLoaded extends AgendaState {
  const AgendaStateLoaded({
    required super.cycles,
  });
}

@immutable
final class AgendaStateAddCycleLoading extends AgendaState {
  const AgendaStateAddCycleLoading({
    required super.cycles,
  });
}

@immutable
final class AgendaStateAddCycleError extends AgendaState {
  const AgendaStateAddCycleError({
    required this.message,
    required super.cycles,
  });

  final String message;

  @override
  List<Object?> get props => [message, cycles];
}
