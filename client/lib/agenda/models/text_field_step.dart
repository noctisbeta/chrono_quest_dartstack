extension type TextFieldStep._(int value) {
  factory TextFieldStep.from(int value) => switch (value) {
        < 1 => throw ArgumentError('TextFieldStep must be greater than 0'),
        > 3 => throw ArgumentError('TextFieldStep must be less than 4'),
        _ => TextFieldStep._(value),
      };

  TextFieldStep operator +(int other) {
    final int newValue = ((value + other - 1) % 3) + 1;
    return TextFieldStep.from(newValue);
  }
}
