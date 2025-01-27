import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show immutable;

@immutable
sealed class AuthEvent extends Equatable {}

@immutable
final class AuthEventLogin extends AuthEvent {
  AuthEventLogin({
    required this.username,
    required this.password,
  });

  final String username;
  final String password;

  @override
  List<Object?> get props => [username, password];
}

@immutable
final class AuthEventRegister extends AuthEvent {
  AuthEventRegister({
    required this.username,
    required this.password,
  });

  final String username;
  final String password;

  @override
  List<Object?> get props => [username, password];
}
