import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
sealed class AgendaEvent extends Equatable {
  const AgendaEvent();
}

@immutable
final class AgendaEventGetCycles extends AgendaEvent {
  const AgendaEventGetCycles();

  @override
  List<Object?> get props => [];
}

@immutable
final class AgendaEventAddCycle extends AgendaEvent {
  const AgendaEventAddCycle({
    required this.title,
    required this.note,
    required this.period,
    required this.startTime,
    required this.endTime,
  });

  final String title;
  final String note;
  final int period;
  final DateTime startTime;
  final DateTime endTime;

  @override
  List<Object?> get props => [title, note, period, startTime, endTime];
}
