import 'package:chrono_quest/dio_wrapper/dio_wrapper.dart';
import 'package:chrono_quest/encryption/encryption_repository.dart';
import 'package:common/agenda/add_task_error.dart';
import 'package:common/agenda/add_task_request.dart';
import 'package:common/agenda/add_task_response.dart';
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

      // final dataString = response.data.toString();

      // LOG.i('Response data string: $dataString');

      // final tasksJson = response.data['tasks'];

      // LOG.i('Tasks json: $tasksJson');
      // LOG.i('Tasks json type: ${tasksJson.runtimeType}');

      // final map = jsonDecode(response.data.toString());

      // LOG.i('Response: ${response.data}');
      // LOG.i('Response type: ${response.data.runtimeType}');

      // LOG.i('Response as map: $map');
      // LOG.i('Response as map type: ${map.runtimeType}');

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

  Future<AddTaskRequest> encryptAddTaskRequest(
    AddTaskRequest addTaskRequest,
  ) async =>
      addTaskRequest;

  Future<AddTaskResponse> addTask(AddTaskRequest addTaskRequest) async {
    try {
      final AddTaskRequest encryptedAddTaskRequest =
          await encryptAddTaskRequest(addTaskRequest);

      final Response response = await _dio.post(
        '/agenda/tasks',
        data: encryptedAddTaskRequest.toMap(),
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
