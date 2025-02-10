import 'package:flutter/material.dart';

/// A widget that conditionally renders a child based on a condition.
class ConditionalChild extends StatelessWidget {
  /// Creates a [ConditionalChild] widget.
  const ConditionalChild({
    required this.condition,
    required this.child,
    this.fallback,
    super.key,
  });

  /// The condition that determines whether to show the child.
  final bool condition;

  /// The widget to show when the condition is true.
  final Widget child;

  /// The widget to show when the condition is false.
  /// If not provided, returns an empty [SizedBox].
  final Widget? fallback;

  @override
  Widget build(BuildContext context) =>
      condition ? child : (fallback ?? const SizedBox.shrink());
}
