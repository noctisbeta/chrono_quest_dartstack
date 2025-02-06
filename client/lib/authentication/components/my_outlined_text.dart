import 'package:flutter/material.dart';

class MyOutlinedText extends StatelessWidget {
  const MyOutlinedText({
    required this.text,
    required this.fontWeight,
    required this.fontSize,
    required this.strokeWidth,
    required this.foreground,
    required this.background,
    super.key,
  });

  final String text;
  final FontWeight fontWeight;
  final double fontSize;
  final double strokeWidth;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: fontWeight,
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = strokeWidth
                ..color = background,
            ),
          ),
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: foreground,
            ),
          ),
        ],
      );
}
