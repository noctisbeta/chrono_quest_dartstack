import 'package:chrono_quest/common/constants/colors.dart';
import 'package:flutter/material.dart';

class ChronoBarTextField extends StatelessWidget {
  const ChronoBarTextField({
    required this.hintText,
    required this.textEditingController,
    this.textInputType,
    this.focusNode,
    this.keyboardType = TextInputType.text,
    this.onSubmitted,
    super.key,
  });

  final String hintText;
  final TextEditingController textEditingController;
  final TextInputType keyboardType;
  final FocusNode? focusNode;
  final void Function(String)? onSubmitted;
  final TextInputType? textInputType;

  @override
  Widget build(BuildContext context) => TextField(
    controller: textEditingController,
    focusNode: focusNode,
    textInputAction: TextInputAction.done,
    keyboardType: keyboardType,
    onSubmitted: onSubmitted,
    style: const TextStyle(color: kBlack, fontWeight: FontWeight.w900),
    cursorColor: kBlack,
    decoration: InputDecoration(
      border: InputBorder.none,
      hintText: hintText,
      hintStyle: const TextStyle(color: kBlack, fontWeight: FontWeight.w600),
    ),
  );
}
