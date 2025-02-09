// import 'dart:async';

// import 'package:chrono_quest/agenda/repositories/agenda_repository.dart';
// import 'package:common/agenda/add_cycle_error.dart';
// import 'package:common/agenda/add_cycle_request.dart';
// import 'package:common/agenda/add_cycle_response.dart';
// import 'package:common/agenda/cycle.dart';
// import 'package:common/agenda/get_cycles_response.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// class AgendaCubit extends Cubit<List<Cycle>> {
//   AgendaCubit({
//     required AgendaRepository agendaRepository,
//   })  : _agendaRepository = agendaRepository,
//         super(
//           [],
//         ) {
//     unawaited(getCycles());
//   }

//   final AgendaRepository _agendaRepository;

//   Future<void> getCycles() async {
//     final GetCyclesResponse getCyclesResponse =
//         await _agendaRepository.getCycles();

//     switch (getCyclesResponse) {
//       case GetCyclesResponseSuccess(:final cycles):
//         emit(
//           cycles,
//         );
//       case GetCyclesResponseError():
//         emit(
//           [],
//         );
//     }
//   }

//   Future<void> addCycle(
//     String title,
//     String note,
//     int period,
//     DateTime startTime,
//     DateTime endTime,
//   ) async {
//     final addCycleRequest = AddCycleRequest(
//       startTime: startTime,
//       note: note,
//       title: title,
//       period: period,
//       endTime: endTime,
//     );

//     final AddCycleResponse addCycleResponse = await _agendaRepository.addCycle(
//       addCycleRequest,
//     );

//     switch (addCycleResponse) {
//       case AddCycleResponseSuccess():
//         await getCycles();
//       case AddCycleResponseError():
//         switch (addCycleResponse.error) {
//           case AddCycleError.unknownError:
//             emit(
//               [],
//             );
//         }
//     }
//   }
// }
