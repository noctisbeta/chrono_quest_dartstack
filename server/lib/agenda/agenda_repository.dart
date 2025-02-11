import 'package:common/agenda/add_cycle_request.dart';
import 'package:common/agenda/add_cycle_response.dart';
import 'package:common/agenda/cycle.dart';
import 'package:common/agenda/encrypted_add_cycle_request.dart';
import 'package:common/agenda/encrypted_add_cycle_response.dart';
import 'package:common/agenda/encrypted_cycle.dart';
import 'package:common/agenda/encrypted_get_cycles_response.dart';
import 'package:common/agenda/get_cycles_request.dart';
import 'package:common/agenda/get_cycles_response.dart';
import 'package:common/agenda/get_reference_date_request.dart';
import 'package:common/agenda/get_reference_date_response.dart';
import 'package:common/agenda/set_reference_date_request.dart';
import 'package:common/agenda/set_reference_date_response.dart';
import 'package:common/exceptions/propagates.dart';
import 'package:common/exceptions/throws.dart';
import 'package:meta/meta.dart';
import 'package:server/agenda/agenda_data_source.dart';
import 'package:server/agenda/cycle_db.dart';
import 'package:server/agenda/encrypted_cycle_db.dart';
import 'package:server/postgres/exceptions/database_exception.dart';

@immutable
final class AgendaRepository {
  const AgendaRepository({
    required AgendaDataSource agendaDataSource,
  }) : _agendaDataSource = agendaDataSource;

  final AgendaDataSource _agendaDataSource;

  @Propagates([DatabaseException])
  Future<GetReferenceDateResponse> getReferenceDate(
    GetReferenceDateRequest getReferenceDateRequest,
    int userId,
  ) async {
    @Throws([DatabaseException])
    final DateTime referenceDate =
        await _agendaDataSource.getReferenceDate(userId);

    return GetReferenceDateResponseSuccess(referenceDate: referenceDate);
  }

  @Propagates([DatabaseException])
  Future<SetReferenceDateResponse> setReferenceDate(
    SetReferenceDateRequest setReferenceDateRequest,
    int userId,
  ) async {
    @Throws([DatabaseException])
    final DateTime referenceDate = await _agendaDataSource.setReferenceDate(
      setReferenceDateRequest,
      userId,
    );

    return SetReferenceDateResponseSuccess(referenceDate: referenceDate);
  }

  @Propagates([DatabaseException])
  Future<GetCyclesResponse> getCycles(
    GetCyclesRequest getCyclesRequest,
    int userId,
  ) async {
    @Throws([DatabaseException])
    final List<CycleDB> cycleDB = await _agendaDataSource.getCycles(
      getCyclesRequest,
      userId,
    );

    final getCyclesResponse = GetCyclesResponseSuccess(
      cycles: cycleDB
          .map(
            (e) => Cycle(
              endTime: e.endTime,
              startTime: e.startTime,
              note: e.note,
              id: e.id,
              title: e.title,
              period: e.period,
            ),
          )
          .toList(),
    );

    return getCyclesResponse;
  }

  @Propagates([DatabaseException])
  Future<AddCycleResponse> addCycle(
    AddCycleRequest addCycleRequest,
    int userId,
  ) async {
    @Throws([DatabaseException])
    final CycleDB cycleDB = await _agendaDataSource.addCycle(
      addCycleRequest,
      userId,
    );

    final Cycle cycle = Cycle(
      endTime: cycleDB.endTime,
      startTime: cycleDB.startTime,
      note: cycleDB.note,
      id: cycleDB.id,
      title: cycleDB.title,
      period: cycleDB.period,
    );

    final addCycleResponse = AddCycleResponseSuccess(
      cycle: cycle,
    );

    return addCycleResponse;
  }

  @Propagates([DatabaseException])
  Future<EncryptedAddCycleResponse> addEncryptedCycle(
    EncryptedAddCycleRequest addCycleRequest,
    int userId,
  ) async {
    @Throws([DatabaseException])
    final EncryptedCycleDB cycleDB = await _agendaDataSource.addEncryptedCycle(
      addCycleRequest,
      userId,
    );

    final addCycleResponse = EncryptedAddCycleResponseSuccess(
      id: cycleDB.id,
      startTime: cycleDB.startTime,
      endTime: cycleDB.endTime,
      note: cycleDB.note,
      title: cycleDB.title,
      cycleRepetition: cycleDB.cycleRepetition,
    );

    return addCycleResponse;
  }

  @Propagates([DatabaseException])
  Future<EncryptedGetCyclesResponse> getEncryptedCycles(int userId) async {
    @Throws([DatabaseException])
    final List<EncryptedCycleDB> cyclesDB =
        await _agendaDataSource.getEncryptedCycles(userId);

    final List<EncryptedCycle> cycles = cyclesDB
        .map(
          (cycleDB) => EncryptedCycle(
            id: cycleDB.id,
            startTime: cycleDB.startTime,
            endTime: cycleDB.endTime,
            note: cycleDB.note,
            title: cycleDB.title,
            cycleRepetition: cycleDB.cycleRepetition,
            createdAt: cycleDB.createdAt,
            updatedAt: cycleDB.updatedAt,
          ),
        )
        .toList();

    return EncryptedGetCyclesResponseSuccess(cycles: cycles);
  }
}
