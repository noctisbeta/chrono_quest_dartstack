import 'package:chrono_quest/dio_wrapper/dio_wrapper.dart';
import 'package:chrono_quest/encryption/encryption_repository.dart';
import 'package:common/agenda/add_task_error.dart';
import 'package:common/agenda/add_task_request.dart';
import 'package:common/agenda/add_task_response.dart';
import 'package:common/agenda/encrypted_add_task_request.dart';
import 'package:common/agenda/encrypted_add_task_response.dart';
import 'package:common/agenda/get_tasks_request.dart';
import 'package:common/agenda/get_tasks_response.dart';
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

  Future<GetTasksResponse> getTasks() async {
    try {
      final getTasksRequest = GetTasksRequest(
        dateTime: DateTime.now(),
      );

      final Response response = await _dio.get(
        '/agenda/tasks',
        queryParameters: getTasksRequest.toMap(),
      );

      final GetTasksResponseSuccess getTasksResponse =
          GetTasksResponseSuccess.validatedFromMap(response.data);

      return getTasksResponse;
    } on DioException catch (e) {
      LOG.e('Error getting tasks: $e');
      switch (e.response?.statusCode) {
        default:
          LOG.e('Unknown Error getting tasks: $e');
          return const GetTasksResponseError(
            message: 'Error getting tasks',
          );
      }
    }
  }

  Future<EncryptedAddTaskRequest> _encryptAddTaskRequest(
    AddTaskRequest addTaskRequest,
  ) async {
    final [
      String title,
      String note,
      String startTime,
      String endTime,
      String taskType
    ] = await Future.wait([
      _encryptionRepository.encrypt(addTaskRequest.title),
      _encryptionRepository.encrypt(addTaskRequest.note),
      _encryptionRepository.encrypt(addTaskRequest.startTime.toString()),
      _encryptionRepository.encrypt(addTaskRequest.endTime.toString()),
      _encryptionRepository.encrypt(addTaskRequest.taskType.name),
    ]);

    return EncryptedAddTaskRequest(
      title: title,
      note: note,
      startTime: startTime,
      endTime: endTime,
      taskType: taskType,
    );
  }

  Future<EncryptedAddTaskResponse> addEncryptedTask(
    AddTaskRequest addTaskRequest,
  ) async {
    try {
      final EncryptedAddTaskRequest encryptedRequest =
          await _encryptAddTaskRequest(addTaskRequest);

      final Response response = await _dio.post(
        '/agenda/tasks/encrypted',
        data: encryptedRequest.toMap(),
      );

      final EncryptedAddTaskResponseSuccess addTaskResponse =
          EncryptedAddTaskResponseSuccess.validatedFromMap(response.data);

      return addTaskResponse;
    } on DioException catch (e) {
      LOG.e('Error adding encrypted task: $e');
      switch (e.response?.statusCode) {
        default:
          LOG.e('Unknown Error adding encrypted task: $e');
          return const EncryptedAddTaskResponseError(
            message: 'Error adding encrypted task',
            error: AddTaskError.unknownError,
          );
      }
    }
  }

  Future<AddTaskResponse> addTask(AddTaskRequest addTaskRequest) async {
    try {
      final Response response = await _dio.post(
        '/agenda/tasks',
        data: addTaskRequest.toMap(),
      );

      final AddTaskResponseSuccess addTaskResponse =
          AddTaskResponseSuccess.validatedFromMap(response.data);

      return addTaskResponse;
    } on DioException catch (e) {
      LOG.e('Error adding task: $e');
      switch (e.response?.statusCode) {
        default:
          LOG.e('Unknown Error adding task: $e');
          return const AddTaskResponseError(
            message: 'Error adding task',
            error: AddTaskError.unknownError,
          );
      }
    }
  }
}
