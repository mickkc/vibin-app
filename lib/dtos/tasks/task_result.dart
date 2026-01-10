import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class TaskResult {
  final bool success;
  final String? message;

  TaskResult({
    required this.success,
    this.message,
  });

  factory TaskResult.fromJson(Map<String, dynamic> json) {
    return TaskResult(
      success: json['success'],
      message: json['message'],
    );
  }
}