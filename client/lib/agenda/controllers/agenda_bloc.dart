import 'package:chrono_quest/agenda/models/agenda_event.dart';
import 'package:chrono_quest/agenda/models/agenda_state.dart';
import 'package:chrono_quest/authentication/repositories/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AgendaBloc extends Bloc<AgendaEvent, AgendaState> {
  AgendaBloc({
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(const AgendaInitial()) {
    on<AgendaEvent>((event, emit) {});
  }

  final AuthRepository _authRepository;
}
