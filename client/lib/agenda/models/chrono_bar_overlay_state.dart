import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
final class ChronoBarOverlayState extends Equatable {
  const ChronoBarOverlayState({
    required this.bottom,
    this.overlayEntry,
  });

  const ChronoBarOverlayState.initial()
      : overlayEntry = null,
        bottom = initialBottom;

  final OverlayEntry? overlayEntry;

  final double bottom;

  static const double initialBottom = 100;

  @override
  List<Object?> get props => [
        overlayEntry,
        bottom,
      ];

  ChronoBarOverlayState copyWith({
    double? bottom,
    OverlayEntry? Function()? overlayEntryFn,
  }) =>
      ChronoBarOverlayState(
        bottom: bottom ?? this.bottom,
        overlayEntry: overlayEntryFn != null ? overlayEntryFn() : overlayEntry,
      );
}
