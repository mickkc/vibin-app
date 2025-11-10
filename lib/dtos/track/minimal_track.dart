import 'package:json_annotation/json_annotation.dart';
import 'package:vibin_app/dtos/id_name.dart';
import 'package:vibin_app/dtos/track/base_track.dart';

@JsonSerializable()
class MinimalTrack implements BaseTrack {
  @override
  final int id;
  final String title;
  final List<IdName> artists;
  final IdName album;
  final int? duration;
  final IdName? uploader;

  MinimalTrack({
    required this.id,
    required this.title,
    required this.artists,
    required this.album,
    this.duration,
    this.uploader,
  });

  factory MinimalTrack.fromJson(Map<String, dynamic> json) {
    return MinimalTrack(
      id: json['id'],
      title: json['title'],
      artists: (json['artists'] as List<dynamic>)
          .map((artistJson) => IdName.fromJson(artistJson))
          .toList(),
      album: IdName.fromJson(json['album']),
      duration: json['duration'],
      uploader: json['uploader'] != null ? IdName.fromJson(json['uploader']) : null,
    );
  }

  @override
  String getTitle() => title;

  @override
  IdName getAlbum() => album;

  @override
  List<IdName> getArtists() => artists;

  @override
  int? getTrackNumber() => null;

  @override
  int? getDuration() => duration;
}