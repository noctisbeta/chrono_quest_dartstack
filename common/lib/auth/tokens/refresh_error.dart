enum RefreshError {
  expired,
  unknownRefreshError;

  factory RefreshError.fromString(String name) {
    switch (name) {
      case 'expired':
        return RefreshError.expired;
      case 'unknownRegisterError':
        return RefreshError.unknownRefreshError;
      default:
        throw ArgumentError('Invalid RefreshError: $name');
    }
  }

  @override
  String toString() => switch (this) {
        RefreshError.expired => 'expired',
        RefreshError.unknownRefreshError => 'unknownRefreshError',
      };
}
