import 'package:common/auth/jwt_token.dart';
import 'package:common/auth/user.dart';
import 'package:common/exceptions/response_exception.dart';
import 'package:common/requests/request.dart';
import 'package:meta/meta.dart';

@immutable
final class LoginResponse extends Response {
  const LoginResponse({
    required this.user,
    required this.token,
  });

  factory LoginResponse.validatedFromMap(Map<String, dynamic> map) =>
      switch (map) {
        {
          'user': final Map<String, dynamic> user,
          'token': final JwtToken token,
        } =>
          LoginResponse(
            user: User.validatedFromMap(user),
            token: token,
          ),
        _ => throw const BadResponseBodyException(
            'Invalid map format for RegisterResponse',
          )
      };

  final User user;

  final JwtToken token;

  @override
  Map<String, dynamic> toMap() => {
        'user': user.toMap(),
        'token': token,
      };

  @override
  List<Object?> get props => [user, token];
}
