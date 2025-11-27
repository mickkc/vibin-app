import 'package:vibin_app/dtos/track/minimal_track.dart';

class RelatedTrack {
  final MinimalTrack track;
  final String relationDescription;

  RelatedTrack({
    required this.track,
    required this.relationDescription,
  });

  factory RelatedTrack.fromJson(Map<String, dynamic> json) {
    return RelatedTrack(
      track: MinimalTrack.fromJson(json['key']),
      relationDescription: json['value'] as String,
    );
  }
}