import 'package:common/agenda/task_type.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show immutable;

@immutable
sealed class AgendaEvent extends Equatable {
  const AgendaEvent();
}

@immutable
final class AgendaEventAddTask extends AgendaEvent {
  const AgendaEventAddTask({
    required this.title,
    required this.description,
    required this.taskType,
    required this.startTime,
    required this.endTime,
  });

  final String title;
  final String description;
  final TaskType taskType;
  final DateTime startTime;
  final DateTime endTime;

  @override
  List<Object?> get props => [title, description, taskType, startTime, endTime];
}
