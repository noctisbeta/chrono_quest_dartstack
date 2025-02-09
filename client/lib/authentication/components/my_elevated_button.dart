import 'package:chrono_quest/common/constants/colors.dart';
import 'package:flutter/material.dart';

class MyElevatedButton extends StatelessWidget {
  const MyElevatedButton({
    required this.label,
    required this.backgroundColor,
    required this.onPressed,
    this.trailing,
    super.key,
  });

  final String label;

  final Color backgroundColor;

  final void Function() onPressed;

  final Widget? trailing;

  @override
  Widget build(BuildContext context) => ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(120, 40),
          backgroundColor: backgroundColor,
          foregroundColor: kWhite,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label),
            if (trailing != null) const SizedBox(width: 8),
            trailing ?? const SizedBox.shrink(),
          ],
        ),
      );
}
