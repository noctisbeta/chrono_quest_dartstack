import 'package:common/agenda/cycle.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show immutable;

@immutable
sealed class AgendaState extends Equatable {
  const AgendaState();
}

@immutable
final class AgendaStateLoading extends AgendaState {
  const AgendaStateLoading();

  @override
  List<Object?> get props => [];
}

@immutable
final class AgendaStateCyclesLoaded extends AgendaState {
  const AgendaStateCyclesLoaded({
    required this.cycles,
  });

  final List<Cycle> cycles;

  @override
  List<Object?> get props => [cycles];
}

@immutable
final class AgendaStateNoCyclesLoaded extends AgendaState {
  const AgendaStateNoCyclesLoaded();

  @override
  List<Object?> get props => [];
}

@immutable
final class AgendaStateError extends AgendaState {
  const AgendaStateError({
    required this.message,
  });

  final String message;

  @override
  List<Object?> get props => [message];
}
