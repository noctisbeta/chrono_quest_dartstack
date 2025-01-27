import 'package:common/abstractions/models.dart';
import 'package:common/exceptions/request_exception.dart';
import 'package:meta/meta.dart';

@immutable
final class LoginRequest extends Request {
  const LoginRequest({
    required this.username,
    required this.password,
  });

  /// Throws [BadRequestBodyException].
  factory LoginRequest.validatedFromMap(Map<String, dynamic> map) =>
      switch (map) {
        {
          'username': final username,
          'password': final password,
        } =>
          LoginRequest(
            username: username,
            password: password,
          ),
        _ => throw const BadRequestBodyException(
            'Invalid map format for LoginRequest',
          )
      };

  final String username;
  final String password;

  @override
  Map<String, dynamic> toMap() => {
        'username': username,
        'password': password,
      };

  @override
  List<Object?> get props => [username, password];
}
