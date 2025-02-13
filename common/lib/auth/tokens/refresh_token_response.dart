import 'package:common/abstractions/models.dart';
import 'package:common/auth/tokens/jwtoken.dart';
import 'package:common/auth/tokens/refresh_error.dart';
import 'package:common/auth/tokens/refresh_token.dart';
import 'package:common/exceptions/bad_map_shape_exception.dart';
import 'package:common/exceptions/throws.dart';
import 'package:meta/meta.dart';

@immutable
sealed class RefreshTokenResponse extends Response {
  const RefreshTokenResponse();
}

@immutable
final class RefreshTokenResponseSuccess extends RefreshTokenResponse {
  const RefreshTokenResponseSuccess({
    required this.jwToken,
    required this.refreshToken,
    required this.refreshTokenExpiresAt,
  });

  @Throws([BadMapShapeException])
  factory RefreshTokenResponseSuccess.validatedFromMap(
    Map<String, dynamic> map,
  ) => switch (map) {
    {
      'jwToken': final String jwToken,
      'refreshToken': final String refreshToken,
      'refreshTokenExpiresAt': final String refreshTokenExpiresAt,
    } =>
      RefreshTokenResponseSuccess(
        jwToken: JWToken.fromJwtString(jwToken),
        refreshToken: RefreshToken.fromRefreshTokenString(refreshToken),
        refreshTokenExpiresAt: DateTime.parse(refreshTokenExpiresAt),
      ),
    _ =>
      throw const BadMapShapeException(
        'Invalid map format for RefreshTokenResponseSuccess',
      ),
  };
  final JWToken jwToken;
  final RefreshToken refreshToken;
  final DateTime refreshTokenExpiresAt;

  @override
  List<Object?> get props => [jwToken, refreshToken, refreshTokenExpiresAt];

  @override
  Map<String, dynamic> toMap() => {
    'jwToken': jwToken.value,
    'refreshToken': refreshToken.value,
    'refreshTokenExpiresAt': refreshTokenExpiresAt.toIso8601String(),
  };
}

@immutable
final class RefreshTokenResponseError extends RefreshTokenResponse {
  const RefreshTokenResponseError({required this.message, required this.error});

  @Throws([BadMapShapeException])
  factory RefreshTokenResponseError.validatedFromMap(
    Map<String, dynamic> map,
  ) => switch (map) {
    {'message': final String message, 'error': final String error} =>
      RefreshTokenResponseError(
        message: message,
        error: RefreshError.fromString(error),
      ),
    _ =>
      throw const BadMapShapeException(
        'Invalid map format for RefreshTokenResponseError',
      ),
  };

  final String message;
  final RefreshError error;

  @override
  List<Object?> get props => [message, error];

  @override
  Map<String, dynamic> toMap() => {
    'message': message,
    'error': error.toString(),
  };
}
