import 'package:flutter/material.dart';

class ConditionalParent extends StatelessWidget {
  const ConditionalParent({
    required this.condition,
    required this.child,
    required this.parentBuilder,
    super.key,
  });

  final bool condition;
  final Widget child;
  final Widget Function(Widget child) parentBuilder;

  @override
  Widget build(BuildContext context) =>
      condition ? parentBuilder(child) : child;
}
