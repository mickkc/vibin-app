import 'package:json_annotation/json_annotation.dart';
import 'package:vibin_app/dtos/id_name.dart';
import 'package:vibin_app/dtos/image.dart';

@JsonSerializable()
class MinimalTrack {
  final int id;
  final String title;
  final List<IdName> artists;
  final IdName album;
  final int? duration;
  final Image? cover;
  final IdName? uploader;

  MinimalTrack({
    required this.id,
    required this.title,
    required this.artists,
    required this.album,
    this.duration,
    this.cover,
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
      cover: json['cover'] != null ? Image.fromJson(json['cover']) : null,
      uploader: json['uploader'] != null ? IdName.fromJson(json['uploader']) : null,
    );
  }
}