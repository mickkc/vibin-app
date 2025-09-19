import 'package:json_annotation/json_annotation.dart';
import 'package:vibin_app/dtos/track/track.dart';

@JsonSerializable()
class PlaylistTrack {
  final Track track;
  final String source;

  PlaylistTrack({
    required this.track,
    required this.source,
  });

  factory PlaylistTrack.fromJson(Map<String, dynamic> json) {
    return PlaylistTrack(
      track: Track.fromJson(json['track']),
      source: json['source'],
    );
  }
}