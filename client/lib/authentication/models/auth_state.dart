import 'package:common/auth/jwtoken.dart';
import 'package:common/auth/user.dart';
import 'package:flutter/material.dart' show immutable;

@immutable
sealed class AuthState {
  const AuthState();
}

@immutable
final class AuthStateUnauthenticated extends AuthState {}

@immutable
final class AuthStateAuthenticated extends AuthState {
  const AuthStateAuthenticated({
    required this.user,
    required this.token,
  });

  final User user;
  final JWToken token;
}

@immutable
final class AuthStateLoading extends AuthState {}

@immutable
sealed class AuthStateError extends AuthState {
  const AuthStateError({
    required this.message,
  });

  final String message;
}

@immutable
final class AuthStateErrorUsernameAlreadyExists extends AuthStateError {
  const AuthStateErrorUsernameAlreadyExists({required super.message});
}

@immutable
final class AuthStateErrorUnknown extends AuthStateError {
  const AuthStateErrorUnknown({required super.message});
}

@immutable
final class AuthStateErrorWrongPassword extends AuthStateError {
  const AuthStateErrorWrongPassword({required super.message});
}

@immutable
final class AuthStateErrorUserNotFound extends AuthStateError {
  const AuthStateErrorUserNotFound({required super.message});
}
