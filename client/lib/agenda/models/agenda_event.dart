import 'package:common/agenda/task.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show immutable;

@immutable
sealed class AgendaEvent extends Equatable {
  const AgendaEvent();
}

@immutable
final class AgendaEventAddTask extends AgendaEvent {
  const AgendaEventAddTask({
    required this.task,
  });

  final Task task;

  @override
  List<Object?> get props => [task];
}
