sealed class RequestException implements Exception {
  const RequestException(this.message);
  final String message;

  @override
  String toString() => 'RequestException: $message';
}

final class BadRequestBodyException extends RequestException {
  const BadRequestBodyException(super.message);

  @override
  String toString() => 'BadRequestBodyException: $message';
}

final class BadRequestContentTypeException extends RequestException {
  const BadRequestContentTypeException(super.message);

  @override
  String toString() => 'BadContentTypeException: $message';
}
