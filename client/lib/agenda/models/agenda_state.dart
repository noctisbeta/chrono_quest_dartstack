import 'package:common/agenda/task.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show immutable;

@immutable
sealed class AgendaState extends Equatable {
  const AgendaState({
    required this.tasks,
  });

  final List<Task> tasks;

  @override
  List<Object?> get props => [tasks];
}

@immutable
final class AgendaStateInitial extends AgendaState {
  const AgendaStateInitial()
      : super(
          tasks: const [],
        );
}

@immutable
final class AgendaStateLoaded extends AgendaState {
  const AgendaStateLoaded({
    required super.tasks,
  });
}

@immutable
final class AgendaStateAddTaskLoading extends AgendaState {
  const AgendaStateAddTaskLoading({
    required super.tasks,
  });
}

@immutable
final class AgendaStateAddTaskError extends AgendaState {
  const AgendaStateAddTaskError({
    required this.message,
    required super.tasks,
  });

  final String message;

  @override
  List<Object?> get props => [message, tasks];
}
