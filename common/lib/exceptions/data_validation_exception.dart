final class DataValidationException implements Exception {
  const DataValidationException(this.message);
  final String message;

  @override
  String toString() => 'DataValidationException: $message';
}
