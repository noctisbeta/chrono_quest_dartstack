import 'package:chrono_quest/authentication/models/auth_event.dart';
import 'package:chrono_quest/authentication/models/auth_state.dart';
import 'package:chrono_quest/authentication/repositories/auth_repository.dart';
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
    await _authRepository.login(event.username, event.password);
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
        emit(
          AuthStateError(
            message: registerResponse.message,
          ),
        );
    }
  }
}
