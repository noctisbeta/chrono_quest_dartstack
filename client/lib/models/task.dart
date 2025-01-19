import 'package:chrono_quest/models/task_type.dart';

final class Task {
  const Task({
    required this.dateTime,
    required this.description,
    required this.title,
    required this.taskType,
  });

  final DateTime dateTime;
  final String description;
  final String title;
  final TaskType taskType;
}
