import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class Session {
  final int id;
  final int createdAt;
  final int lastUsed;

  Session({
    required this.id,
    required this.createdAt,
    required this.lastUsed,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'],
      createdAt: json['createdAt'],
      lastUsed: json['lastUsed'],
    );
  }
}