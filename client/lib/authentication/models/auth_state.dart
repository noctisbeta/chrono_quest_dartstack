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
