class UploadResult {
  final bool success;
  final bool didFileAlreadyExist;
  final int? id;

  UploadResult({
    required this.success,
    required this.didFileAlreadyExist,
    this.id,
  });

  factory UploadResult.fromJson(Map<String, dynamic> json) {
    return UploadResult(
      success: json['success'],
      didFileAlreadyExist: json['didFileAlreadyExist'],
      id: json['id'],
    );
  }
}