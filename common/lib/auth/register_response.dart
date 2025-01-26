import 'package:common/auth/jwtoken.dart';
import 'package:common/auth/user.dart';
import 'package:common/exceptions/response_exception.dart';
import 'package:common/requests/request.dart';
import 'package:meta/meta.dart';

@immutable
final class RegisterResponse extends Response {
  const RegisterResponse({
    required this.user,
    required this.token,
  });

  factory RegisterResponse.validatedFromMap(Map<String, dynamic> map) =>
      switch (map) {
        {
          'user': final Map<String, dynamic> user,
          'token': final JWToken token,
        } =>
          RegisterResponse(
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
