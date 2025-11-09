import 'package:json_annotation/json_annotation.dart';

import '../id_name.dart';
import '../track/minimal_track.dart';

@JsonSerializable()
class PlaylistTrack {
  final MinimalTrack track;
  final int position;
  final IdName? addedBy;
  final int? addedAt;

  PlaylistTrack({
    required this.track,
    required this.position,
    this.addedBy,
    this.addedAt,
  });

  factory PlaylistTrack.fromJson(Map<String, dynamic> json) {
    return PlaylistTrack(
      track: MinimalTrack.fromJson(json['track']),
      position: json['position'],
      addedBy: json['addedBy'] != null ? IdName.fromJson(json['addedBy']) : null,
      addedAt: json['addedAt'],
    );
  }
}