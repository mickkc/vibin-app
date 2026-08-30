import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class Session {
  final int id;
  final String deviceName;
  final int createdAt;
  final int lastUsed;

  Session({
    required this.id,
    required this.deviceName,
    required this.createdAt,
    required this.lastUsed,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'],
      deviceName: json['deviceName'],
      createdAt: json['createdAt'],
      lastUsed: json['lastUsed'],
    );
  }
}