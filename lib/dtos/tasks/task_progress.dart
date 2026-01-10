class TaskProgress {
  final String taskId;
  final double? progress;
  final String? message;

  TaskProgress({
    required this.taskId,
    this.progress,
    this.message,
  });

  factory TaskProgress.fromJson(Map<String, dynamic> json) {
    return TaskProgress(
      taskId: json['taskId'],
      progress: json['progress'],
      message: json['message'],
    );
  }
}