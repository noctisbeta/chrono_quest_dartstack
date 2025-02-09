enum AddCycleError {
  unknownError;

  factory AddCycleError.fromString(String name) {
    switch (name) {
      case 'unknownError':
        return AddCycleError.unknownError;
      default:
        throw ArgumentError('Invalid RegisterError: $name');
    }
  }

  @override
  String toString() => switch (this) {
        AddCycleError.unknownError => 'unknownError',
      };
}
