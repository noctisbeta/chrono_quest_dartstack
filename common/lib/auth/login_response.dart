import 'package:common/abstractions/models.dart';
import 'package:common/auth/jwtoken.dart';
import 'package:common/auth/login_error.dart';
import 'package:common/auth/user.dart';
import 'package:common/exceptions/response_exception.dart';
import 'package:meta/meta.dart';

@immutable
sealed class LoginResponse extends Response {
  const LoginResponse();
}

@immutable
final class LoginResponseSuccess extends LoginResponse {
  const LoginResponseSuccess({
    required this.user,
    required this.token,
  });

  factory LoginResponseSuccess.validatedFromMap(Map<String, dynamic> map) =>
      switch (map) {
        {
          'user': final Map<String, dynamic> user,
          'token': final JWToken token,
        } =>
          LoginResponseSuccess(
            user: User.validatedFromMap(user),
            token: token,
          ),
        _ => throw const BadResponseBodyException(
            'Invalid map format for RegisterResponse',
          )
      };

  final User user;

  final JWToken token;

  @override
  Map<String, dynamic> toMap() => {
        'user': user.toMap(),
        'token': token,
      };

  @override
  List<Object?> get props => [user, token];
}

@immutable
final class LoginResponseError extends LoginResponse {
  const LoginResponseError({
    required this.message,
    required this.error,
  });

  factory LoginResponseError.validatedFromMap(Map<String, dynamic> map) =>
      switch (map) {
        {
          'message': final String message,
          'error': final String error,
        } =>
          LoginResponseError(
            message: message,
            error: LoginError.fromString(error),
          ),
        _ => throw const BadResponseBodyException(
            'Invalid map format for LoginResponseError',
          )
      };

  final String message;

  final LoginError error;

  @override
  Map<String, dynamic> toMap() => {
        'message': message,
        'error': error.toString(),
      };

  @override
  List<Object?> get props => [message, error];
}
