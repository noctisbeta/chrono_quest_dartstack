enum TaskType {
  daily,
  weeekly,
  monthly,
  occasional,
  once;

  factory TaskType.fromString(String name) {
    switch (name) {
      case 'daily':
        return TaskType.daily;
      case 'weeekly':
        return TaskType.weeekly;
      case 'monthly':
        return TaskType.monthly;
      case 'occasional':
        return TaskType.occasional;
      case 'once':
        return TaskType.once;
      default:
        throw ArgumentError('Invalid TaskType: $name');
    }
  }

  @override
  String toString() => switch (this) {
        TaskType.daily => 'daily',
        TaskType.weeekly => 'weeekly',
        TaskType.monthly => 'monthly',
        TaskType.occasional => 'occasional',
        TaskType.once => 'once',
      };
}
