import 'package:chrono_quest/common/constants/colors.dart';
import 'package:chrono_quest/common/constants/numbers.dart';
import 'package:flutter/material.dart';

class MyTextField extends StatefulWidget {
  const MyTextField({
    required this.onChanged,
    required this.label,
    this.keyboardType = TextInputType.text,
    this.inverted = false,
    this.maxLength,
    this.obscureText = false,
    super.key,
  });

  final String label;

  final int? maxLength;

  final void Function(String) onChanged;

  final TextInputType keyboardType;

  final bool inverted;

  final bool obscureText;

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  String enteredText = '';
  late bool obscureText = widget.obscureText;

  @override
  Widget build(BuildContext context) => TextField(
        obscureText: obscureText,
        keyboardType: widget.keyboardType,
        onChanged: (String value) {
          setState(() {
            enteredText = value;
          });
          widget.onChanged(value);
        },
        maxLength: widget.maxLength,
        buildCounter: (
          context, {
          required currentLength,
          required isFocused,
          required int? maxLength,
        }) =>
            null,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: widget.inverted ? kSecondaryColor : kQuaternaryColor,
        ),
        cursorColor: widget.inverted ? kSecondaryColor : kQuaternaryColor,
        decoration: InputDecoration(
          suffixIcon: widget.obscureText
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      obscureText = !obscureText;
                    });
                  },
                  child: Icon(
                    obscureText ? Icons.visibility : Icons.visibility_off,
                    color: widget.inverted ? kSecondaryColor : kQuaternaryColor,
                  ),
                )
              : null,
          fillColor: kWhite,
          filled: true,
          suffix: switch (widget.maxLength) {
            int() => Text(
                '${enteredText.length}/${widget.maxLength}',
                style: TextStyle(
                  color: widget.inverted ? kQuaternaryColor : kSecondaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            null => null,
          },
          focusColor: widget.inverted ? kTernaryColor : kPrimaryColor,
          hoverColor: widget.inverted ? kTernaryColor : kPrimaryColor,
          labelText: widget.label,
          labelStyle: TextStyle(
            color: widget.inverted ? kQuaternaryColor : kSecondaryColor,
            fontWeight: FontWeight.bold,
          ),
          floatingLabelStyle: TextStyle(
            color: widget.inverted ? kSecondaryColor : kQuaternaryColor,
            decorationColor:
                widget.inverted ? kQuaternaryColor : kSecondaryColor,
            fontWeight: FontWeight.bold,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(kBorderRadius),
            borderSide: BorderSide(
              color: widget.inverted ? kQuaternaryColor : kSecondaryColor,
              width: 1.5,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(kBorderRadius),
            borderSide: BorderSide(
              color: widget.inverted ? kSecondaryColor : kQuaternaryColor,
              width: 1.5,
            ),
          ),
        ),
      );
}
