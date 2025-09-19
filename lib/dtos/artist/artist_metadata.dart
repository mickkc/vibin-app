import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class ArtistMetadata {
  final String name;
  final String? pictureUrl;

  ArtistMetadata({
    required this.name,
    this.pictureUrl,
  });

  factory ArtistMetadata.fromJson(Map<String, dynamic> json) {
    return ArtistMetadata(
      name: json['name'],
      pictureUrl: json['pictureUrl'],
    );
  }
}