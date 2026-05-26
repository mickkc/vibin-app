import 'package:vibin_app/dtos/track/minimal_track.dart';

class BatchEditResultChange {
  final MinimalTrack track;
  final String type;
  final String before;
  final String after;

  BatchEditResultChange({
    required this.track,
    required this.type,
    required this.before,
    required this.after
  });

  factory BatchEditResultChange.fromJson(Map<String, dynamic> json) {
    return BatchEditResultChange(
      track: MinimalTrack.fromJson(json['track']),
      type: json['type'],
      before: json['before'],
      after: json['after']
    );
  }
}