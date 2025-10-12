import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class ArtistMetadata {
  final String name;
  final String? pictureUrl;
  final String? biography;

  ArtistMetadata({
    required this.name,
    this.pictureUrl,
    this.biography,
  });

  factory ArtistMetadata.fromJson(Map<String, dynamic> json) {
    return ArtistMetadata(
      name: json['name'],
      pictureUrl: json['pictureUrl'],
      biography: json['biography'],
    );
  }
}