import 'package:json_annotation/json_annotation.dart';
import 'package:vibin_app/dtos/album/album.dart';
import 'package:vibin_app/dtos/track/minimal_track.dart';

@JsonSerializable()
class AlbumData {
  final Album album;
  final List<MinimalTrack> tracks;

  AlbumData({
    required this.album,
    required this.tracks,
  });

  factory AlbumData.fromJson(Map<String, dynamic> json) {
    return AlbumData(
      album: Album.fromJson(json['album']),
      tracks: (json['tracks'] as List<dynamic>)
          .map((trackJson) => MinimalTrack.fromJson(trackJson))
          .toList(),
    );
  }
}