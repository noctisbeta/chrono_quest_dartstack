import 'package:flutter/material.dart' show immutable;

@immutable
sealed class AuthEvent {}

@immutable
final class AuthEventLogin extends AuthEvent {
  AuthEventLogin({
    required this.username,
    required this.password,
  });

  final String username;
  final String password;
}

@immutable
final class AuthEventRegister extends AuthEvent {
  AuthEventRegister({
    required this.username,
    required this.password,
  });

  final String username;
  final String password;
}
