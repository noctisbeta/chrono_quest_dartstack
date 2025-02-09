import 'package:chrono_quest/dio_wrapper/dio_wrapper.dart';
import 'package:chrono_quest/encryption/encryption_repository.dart';
import 'package:common/agenda/add_cycle_error.dart';
import 'package:common/agenda/add_cycle_request.dart';
import 'package:common/agenda/add_cycle_response.dart';
import 'package:common/agenda/encrypted_add_cycle_request.dart';
import 'package:common/agenda/encrypted_add_cycle_response.dart';
import 'package:common/agenda/get_cycles_request.dart';
import 'package:common/agenda/get_cycles_response.dart';
import 'package:common/logger/logger.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart' show immutable;

@immutable
final class AgendaRepository {
  const AgendaRepository({
    required EncryptionRepository encryptionRepository,
    required DioWrapper authorizedDio,
  })  : _dio = authorizedDio,
        _encryptionRepository = encryptionRepository;

  final DioWrapper _dio;

  final EncryptionRepository _encryptionRepository;

  Future<GetCyclesResponse> getCycles() async {
    try {
      final getCyclesRequest = GetCyclesRequest(
        dateTime: DateTime.now(),
      );

      final Response response = await _dio.get(
        '/agenda/cycles',
        queryParameters: getCyclesRequest.toMap(),
      );

      final GetCyclesResponseSuccess getCyclesResponse =
          GetCyclesResponseSuccess.validatedFromMap(response.data);

      return getCyclesResponse;
    } on DioException catch (e) {
      LOG.e('Error getting cycles: $e');
      switch (e.response?.statusCode) {
        default:
          LOG.e('Unknown Error getting cycles: $e');
          return const GetCyclesResponseError(
            message: 'Error getting cycles',
          );
      }
    }
  }

  Future<EncryptedAddCycleRequest> _encryptAddCycleRequest(
    AddCycleRequest addCycleRequest,
  ) async {
    final [
      String title,
      String note,
      String startTime,
      String endTime,
      String period,
    ] = await Future.wait([
      _encryptionRepository.encrypt(addCycleRequest.title),
      _encryptionRepository.encrypt(addCycleRequest.note),
      _encryptionRepository.encrypt(addCycleRequest.startTime.toString()),
      _encryptionRepository.encrypt(addCycleRequest.endTime.toString()),
      _encryptionRepository.encrypt(addCycleRequest.period.toString()),
    ]);

    return EncryptedAddCycleRequest(
      title: title,
      note: note,
      startTime: startTime,
      endTime: endTime,
      period: period,
    );
  }

  Future<EncryptedAddCycleResponse> addEncryptedCycle(
    AddCycleRequest addCycleRequest,
  ) async {
    try {
      final EncryptedAddCycleRequest encryptedRequest =
          await _encryptAddCycleRequest(addCycleRequest);

      final Response response = await _dio.post(
        '/agenda/cycles/encrypted',
        data: encryptedRequest.toMap(),
      );

      final EncryptedAddCycleResponseSuccess addCycleResponse =
          EncryptedAddCycleResponseSuccess.validatedFromMap(response.data);

      return addCycleResponse;
    } on DioException catch (e) {
      LOG.e('Error adding encrypted cycle: $e');
      switch (e.response?.statusCode) {
        default:
          LOG.e('Unknown Error adding encrypted cycle: $e');
          return const EncryptedAddCycleResponseError(
            message: 'Error adding encrypted cycle',
            error: AddCycleError.unknownError,
          );
      }
    }
  }

  Future<AddCycleResponse> addCycle(AddCycleRequest addCycleRequest) async {
    try {
      LOG.i('Adding cycle: ${addCycleRequest.toMap()}');

      final Response response = await _dio.post(
        '/agenda/cycles',
        data: addCycleRequest.toMap(),
      );

      final AddCycleResponseSuccess addCycleResponse =
          AddCycleResponseSuccess.validatedFromMap(response.data);

      return addCycleResponse;
    } on DioException catch (e) {
      LOG.e('Error adding cycle: $e');
      switch (e.response?.statusCode) {
        default:
          LOG.e('Unknown Error adding cycle: $e');
          return const AddCycleResponseError(
            message: 'Error adding cycle',
            error: AddCycleError.unknownError,
          );
      }
    }
  }
}
