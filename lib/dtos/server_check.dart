import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class ServerCheck {
  final String status;
  final String version;
  final List<String> supportedAppVersions;

  ServerCheck({
    required this.status,
    required this.version,
    required this.supportedAppVersions,
  });

  factory ServerCheck.fromJson(Map<String, dynamic> json) {
    return ServerCheck(
      status: json['status'],
      version: json['version'],
      supportedAppVersions: List<String>.from(json['supportedAppVersions'] as List),
    );
  }
}