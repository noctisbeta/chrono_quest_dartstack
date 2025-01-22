sealed class AuthException implements Exception {
  const AuthException(
    this.message,
  );

  final String message;

  @override
  String toString() => message;
}

final class AEinvalidPassword extends AuthException {
  const AEinvalidPassword(
    super.message,
  );
}
