import 'package:common/auth/tokens/jwtoken.dart';
import 'package:common/auth/user.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show immutable;

@immutable
sealed class AuthState extends Equatable {
  const AuthState();
}

@immutable
final class AuthStateUnauthenticated extends AuthState {
  const AuthStateUnauthenticated();

  @override
  List<Object?> get props => [];
}

@immutable
final class AuthStateAuthenticated extends AuthState {
  const AuthStateAuthenticated({required this.user, required this.token});

  final User user;
  final JWToken token;

  @override
  List<Object?> get props => [user, token];
}

@immutable
final class AuthStateLoading extends AuthState {
  const AuthStateLoading();

  @override
  List<Object?> get props => [];
}

@immutable
sealed class AuthStateError extends AuthState {
  const AuthStateError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
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
