import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show immutable;

@immutable
sealed class AgendaState extends Equatable {
  const AgendaState();
}

@immutable
final class AgendaInitial extends AgendaState {
  const AgendaInitial();

  @override
  List<Object?> get props => [];
}
