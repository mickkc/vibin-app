import 'package:vibin_app/dtos/scrobbling/scrobbler_status.dart';

class Scrobbler {
  final String id;
  final String name;
  final bool available;
  final ScrobblerStatus? status;

  Scrobbler({
    required this.id,
    required this.name,
    required this.available,
    this.status
  });

  factory Scrobbler.fromJson(Map<String, dynamic> json) {
    return Scrobbler(
      id: json['id'],
      name: json['name'],
      available: json['available'],
      status: json['status'] != null ? ScrobblerStatus.fromJson(json['status']) : null,
    );
  }
}