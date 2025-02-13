import 'package:common/agenda/cycle.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show immutable;

@immutable
sealed class AgendaState extends Equatable {
  const AgendaState();
}

@immutable
final class AgendaStateInitial extends AgendaState {
  const AgendaStateInitial();

  @override
  List<Object?> get props => [];
}

@immutable
final class AgendaStateLoading extends AgendaState {
  const AgendaStateLoading();

  @override
  List<Object?> get props => [];
}

@immutable
final class AgendaStateReferenceDateSet extends AgendaState {
  const AgendaStateReferenceDateSet({required this.referenceDate});

  final DateTime referenceDate;

  @override
  List<Object?> get props => [referenceDate];
}

@immutable
final class AgendaStateCyclesLoaded extends AgendaState {
  const AgendaStateCyclesLoaded({
    required this.cycles,
    required this.referenceDate,
  });

  final List<Cycle> cycles;

  final DateTime? referenceDate;

  @override
  List<Object?> get props => [cycles, referenceDate];
}

@immutable
final class AgendaStateNoCyclesLoaded extends AgendaState {
  const AgendaStateNoCyclesLoaded({required this.referenceDate});

  final DateTime? referenceDate;

  @override
  List<Object?> get props => [referenceDate];
}

@immutable
final class AgendaStateError extends AgendaState {
  const AgendaStateError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

@immutable
final class AgendaStateCycleAdded extends AgendaState {
  const AgendaStateCycleAdded();

  @override
  List<Object?> get props => [];
}
