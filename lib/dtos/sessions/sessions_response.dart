import 'package:json_annotation/json_annotation.dart';
import 'package:vibin_app/dtos/sessions/session.dart';

@JsonSerializable()
class SessionsResponse {
  final List<Session> sessions;
  final int currentSessionIndex;

  SessionsResponse({
    required this.sessions,
    required this.currentSessionIndex,
  });

  factory SessionsResponse.fromJson(Map<String, dynamic> json) {
    return SessionsResponse(
      sessions: (json['sessions'] as List<dynamic>)
          .map((e) => Session.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentSessionIndex: json['currentSessionIndex'],
    );
  }
}