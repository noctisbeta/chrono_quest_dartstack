import 'package:common/abstractions/models.dart';
import 'package:common/auth/register/register_error.dart';
import 'package:common/auth/tokens/jwtoken.dart';
import 'package:common/auth/tokens/refresh_token_wrapper.dart';
import 'package:common/auth/user.dart';
import 'package:common/exceptions/response_exception.dart';
import 'package:common/exceptions/throws.dart';
import 'package:meta/meta.dart';

@immutable
sealed class RegisterResponse extends Response {
  const RegisterResponse();
}

@immutable
final class RegisterResponseSuccess extends RegisterResponse {
  const RegisterResponseSuccess({
    required this.user,
    required this.token,
    required this.refreshTokenWrapper,
  });

  @Throws([BadResponseBodyException])
  factory RegisterResponseSuccess.validatedFromMap(Map<String, dynamic> map) =>
      switch (map) {
        {
          'user': final Map<String, dynamic> user,
          'token': final String token,
          'refresh_token_wrapper': final Map<String, dynamic>
              refreshTokenWrapperMap,
        } =>
          RegisterResponseSuccess(
            user: User.validatedFromMap(user),
            token: JWToken.fromJwtString(token),
            refreshTokenWrapper: RefreshTokenWrapper.validatedFromMap(
              refreshTokenWrapperMap,
            ),
          ),
        _ => throw const BadResponseBodyException(
            'Invalid map format for RegisterResponseSuccess',
          )
      };

  final User user;

  final JWToken token;

  final RefreshTokenWrapper refreshTokenWrapper;

  @override
  Map<String, dynamic> toMap() => {
        'user': user.toMap(),
        'token': token.value,
        'refresh_token_wrapper': refreshTokenWrapper.toMap(),
      };

  @override
  List<Object?> get props => [user, token, refreshTokenWrapper];
}

@immutable
final class RegisterResponseError extends RegisterResponse {
  const RegisterResponseError({
    required this.message,
    required this.error,
  });

  factory RegisterResponseError.validatedFromMap(Map<String, dynamic> map) =>
      switch (map) {
        {
          'message': final String message,
          'error': final String error,
        } =>
          RegisterResponseError(
            message: message,
            error: RegisterError.fromString(error),
          ),
        _ => throw const BadResponseBodyException(
            'Invalid map format for RegisterResponseError',
          )
      };

  final String message;

  final RegisterError error;

  @override
  Map<String, dynamic> toMap() => {
        'message': message,
        'error': error.toString(),
      };

  @override
  List<Object?> get props => [message, error];
}
