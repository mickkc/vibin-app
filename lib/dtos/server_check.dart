import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class ServerCheck {
  final String status;
  final String version;

  ServerCheck({
    required this.status,
    required this.version,
  });

  factory ServerCheck.fromJson(Map<String, dynamic> json) {
    return ServerCheck(
      status: json['status'],
      version: json['version'],
    );
  }
}