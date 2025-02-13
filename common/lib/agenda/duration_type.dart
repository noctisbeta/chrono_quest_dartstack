enum DurationType {
  hours,
  days,
  weeks;

  factory DurationType.fromString(String name) {
    switch (name) {
      case 'hours':
        return DurationType.hours;
      case 'days':
        return DurationType.days;
      case 'weeks':
        return DurationType.weeks;
      default:
        throw ArgumentError('Invalid DurationType: $name');
    }
  }

  @override
  String toString() => switch (this) {
    DurationType.hours => 'hours',
    DurationType.days => 'days',
    DurationType.weeks => 'weeks',
  };
}
