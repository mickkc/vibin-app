import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class MetadataSources {
  final List<String> file;
  final List<String> track;
  final List<String> album;
  final List<String> artist;
  final List<String> lyrics;

  MetadataSources({
    required this.file,
    required this.track,
    required this.album,
    required this.artist,
    required this.lyrics,
  });

  factory MetadataSources.fromJson(Map<String, dynamic> json) {
    return MetadataSources(
      file: List<String>.from(json['file']),
      album: List<String>.from(json['album']),
      track: List<String>.from(json['track']),
      artist: List<String>.from(json['artist']),
      lyrics: List<String>.from(json['lyrics']),
    );
  }
}