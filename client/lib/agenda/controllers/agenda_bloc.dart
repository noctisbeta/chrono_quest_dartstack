import 'package:chrono_quest/agenda/models/agenda_event.dart';
import 'package:chrono_quest/agenda/models/agenda_state.dart';
import 'package:chrono_quest/agenda/repositories/agenda_repository.dart';
import 'package:common/agenda/add_cycle_request.dart';
import 'package:common/agenda/add_cycle_response.dart';
import 'package:common/agenda/get_cycles_response.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AgendaBloc extends Bloc<AgendaEvent, AgendaState> {
  AgendaBloc({
    required AgendaRepository agendaRepository,
  })  : _agendaRepository = agendaRepository,
        super(const AgendaStateLoading()) {
    on<AgendaEvent>(_handleEvents);

    add(const AgendaEventGetCycles());
  }

  final AgendaRepository _agendaRepository;

  Future<void> _handleEvents(
    AgendaEvent event,
    Emitter<AgendaState> emit,
  ) async {
    switch (event) {
      case AgendaEventGetCycles():
        await _onGetCycles(event, emit);
      case AgendaEventAddCycle():
        await _onAddCycle(event, emit);
    }
  }

  Future<void> _onAddCycle(
    AgendaEventAddCycle event,
    Emitter<AgendaState> emit,
  ) async {
    emit(const AgendaStateLoading());

    final AddCycleResponse addCycleResponse = await _agendaRepository.addCycle(
      AddCycleRequest(
        title: event.title,
        note: event.note,
        period: event.period,
        startTime: event.startTime,
        endTime: event.endTime,
      ),
    );

    switch (addCycleResponse) {
      case AddCycleResponseSuccess(:final cycle):
        emit(AgendaStateCyclesLoaded(cycles: [cycle]));
      case AddCycleResponseError(:final message):
        emit(AgendaStateError(message: message));
    }
  }

  Future<void> _onGetCycles(
    AgendaEventGetCycles event,
    Emitter<AgendaState> emit,
  ) async {
    emit(const AgendaStateLoading());

    final GetCyclesResponse getCyclesResponse =
        await _agendaRepository.getCycles();

    switch (getCyclesResponse) {
      case GetCyclesResponseSuccess(:final cycles):
        if (cycles.isEmpty) {
          emit(const AgendaStateNoCyclesLoaded());
        } else {
          emit(AgendaStateCyclesLoaded(cycles: cycles));
        }
      case GetCyclesResponseError(:final message):
        emit(AgendaStateError(message: message));
    }
  }
}
