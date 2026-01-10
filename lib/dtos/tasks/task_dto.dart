
import 'package:json_annotation/json_annotation.dart';
import 'package:vibin_app/dtos/tasks/task_result.dart';

@JsonSerializable()
class Task {
  final String id;
  bool enabled;
  int? lastRun;
  final int? nextRun;
  final int? interval;
  TaskResult? lastResult;

  Task({
    required this.id,
    required this.enabled,
    this.lastRun,
    this.nextRun,
    this.interval,
    this.lastResult,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      enabled: json['enabled'],
      lastRun: json['lastRun'],
      nextRun: json['nextRun'],
      interval: json['interval'],
      lastResult: json['lastResult'] != null
          ? TaskResult.fromJson(json['lastResult'])
          : null,
    );
  }
}
