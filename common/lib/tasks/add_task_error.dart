enum AddTaskError {
  unknownError;

  factory AddTaskError.fromString(String name) {
    switch (name) {
      case 'unknownError':
        return AddTaskError.unknownError;
      default:
        throw ArgumentError('Invalid RegisterError: $name');
    }
  }

  @override
  String toString() => switch (this) {
        AddTaskError.unknownError => 'unknownError',
      };
}
