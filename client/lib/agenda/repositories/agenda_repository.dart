import 'package:chrono_quest/dio_wrapper/dio_wrapper.dart';
import 'package:common/agenda/add_task_error.dart';
import 'package:common/agenda/add_task_request.dart';
import 'package:common/agenda/add_task_response.dart';
import 'package:common/logger/logger.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart' show immutable;

@immutable
final class AgendaRepository {
  const AgendaRepository({required this.dio});

  final DioWrapper dio;

  Future<AddTaskResponse> addTask(AddTaskRequest addTaskRequest) async {
    try {
      final Response response = await dio.post(
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
