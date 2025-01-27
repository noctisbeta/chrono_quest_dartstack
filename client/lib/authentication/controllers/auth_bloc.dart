import 'package:chrono_quest/authentication/models/auth_event.dart';
import 'package:chrono_quest/authentication/models/auth_state.dart';
import 'package:chrono_quest/authentication/repositories/auth_repository.dart';
import 'package:common/auth/login_error.dart';
import 'package:common/auth/login_request.dart';
import 'package:common/auth/login_response.dart';
import 'package:common/auth/register_error.dart';
import 'package:common/auth/register_request.dart';
import 'package:common/auth/register_response.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(AuthStateUnauthenticated()) {
    on<AuthEvent>(
      (event, emit) async => switch (event) {
        AuthEventLogin() => login(event, emit),
        AuthEventRegister() => register(event, emit),
      },
    );
  }

  final AuthRepository _authRepository;

  Future<void> login(
    AuthEventLogin event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthStateLoading());

    final LoginRequest loginRequest = LoginRequest(
      username: event.username,
      password: event.password,
    );

    final LoginResponse loginResponse = await _authRepository.login(
      loginRequest,
    );

    switch (loginResponse) {
      case LoginResponseSuccess():
        emit(
          AuthStateAuthenticated(
            user: loginResponse.user,
            token: loginResponse.token,
          ),
        );
      case LoginResponseError():
        switch (loginResponse.error) {
          case LoginError.wrongPassword:
            emit(
              const AuthStateErrorWrongPassword(
                message: 'Wrong password',
              ),
            );
          case LoginError.unknownLoginError:
            emit(
              const AuthStateErrorUnknown(
                message: 'Error logging in user',
              ),
            );
          case LoginError.userNotFound:
            emit(
              const AuthStateErrorUserNotFound(
                message: 'User not found',
              ),
            );
        }
    }
  }

  Future<void> register(
    AuthEventRegister event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthStateLoading());

    final RegisterRequest registerRequest = RegisterRequest(
      username: event.username,
      password: event.password,
    );

    final RegisterResponse registerResponse = await _authRepository.register(
      registerRequest,
    );

    switch (registerResponse) {
      case RegisterResponseSuccess():
        emit(
          AuthStateAuthenticated(
            user: registerResponse.user,
            token: registerResponse.token,
          ),
        );
      case RegisterResponseError():
        switch (registerResponse.error) {
          case RegisterError.usernameAlreadyExists:
            emit(
              const AuthStateErrorUsernameAlreadyExists(
                message: 'Username already taken',
              ),
            );
          case RegisterError.unknownRegisterError:
            emit(
              const AuthStateErrorUnknown(
                message: 'Error registering user',
              ),
            );
        }
    }
  }
}
