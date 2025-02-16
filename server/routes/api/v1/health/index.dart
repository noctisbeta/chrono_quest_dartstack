import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:server/health/services/health_service.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final HealthService healthService =
      await context.read<Future<HealthService>>();
  final Map<String, dynamic> healthCheck = await healthService.checkHealth();

  final String status = healthCheck['status'];
  final DateTime timestamp = DateTime.parse(healthCheck['timestamp']);
  final Map<String, dynamic> databaseChecks = healthCheck['database'];

  final String dbStatus = databaseChecks['status'];
  final String dbLatency = databaseChecks['latency'];

  final health = <String, dynamic>{
    'status': status,
    'timestamp': timestamp.toIso8601String(),
    'version': '1.0.0',
    'service': 'chrono-quest-api',
    'api': {
      'version': 'v1',
      'dependencies': {'database': dbStatus},
      'latency': {'database': dbLatency},
    },
  };

  return Response.json(
    body: health,
    statusCode:
        health['status'] == 'UP'
            ? HttpStatus.ok
            : HttpStatus.serviceUnavailable,
  );
}
