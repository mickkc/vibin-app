class ScrobblerStatus {
  final bool error;
  final String? message;

  ScrobblerStatus({
    required this.error,
    this.message
  });

  factory ScrobblerStatus.fromJson(Map<String, dynamic> json) {
    return ScrobblerStatus(
      error: json['error'],
      message: json['message']
    );
  }
}