import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class MetadataSources {
  final List<String> file;
  final List<String> track;
  final List<String> artist;

  MetadataSources({
    required this.file,
    required this.track,
    required this.artist,
  });

  factory MetadataSources.fromJson(Map<String, dynamic> json) {
    return MetadataSources(
      file: List<String>.from(json['file']),
      track: List<String>.from(json['track']),
      artist: List<String>.from(json['artist']),
    );
  }
}