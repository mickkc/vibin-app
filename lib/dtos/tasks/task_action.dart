import 'package:vibin_app/dtos/tasks/task_progress.dart';
import 'package:vibin_app/dtos/tasks/task_result.dart';

class TaskAction {
  final String taskId;
  final String action;
  final TaskProgress? progress;
  final TaskResult? result;

  TaskAction({
    required this.taskId,
    required this.action,
    this.progress,
    this.result,
  });

  factory TaskAction.fromJson(Map<String, dynamic> json) {
    return TaskAction(
      taskId: json['taskId'],
      action: json['action'],
      progress: json['progress'] != null
          ? TaskProgress.fromJson(json['progress'])
          : null,
      result: json['result'] != null
          ? TaskResult.fromJson(json['result'])
          : null,
    );
  }
}