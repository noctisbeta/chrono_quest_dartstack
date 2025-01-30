import 'package:common/abstractions/models.dart';
import 'package:common/auth/login/login_error.dart';
import 'package:common/auth/tokens/jwtoken.dart';
import 'package:common/auth/tokens/refresh_token_wrapper.dart';
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
    required this.refreshTokenWrapper,
  });

  factory LoginResponseSuccess.validatedFromMap(Map<String, dynamic> map) =>
      switch (map) {
        {
          'user': final Map<String, dynamic> user,
          'token': final JWToken token,
          'refresh_token_wrapper': final Map<String, dynamic>
              refreshTokenWrapperMap,
        } =>
          LoginResponseSuccess(
            user: User.validatedFromMap(user),
            token: token,
            refreshTokenWrapper: RefreshTokenWrapper.validatedFromMap(
              refreshTokenWrapperMap,
            ),
          ),
        _ => throw const BadResponseBodyException(
            'Invalid map format for RegisterResponse',
          )
      };

  final User user;

  final JWToken token;

  final RefreshTokenWrapper refreshTokenWrapper;

  @override
  Map<String, dynamic> toMap() => {
        'user': user.toMap(),
        'token': token,
        'refresh_token_wrapper': refreshTokenWrapper.toMap(),
      };

  @override
  List<Object?> get props => [user, token, refreshTokenWrapper];
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
