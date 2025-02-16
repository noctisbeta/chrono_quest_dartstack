import 'package:chrono_quest/common/util/screen_type.dart';
import 'package:flutter/material.dart';

class ResponsiveLayoutBuilder extends StatelessWidget {
  const ResponsiveLayoutBuilder({required this.builder, super.key});

  final Function(BuildContext, ScreenType) builder;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final ScreenType screenType = switch (constraints.maxWidth) {
        < 600.0 => ScreenType.mobile,
        >= 600.0 && < 1200.0 => ScreenType.tablet,
        >= 1200.0 => ScreenType.desktop,
        _ => ScreenType.mobile,
      };

      return builder(context, screenType);
    },
  );
}
