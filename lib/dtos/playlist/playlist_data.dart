import 'package:json_annotation/json_annotation.dart';
import 'package:vibin_app/dtos/playlist/playlist.dart';
import 'package:vibin_app/dtos/playlist/playlist_track.dart';

@JsonSerializable()
class PlaylistData {
  final Playlist playlist;
  final List<PlaylistTrack> tracks;

  PlaylistData({
    required this.playlist,
    required this.tracks,
  });

  factory PlaylistData.fromJson(Map<String, dynamic> json) {
    return PlaylistData(
      playlist: Playlist.fromJson(json['playlist']),
      tracks: (json['tracks'] as List)
          .map((trackJson) => PlaylistTrack.fromJson(trackJson))
          .toList(),
    );
  }
}